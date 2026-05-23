#ifndef CMANGOS_MODULE_DUALSPECTBC_H
#define CMANGOS_MODULE_DUALSPECTBC_H

#include "Module.h"
#include "DualspectbcModuleConfig.h"

#include "Entities/ObjectGuid.h"

#include <cstdint>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

class Spell;

class WorldSession;

namespace cmangos_module
{
    static constexpr uint8 MAX_TALENT_SPECS = 2;

    // ActivateSpec / UpdateSpecCount return values. M4 will fill in the
    // gating reject codes; M3 only uses OK + SAME_SPEC + OUT_OF_RANGE +
    // NOT_LOADED.
    enum DualSpecResult : uint8
    {
        DUALSPEC_OK = 0,
        DUALSPEC_ERR_SAME_SPEC,
        DUALSPEC_ERR_OUT_OF_RANGE,
        DUALSPEC_ERR_NOT_LOADED,     // m_actionButtons ref not cached yet
        // M4 reject codes — placeholder values, filled in then:
        DUALSPEC_ERR_DEAD,
        DUALSPEC_ERR_IN_COMBAT,
        DUALSPEC_ERR_WHILE_CASTING,
        DUALSPEC_ERR_IN_DUEL,
        DUALSPEC_ERR_IN_BG,
        DUALSPEC_ERR_ON_TAXI,
        DUALSPEC_ERR_IN_FORM,
    };

    struct DualSpecState
    {
        uint8 activeSpec = 0;
        uint8 specsCount = 1;
        // spell -> specMask (bit0 = spec0, bit1 = spec1)
        std::unordered_map<uint32, uint8> talents;
        // Cached pointer to player->m_actionButtons. Set when
        // OnLoadActionButtons or OnSaveActionButtons fires (the framework
        // hands us the reference); cleared in OnLogOut. ActivateSpec needs
        // direct map access for the pre-flip save and the post-flip clear.
        ActionButtonList* actionsRef = nullptr;
        // M3.5: outgoing auras this player has cast — on others AND on
        // themselves. Keyed by target guid (includes the swapper's own
        // guid for self-cast buffs), valued by the set of spell ids
        // active on that target. Populated via OnHit, drained on swap.
        // Stale entries (target despawned, aura naturally expired) are
        // harmless: RemoveAurasByCasterSpell is a no-op if not present.
        std::unordered_map<ObjectGuid, std::unordered_set<uint32>> outgoingAuras;
    };

    class DualspectbcModule : public Module
    {
    public:
        DualspectbcModule();
        const DualspectbcModuleConfig* GetConfig() const override;

        void OnInitialize() override;

        // M2: per-player state hydration / persistence. Action-bar storage
        // is replaced via OnLoad/SaveActionButtons (return true), so the
        // core path's spec-blind queries never run.
        void OnLoadFromDB(Player* player) override;
        void OnSaveToDB(Player* player) override;
        void OnLogOut(Player* player) override;
        void OnCharacterCreated(Player* player) override;
        bool OnLoadActionButtons(Player* player, ActionButtonList& actionButtons) override;
        bool OnSaveActionButtons(Player* player, ActionButtonList& actionButtons) override;

        // M2 (LearnTalent integration) + M5 (spec-aware reset).
        void OnLearnTalent(Player* player, uint32 spellId) override;
        void OnResetTalents(Player* player, uint32 cost) override;

        // M3.5: track outgoing auras the player applies on other units, so
        // the swap can strip them. Fires after AddSpellAuraHolder runs
        // inside DoSpellHitOnUnit (Spell.cpp:1358, unconditional of
        // m_damage/m_healing) — works for both Moonfire-style damage+aura
        // and Mark-of-the-Wild-style pure-buff casts.
        void OnHit(Spell* spell, Unit* caster, Unit* victim) override;

        // M8: gossip-driven unlock + switch on the Talent Specialist NPC.
        bool OnPreGossipHello(Player* player, Creature* creature) override;
        bool OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action, const std::string& code, uint32 gossipListId) override;

        // M7: chat command surface. M3 ships `.dualspec_debug` for testing
        // until M7 replaces it with the full `.dualspec` family.
        const char* GetChatCommandPrefix() const override { return "dualspec_debug"; }
        std::vector<ModuleChatCommand>* GetCommandTable() override;

        // M3: spec swap. Public so chat / gossip / addon dispatch can call it.
        // bypassGating skips the M4 CanActivateSpec checks — only the
        // .dualspec_debug commands set it, so manual test runs can drive
        // mid-combat / mid-cast scenarios (Hunter's Mark across swap, etc.).
        DualSpecResult ActivateSpec(Player* player, uint8 spec, bool bypassGating = false);

        // M4: returns DUALSPEC_OK if the player's current gameplay state
        // permits a spec swap; otherwise the appropriate ERR_* reject.
        // No mutation — safe to call from gossip-menu visibility predicates
        // (M8) as well as from ActivateSpec.
        DualSpecResult CanActivateSpec(Player* player);

    private:
        DualSpecState& GetOrCreateState(Player* player);
        DualSpecState* FindState(Player* player);
        static uint8 SpecMask(uint8 spec) { return uint8(1u << spec); }

        // Shared helpers used by ActivateSpec and the action-button hooks.
        void SaveActionsForSpec(Player* player, ActionButtonList& buttons, uint8 spec);
        void LoadActionsForSpec(Player* player, uint8 spec);

        // M3.5: drain the outgoing-aura tracker. Walks each tracked target,
        // removes any matching holders, then DELETEs offline / cross-map
        // targets' rows from character_aura so they don't reapply on next
        // login.
        void StripOutgoingAuras(Player* swapper);

        // M3 debug command handlers; removed at M7.
        bool DebugCmdEnable(WorldSession* session, const std::string& args);
        bool DebugCmdSwap(WorldSession* session, const std::string& args, uint8 spec);
        bool DebugCmdStatus(WorldSession* session, const std::string& args);

        std::unordered_map<ObjectGuid, DualSpecState> m_state;
        std::vector<ModuleChatCommand> commandTable;
    };
}

#endif
