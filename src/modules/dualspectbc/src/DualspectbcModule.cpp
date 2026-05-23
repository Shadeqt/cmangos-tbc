#include "DualspectbcModule.h"

#include "Entities/Player.h"
#include "BattleGround/BattleGround.h"
#include "Database/DatabaseEnv.h"
#include "Log/Log.h"
#include "Maps/Map.h"
#include "Server/WorldSession.h"
#include "Spells/Spell.h"
#include "Spells/SpellMgr.h"
#include "Chat/Chat.h"

#include <vector>

namespace cmangos_module
{
    DualspectbcModule::DualspectbcModule()
    : Module("DualSpec", new DualspectbcModuleConfig())
    {
    }

    const DualspectbcModuleConfig* DualspectbcModule::GetConfig() const
    {
        return (DualspectbcModuleConfig*)Module::GetConfig();
    }

    DualSpecState& DualspectbcModule::GetOrCreateState(Player* player)
    {
        return m_state[player->GetObjectGuid()];
    }

    DualSpecState* DualspectbcModule::FindState(Player* player)
    {
        auto it = m_state.find(player->GetObjectGuid());
        return it == m_state.end() ? nullptr : &it->second;
    }

    // === M2: lifecycle ===

    void DualspectbcModule::OnCharacterCreated(Player* player)
    {
        DualSpecState& st = GetOrCreateState(player);
        st.activeSpec = 0;
        st.specsCount = 1;
        st.talents.clear();
        // characters.activeTalentGroup / talentGroupsCount carry DB DEFAULTs
        // (0, 1), so the row inserted by Player::SaveToDB's uberInsert leaves
        // them correct without an explicit module write.
    }

    void DualspectbcModule::OnLoadFromDB(Player* player)
    {
        const uint32 lowguid = player->GetGUIDLow();
        DualSpecState& st = GetOrCreateState(player);
        st.talents.clear();

        if (auto result = CharacterDatabase.PQuery(
                "SELECT activeTalentGroup, talentGroupsCount FROM characters WHERE guid = '%u'",
                lowguid))
        {
            Field* fields = result->Fetch();
            st.activeSpec = fields[0].GetUInt8();
            st.specsCount = fields[1].GetUInt8();
            if (st.specsCount == 0)
                st.specsCount = 1;
            if (st.activeSpec >= st.specsCount)
                st.activeSpec = 0;
        }
        else
        {
            st.activeSpec = 0;
            st.specsCount = 1;
        }

        if (auto result = CharacterDatabase.PQuery(
                "SELECT spell, specMask FROM character_talent WHERE guid = '%u'",
                lowguid))
        {
            do
            {
                Field* fields = result->Fetch();
                const uint32 spell = fields[0].GetUInt32();
                const uint8 mask = fields[1].GetUInt8();
                if (mask)
                    st.talents[spell] = mask;
            }
            while (result->NextRow());
        }
    }

    void DualspectbcModule::OnSaveToDB(Player* player)
    {
        DualSpecState* st = FindState(player);
        if (!st)
            return;

        const uint32 lowguid = player->GetGUIDLow();

        // Player::SaveToDB commits its main transaction before invoking this
        // hook (Player.cpp:16974 -> :16985). Wrap our own work in a fresh
        // transaction so talent + characters-column updates land atomically.
        CharacterDatabase.BeginTransaction();
        CharacterDatabase.PExecute(
            "UPDATE characters SET activeTalentGroup = '%u', talentGroupsCount = '%u' WHERE guid = '%u'",
            uint32(st->activeSpec), uint32(st->specsCount), lowguid);
        CharacterDatabase.PExecute("DELETE FROM character_talent WHERE guid = '%u'", lowguid);
        for (const auto& kv : st->talents)
        {
            CharacterDatabase.PExecute(
                "INSERT INTO character_talent (guid, spell, specMask) VALUES ('%u', '%u', '%u')",
                lowguid, kv.first, uint32(kv.second));
        }
        CharacterDatabase.CommitTransaction();
    }

    void DualspectbcModule::OnLogOut(Player* player)
    {
        // Erasing the state entry also invalidates the cached actionsRef,
        // which is essential — &player->m_actionButtons becomes dangling
        // once ~Player runs (this hook fires from the destructor).
        m_state.erase(player->GetObjectGuid());
    }

    // === M2/M3: action-bar storage replacement + ActivateSpec helpers ===

    void DualspectbcModule::SaveActionsForSpec(Player* player, ActionButtonList& buttons, uint8 spec)
    {
        const uint32 lowguid = player->GetGUIDLow();

        // Replace-all semantics: drop this spec's rows, then re-insert from
        // the in-memory map. Simpler than per-uState INSERT/UPDATE/DELETE
        // and matches the spec-swap rebuild pattern.
        CharacterDatabase.PExecute(
            "DELETE FROM character_action WHERE guid = '%u' AND spec = '%u'",
            lowguid, uint32(spec));

        for (auto it = buttons.begin(); it != buttons.end(); )
        {
            if (it->second.uState == ACTIONBUTTON_DELETED)
            {
                it = buttons.erase(it);
                continue;
            }
            CharacterDatabase.PExecute(
                "INSERT INTO character_action (guid, spec, button, action, type) VALUES ('%u', '%u', '%u', '%u', '%u')",
                lowguid, uint32(spec), uint32(it->first), it->second.GetAction(), uint32(it->second.GetType()));
            it->second.uState = ACTIONBUTTON_UNCHANGED;
            ++it;
        }
    }

    void DualspectbcModule::LoadActionsForSpec(Player* player, uint8 spec)
    {
        const uint32 lowguid = player->GetGUIDLow();

        // Public-API teardown of the current m_actionButtons: removeActionButton
        // marks existing entries DELETED (or erases freshly-NEW ones outright).
        // SendInitialActionButtons skips DELETED entries; the next save will
        // physically erase them.
        for (uint8 b = 0; b < MAX_ACTION_BUTTONS; ++b)
            player->removeActionButton(b);

        auto result = CharacterDatabase.PQuery(
            "SELECT button, action, type FROM character_action WHERE guid = '%u' AND spec = '%u' ORDER BY button",
            lowguid, uint32(spec));
        if (!result)
            return;

        do
        {
            Field* fields = result->Fetch();
            const uint8 button = fields[0].GetUInt8();
            const uint32 action = fields[1].GetUInt32();
            const uint8 type = fields[2].GetUInt8();

            if (ActionButton* ab = player->addActionButton(button, action, type))
            {
                ab->uState = ACTIONBUTTON_UNCHANGED;
            }
            else
            {
                sLog.outError("DualSpec: invalid action button on load (guid=%u, spec=%u, button=%u, action=%u, type=%u)",
                    lowguid, uint32(spec), uint32(button), action, uint32(type));
            }
        }
        while (result->NextRow());
    }

    bool DualspectbcModule::OnLoadActionButtons(Player* player, ActionButtonList& actionButtons)
    {
        // Cache the reference for ActivateSpec. Safe for the player's lifetime;
        // OnLogOut clears the state entry before the Player destructor runs out
        // of useful state.
        GetOrCreateState(player).actionsRef = &actionButtons;

        // OnLoadActionButtons fires inside _LoadActions (Player.cpp:15730),
        // which runs earlier in _LoadFromDB than OnLoadFromDB hydrates state.
        // Resolve active spec inline via JOIN.
        const uint32 lowguid = player->GetGUIDLow();
        actionButtons.clear();

        auto result = CharacterDatabase.PQuery(
            "SELECT ca.button, ca.action, ca.type"
            " FROM character_action ca"
            " JOIN characters c ON c.guid = ca.guid"
            " WHERE ca.guid = '%u' AND ca.spec = c.activeTalentGroup"
            " ORDER BY ca.button",
            lowguid);

        if (result)
        {
            do
            {
                Field* fields = result->Fetch();
                const uint8 button = fields[0].GetUInt8();
                const uint32 action = fields[1].GetUInt32();
                const uint8 type = fields[2].GetUInt8();

                if (ActionButton* ab = player->addActionButton(button, action, type))
                {
                    ab->uState = ACTIONBUTTON_UNCHANGED;
                }
                else
                {
                    sLog.outError("DualSpec: invalid action button on load (guid=%u, button=%u, action=%u, type=%u) - marked for delete",
                        lowguid, uint32(button), action, uint32(type));
                    actionButtons[button].uState = ACTIONBUTTON_DELETED;
                }
            }
            while (result->NextRow());
        }

        return true;
    }

    bool DualspectbcModule::OnSaveActionButtons(Player* player, ActionButtonList& actionButtons)
    {
        // GetOrCreateState (not FindState) so we never fall through to the
        // core saver, whose UPDATE/DELETE statements are spec-blind and would
        // corrupt the other spec's rows.
        DualSpecState& st = GetOrCreateState(player);
        st.actionsRef = &actionButtons;  // refresh the cache; usually a no-op

        SaveActionsForSpec(player, actionButtons, st.activeSpec);
        return true;
    }

    // === M2: talent integration / M5: spec-aware reset ===

    void DualspectbcModule::OnLearnTalent(Player* player, uint32 spellId)
    {
        DualSpecState& st = GetOrCreateState(player);
        const uint8 mask = SpecMask(st.activeSpec);
        auto it = st.talents.find(spellId);
        if (it == st.talents.end())
            st.talents.emplace(spellId, mask);
        else
            it->second = uint8(it->second | mask);
    }

    void DualspectbcModule::OnResetTalents(Player* player, uint32 /*cost*/)
    {
        // Core's Player::resetTalents (Player.cpp:3988) is spec-blind on the
        // spell side: it walks sTalentStore and removeSpell()s every talent
        // rank for the class. For talents the player has learned in the
        // ACTIVE spec, that successfully removes them from m_spells. For
        // talents only present in the INACTIVE spec, removeSpell is a
        // harmless no-op (player doesn't have the spell learned). Cost is
        // already deducted character-wide via m_resetTalentsCost — per-spec
        // cost tracking is NOT a thing in retail/acore (verified) so we
        // don't touch it.
        //
        // The module's job: keep m_state[guid].talents in sync. Clear the
        // active-spec bit from every entry; drop rows whose mask becomes 0.
        // Persisted at next OnSaveToDB.
        DualSpecState* st = FindState(player);
        if (!st)
            return;

        const uint8 activeBit = SpecMask(st->activeSpec);
        for (auto it = st->talents.begin(); it != st->talents.end(); )
        {
            const uint8 newMask = uint8(it->second & ~activeBit);
            if (newMask == 0)
                it = st->talents.erase(it);
            else
            {
                it->second = newMask;
                ++it;
            }
        }

        // M3.5 outgoing-aura tracker entries for talent-cast self-buffs
        // would auto-clear on the next swap; resetTalents itself doesn't
        // trigger a swap, so we leave the tracker alone here. Auras
        // applied by the now-removed talents linger only if their source
        // spell wasn't unlearned by core's removeSpell — should not
        // happen, but step 9's source-spell-lost sweep on the next swap
        // would catch any residue.
    }

    // === M3.5: outgoing-aura tracking + strip on swap ===

    void DualspectbcModule::OnHit(Spell* spell, Unit* caster, Unit* victim)
    {
        // Gates, cheapest first. Self-casts (caster == victim) ARE tracked
        // intentionally: a druid casting MotW on themselves then swapping
        // would otherwise carry the talented buff across, defeating the
        // anti-exploit. Strip-everything is the project mandate.
        if (!caster || !victim)
            return;
        if (!caster->IsPlayer())
            return;
        if (!spell)
            return;
        SpellEntry const* spellInfo = spell->m_spellInfo;
        if (!spellInfo)
            return;
        // Skip passive spells (auto-granted by talent / racial / item,
        // not "cast on" anyone — auto-reapplied post-swap from m_spells).
        if (spellInfo->HasAttribute(SPELL_ATTR_PASSIVE))
            return;
        // Only record if this spell actually applies an aura. Direct-damage
        // spells (Frostbolt without a slow component) don't need tracking;
        // keeps the set lean.
        if (!IsSpellAppliesAura(spellInfo))
            return;

        Player* player = static_cast<Player*>(caster);
        DualSpecState* st = FindState(player);
        if (!st)
            return;

        st->outgoingAuras[victim->GetObjectGuid()].insert(spellInfo->Id);
    }

    void DualspectbcModule::StripOutgoingAuras(Player* swapper)
    {
        DualSpecState* st = FindState(swapper);
        if (!st)
            return;

        const ObjectGuid swapperGuid = swapper->GetObjectGuid();
        Map* map = swapper->GetMap();

        // Online / same-map targets: resolve and strip in memory. Targets we
        // can't reach (offline, cross-map, despawned) silently fall through
        // to the DB sweep below.
        for (auto const& kv : st->outgoingAuras)
        {
            Unit* target = map ? map->GetUnit(kv.first) : nullptr;
            if (!target)
                continue;
            for (uint32 spellId : kv.second)
                target->RemoveAurasByCasterSpell(spellId, swapperGuid);
        }

        st->outgoingAuras.clear();

        // Phase 2: offline / unreachable targets. Single indexed DELETE on
        // character_aura.caster_guid (column stores the full raw uint64 per
        // Player.cpp:17109 — `holder->GetCasterGuid().GetRawValue()`). PK
        // (guid, caster_guid, item_guid, spell) makes this index-eligible.
        // Catches buffs on logged-out raid members so they don't reapply on
        // their next login.
        CharacterDatabase.PExecute(
            "DELETE FROM character_aura WHERE caster_guid = '" UI64FMTD "'",
            swapperGuid.GetRawValue());

        sLog.outBasic("[DualSpec] guid=%u StripOutgoingAuras: in-memory cleared, character_aura swept",
                      swapper->GetGUIDLow());
    }

    // === M4: gating predicate ===

    DualSpecResult DualspectbcModule::CanActivateSpec(Player* player)
    {
        // Order matches the natural "is the player even available" -> "are
        // they doing something blocking" progression. All checks are pure
        // reads; calling this is safe in M8's gossip-visibility path.
        if (!player->IsAlive())
            return DUALSPEC_ERR_DEAD;
        if (player->IsInCombat())
            return DUALSPEC_ERR_IN_COMBAT;
        if (player->IsNonMeleeSpellCasted(true))
            return DUALSPEC_ERR_WHILE_CASTING;
        if (player->duel)
            return DUALSPEC_ERR_IN_DUEL;
        if (BattleGround* bg = player->GetBattleGround())
        {
            if (bg->GetStatus() == STATUS_IN_PROGRESS)
                return DUALSPEC_ERR_IN_BG;
        }
        if (player->IsTaxiFlying())
            return DUALSPEC_ERR_ON_TAXI;
        // IsShapeShifted (Unit.cpp:11418) honors the SHAPESHIFT_FLAG_STANCE
        // bit, so warrior battle/defensive/berserker stances do NOT reject —
        // only "real" forms (druid cat/bear/etc., rogue stealth, shadowform,
        // ghost wolf). The plan's literal `GetShapeshiftForm() != FORM_NONE`
        // would have permanently locked warriors out of swap.
        if (player->IsShapeShifted())
            return DUALSPEC_ERR_IN_FORM;
        return DUALSPEC_OK;
    }

    // === M3: ActivateSpec — live swap ===

    DualSpecResult DualspectbcModule::ActivateSpec(Player* player, uint8 spec, bool bypassGating)
    {
        DualSpecState& st = GetOrCreateState(player);

        // Step 1a: spec-argument validation (cheap, can't gate on state).
        if (spec == st.activeSpec)
            return DUALSPEC_ERR_SAME_SPEC;
        if (spec >= st.specsCount)
            return DUALSPEC_ERR_OUT_OF_RANGE;
        if (!st.actionsRef)
            return DUALSPEC_ERR_NOT_LOADED;

        // Step 1b (M4): gameplay-state gating. Must reject BEFORE any state
        // mutation in step 2+ for A4.5 atomicity. Skipped when the debug
        // commands explicitly bypass (so manual tests can drive mid-combat
        // / mid-cast scenarios like Hunter's Mark across swap).
        if (!bypassGating)
        {
            if (DualSpecResult gate = CanActivateSpec(player); gate != DUALSPEC_OK)
                return gate;
        }

        const uint8 oldSpec = st.activeSpec;
        const uint8 oldMask = SpecMask(oldSpec);
        const uint8 newMask = SpecMask(spec);

        sLog.outBasic("[DualSpec] guid=%u name=%s ActivateSpec %u -> %u",
                      player->GetGUIDLow(), player->GetName(),
                      uint32(oldSpec), uint32(spec));

        // Step 2: snapshot the old spec's bars to DB *before* we mutate
        // anything; despawn pet/totems; interrupt non-melee casts.
        player->InterruptNonMeleeSpells(false);
        SaveActionsForSpec(player, *st.actionsRef, oldSpec);
        player->UnsummonPetTemporaryIfAny();
        player->UnsummonAllTotems();
        // TBC has no SMSG_ACTION_BUTTONS clear opcode; step 11's
        // SendInitialActionButtons will rewrite the bar after the swap.

        // Step 3: remove talents that are in the old spec only. sendUpdate=true
        // fires SMSG_REMOVED_SPELL per spell — the TBC client treats
        // SMSG_INITIAL_SPELLS as additive, so without per-spell removal
        // packets the client's spellbook + talent frame never forget the
        // old-spec spells. Cost: a "you have unlearned" toast per rank.
        // TODO(M3-followup): suppress the toast client-side or batch via
        // a custom opcode.
        // learn_low_rank=false prevents auto-downgrade to a lower rank.
        for (auto const& kv : st.talents)
        {
            const uint32 spellId = kv.first;
            const uint8 mask = kv.second;
            if ((mask & oldMask) && !(mask & newMask))
            {
                player->RemoveAurasDueToSpell(spellId);
                player->removeSpell(spellId, /*disabled=*/false, /*learn_low_rank=*/false, /*sendUpdate=*/true);
            }
        }

        // Step 4: ~~glyphs~~ - TBC has no glyph system.

        // Step 5: flip the active spec index.
        st.activeSpec = spec;

        // Step 6: re-apply talents in the new spec. learnSpell fires
        // SMSG_LEARNED_SPELL (Player.cpp:3679); the addSpell-only path
        // leaves the client unaware of the re-added spells. Cost: a
        // "you have learned" toast per rank. talent=false suppresses
        // the higher-rank cascade (we only re-learn exactly the ranks
        // in m_state.talents, not any subsequent ranks).
        for (auto const& kv : st.talents)
        {
            const uint32 spellId = kv.first;
            const uint8 mask = kv.second;
            if ((mask & newMask) && !(mask & oldMask))
            {
                player->learnSpell(spellId, /*dependent=*/false, /*talent=*/false);
            }
        }

        // Step 7: ~~non-talent spec-tagged spells~~ - we don't tag non-talent
        // spells with a specMask in TBC, so this loop is empty.

        // Step 8: ~~glyphs~~

        // Step 9: sweep self-orphaned auras — auras the SWAPPER cast on
        // themselves whose source spell is no longer learned. Catches
        // self-buffs from talent passives that linger after the talent is
        // gone (M3.5's OnHit tracker would also catch these for the
        // common case, but step 9 is defense-in-depth for auras applied
        // before the module loaded for this player).
        //
        // CRITICAL: filter on caster == swapper. The earlier draft of
        // this loop removed ANY aura whose spell-id wasn't in
        // `player->m_spells`, which wiped buffs OTHER players had cast
        // on the swapper (a priest's PW:Fortitude on a paladin is not
        // in the paladin's m_spells). Reported as a bug after live
        // test 2026-05-23.
        {
            std::vector<uint32> orphans;
            const ObjectGuid swapperGuid = player->GetObjectGuid();
            for (auto const& kv : player->GetSpellAuraHolderMap())
            {
                SpellAuraHolder* holder = kv.second;
                if (!holder || holder->GetCasterGuid() != swapperGuid)
                    continue;
                const uint32 spellId = kv.first;
                if (!player->HasSpell(spellId))
                    orphans.push_back(spellId);
            }
            for (uint32 spellId : orphans)
                player->RemoveAurasByCasterSpell(spellId, swapperGuid);
        }

        // Step 10: recompute the talent-point pool. UpdateFreeTalentPoints
        // walks the player's spells/skills to compute used vs available;
        // since steps 3+6 mutated m_spells, the value resolves correctly
        // for the new spec. `false` suppresses the auto-reset cascade if
        // somehow used > available (it shouldn't be).
        player->UpdateFreeTalentPoints(false);

        // Step 10b: zero current power. Anti-exploit port of acore
        // Player.cpp:15387-15391. Prevents using swap as a free rage /
        // energy / mana refill. Mana is zeroed even when not the active
        // type to close the druid-hybrid workaround (cat form's
        // POWER_ENERGY active type would otherwise let the mana pool
        // retain value across a swap).
        {
            Powers pw = player->GetPowerType();
            if (pw != POWER_MANA)
                player->SetPower(POWER_MANA, 0);
            player->SetPower(pw, 0);
        }

        // Step 11: load the new spec's action bars.
        LoadActionsForSpec(player, spec);
        player->SendInitialActionButtons();

        // Step 12: class fixups.
        player->ResummonPetTemporaryUnSummonedIfAny();
        // Shaman: dropping Enhancement => dropping Dual Wield Spec (674).
        // AutoUnequipOffhandIfNeed handles non-shaman classes correctly too
        // (it's a no-op for them since they don't have an off-hand main-hand
        // weapon mismatch).
        if (!player->HasSpell(674))
            player->AutoUnequipOffhandIfNeed();
        // Paladin: drop Righteous Fury (25780) when leaving Prot. Cheap to
        // call for any class — RemoveAurasDueToSpell is a no-op if absent.
        if (player->getClass() == CLASS_PALADIN)
            player->RemoveAurasDueToSpell(25780);
        // M3.5: strip every aura the swapper cast — on others AND on
        // themselves. Anti-exploit: prevents both the swap-to-buffer
        // pattern (cast boosted MotW on raid → swap → raid keeps it)
        // AND the self-buff variant (cast self-MotW in Improved MotW
        // spec → swap → swapper keeps boosted self-buff). Tracker is
        // populated by OnHit; this call drains it for in-world targets
        // and DELETEs character_aura for offline targets.
        StripOutgoingAuras(player);

        // Step 13: bulk spellbook snapshot. The TBC talent frame re-renders
        // from m_spells + PLAYER_CHARACTER_POINTS1 on next open; this packet
        // and the field update from step 10 give it everything it needs.
        player->SendInitialSpells();

        sLog.outBasic("[DualSpec] guid=%u ActivateSpec %u -> %u: ok",
                      player->GetGUIDLow(), uint32(oldSpec), uint32(spec));
        return DUALSPEC_OK;
    }

    // === M3 debug chat commands (removed at M7) ===

    namespace
    {
        DualspectbcModule* g_module = nullptr;

        Player* SessionPlayer(WorldSession* session)
        {
            return session ? session->GetPlayer() : nullptr;
        }

        const char* ResultText(DualSpecResult r)
        {
            switch (r)
            {
                case DUALSPEC_OK:                return "ok";
                case DUALSPEC_ERR_SAME_SPEC:     return "already active spec";
                case DUALSPEC_ERR_OUT_OF_RANGE:  return "spec index out of range";
                case DUALSPEC_ERR_NOT_LOADED:    return "internal: action buttons not yet loaded";
                case DUALSPEC_ERR_DEAD:          return "you are dead";
                case DUALSPEC_ERR_IN_COMBAT:     return "you are in combat";
                case DUALSPEC_ERR_WHILE_CASTING: return "you are casting";
                case DUALSPEC_ERR_IN_DUEL:       return "you are in a duel";
                case DUALSPEC_ERR_IN_BG:         return "you are in a battleground";
                case DUALSPEC_ERR_ON_TAXI:       return "you are on a taxi";
                case DUALSPEC_ERR_IN_FORM:       return "you are shapeshifted";
                default:                          return "unknown";
            }
        }
    }

    // TODO(M7): remove debug command
    bool DualspectbcModule::DebugCmdEnable(WorldSession* session, const std::string& /*args*/)
    {
        Player* player = SessionPlayer(session);
        if (!player)
            return false;

        DualSpecState& st = GetOrCreateState(player);
        if (st.specsCount >= MAX_TALENT_SPECS)
        {
            ChatHandler(session).PSendSysMessage("dualspec_debug: already at specsCount=%u", uint32(st.specsCount));
            return true;
        }

        const uint32 lowguid = player->GetGUIDLow();
        CharacterDatabase.BeginTransaction();
        // Duplicate the active spec's action bars into spec=1 so the swap
        // doesn't strand the player with empty bars on first activation.
        CharacterDatabase.PExecute(
            "DELETE FROM character_action WHERE guid = '%u' AND spec = '%u'",
            lowguid, uint32(st.activeSpec ^ 1u));
        CharacterDatabase.PExecute(
            "INSERT INTO character_action (guid, spec, button, action, type)"
            " SELECT guid, '%u', button, action, type FROM character_action"
            " WHERE guid = '%u' AND spec = '%u'",
            uint32(st.activeSpec ^ 1u), lowguid, uint32(st.activeSpec));
        CharacterDatabase.CommitTransaction();

        st.specsCount = MAX_TALENT_SPECS;
        // Persisted at next OnSaveToDB; force-write the column now for
        // immediate visibility.
        CharacterDatabase.PExecute(
            "UPDATE characters SET talentGroupsCount = '%u' WHERE guid = '%u'",
            uint32(MAX_TALENT_SPECS), lowguid);

        ChatHandler(session).PSendSysMessage(
            "dualspec_debug: specsCount=%u, bars duplicated to spec=%u",
            uint32(MAX_TALENT_SPECS), uint32(st.activeSpec ^ 1u));
        return true;
    }

    // TODO(M7): remove debug command
    bool DualspectbcModule::DebugCmdSwap(WorldSession* session, const std::string& /*args*/, uint8 spec)
    {
        Player* player = SessionPlayer(session);
        if (!player)
            return false;

        // Honors M4 gating. Originally passed bypassGating=true to allow
        // in-combat M3.5 strip-testing; now that M3.5 is verified, the
        // bypass became a footgun and was reverted (live test 2026-05-23).
        // If a future test genuinely needs to drive a swap while gated,
        // re-add a separate `.dualspec_debug force0|force1` command rather
        // than re-arming the default path.
        DualSpecResult r = ActivateSpec(player, spec);
        ChatHandler(session).PSendSysMessage(
            "dualspec_debug: ActivateSpec(%u) -> %s", uint32(spec), ResultText(r));
        return true;
    }

    // TODO(M7): remove debug command
    bool DualspectbcModule::DebugCmdStatus(WorldSession* session, const std::string& /*args*/)
    {
        Player* player = SessionPlayer(session);
        if (!player)
            return false;

        DualSpecState* st = FindState(player);
        if (!st)
        {
            ChatHandler(session).SendSysMessage("dualspec_debug: no state (player not loaded?)");
            return true;
        }

        size_t spec0Count = 0;
        size_t spec1Count = 0;
        for (auto const& kv : st->talents)
        {
            if (kv.second & 1u) ++spec0Count;
            if (kv.second & 2u) ++spec1Count;
        }

        ChatHandler(session).PSendSysMessage(
            "dualspec_debug: activeSpec=%u specsCount=%u talents=%zu/%zu (spec0/spec1) actionsRef=%s",
            uint32(st->activeSpec), uint32(st->specsCount),
            spec0Count, spec1Count, st->actionsRef ? "set" : "null");
        return true;
    }

    // === M7-stubbed gossip hooks ===

    bool DualspectbcModule::OnPreGossipHello(Player* /*player*/, Creature* /*creature*/)
    {
        return false;
    }

    bool DualspectbcModule::OnGossipSelect(Player* /*player*/, Creature* /*creature*/, uint32 /*sender*/, uint32 /*action*/, const std::string& /*code*/, uint32 /*gossipListId*/)
    {
        return false;
    }

    // === Chat command table registration ===

    void DualspectbcModule::OnInitialize()
    {
        g_module = this;

        commandTable.clear();
        // TODO(M7): drop the whole .dualspec_debug family once .dualspec
        // production commands ship.
        commandTable.push_back({
            "enable",
            [](WorldSession* s, const std::string& args) { return g_module->DebugCmdEnable(s, args); },
            SEC_GAMEMASTER
        });
        commandTable.push_back({
            "0",
            [](WorldSession* s, const std::string& args) { return g_module->DebugCmdSwap(s, args, 0); },
            SEC_GAMEMASTER
        });
        commandTable.push_back({
            "1",
            [](WorldSession* s, const std::string& args) { return g_module->DebugCmdSwap(s, args, 1); },
            SEC_GAMEMASTER
        });
        commandTable.push_back({
            "status",
            [](WorldSession* s, const std::string& args) { return g_module->DebugCmdStatus(s, args); },
            SEC_GAMEMASTER
        });
    }

    std::vector<ModuleChatCommand>* DualspectbcModule::GetCommandTable()
    {
        return &commandTable;
    }
}
