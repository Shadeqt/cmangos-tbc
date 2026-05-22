#include "DualspecModule.h"

namespace cmangos_module
{
    DualspecModule::DualspecModule()
    : Module("DualSpec", new DualspecModuleConfig())
    {
    }

    const DualspecModuleConfig* DualspecModule::GetConfig() const
    {
        return (DualspecModuleConfig*)Module::GetConfig();
    }

    void DualspecModule::OnInitialize()
    {
        // TODO(M7): populate commandTable with the .dualspec family + debug hook.
    }

    // === M2: Player state hooks (scaffold; implementations land in M2) ===

    void DualspecModule::OnLoadFromDB(Player* player)
    {
        // TODO(M2): hydrate per-player state — activeTalentGroup, talentGroupsCount
        // from `characters` row; m_talents map from `character_talent` rows.
    }

    void DualspecModule::OnSaveToDB(Player* player)
    {
        // TODO(M2): persist activeTalentGroup, talentGroupsCount + character_talent
        // (delete-then-insert per row, mirroring acore's _SaveTalents).
    }

    void DualspecModule::OnLogOut(Player* player)
    {
        // TODO(M2): drop the per-player entry from the module's in-memory state map.
    }

    void DualspecModule::OnCharacterCreated(Player* player)
    {
        // TODO(M2): initialize activeTalentGroup=0, talentGroupsCount=1.
    }

    bool DualspecModule::OnLoadActionButtons(Player* player, ActionButtonList& actionButtons)
    {
        // TODO(M2): replace storage — SELECT FROM character_action WHERE spec=<active>.
        // Return true to suppress the core loader once the replacement is wired.
        return false;
    }

    bool DualspecModule::OnSaveActionButtons(Player* player, ActionButtonList& actionButtons)
    {
        // TODO(M2): replace storage — write with spec=<active>. Return true to
        // suppress the core saver once the replacement is wired.
        return false;
    }

    // === M2: talent integration / M5: spec-aware reset ===

    void DualspecModule::OnLearnTalent(Player* player, uint32 spellId)
    {
        // TODO(M2): upsert (guid, spellId) in m_talents with
        // specMask |= GetActiveSpecMask().
    }

    void DualspecModule::OnResetTalents(Player* player, uint32 cost)
    {
        // TODO(M5): spec-aware reset — clear active-spec bits in character_talent
        // and unlearn only the talents whose specMask had the active bit set.
    }

    // === M8: gossip integration ===

    bool DualspecModule::OnPreGossipHello(Player* player, Creature* creature)
    {
        // TODO(M8): when the creature matches GetConfig()->npcEntry, inject the
        // LEARN_DUALSPEC + ACTIVATE_PRIMARY/SECONDARY options gated by
        // m_specsCount, m_activeSpec, and minLevel.
        return false;
    }

    bool DualspecModule::OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action, const std::string& code, uint32 gossipListId)
    {
        // TODO(M8): dispatch LEARN_DUALSPEC -> UpdateSpecCount(2);
        // ACTIVATE_PRIMARY -> ActivateSpec(0); ACTIVATE_SECONDARY -> ActivateSpec(1).
        // BoxMoney auto-deduct handled at Player::OnGossipSelect:12597-12603 in core.
        return false;
    }

    // === M7: chat commands ===

    std::vector<ModuleChatCommand>* DualspecModule::GetCommandTable()
    {
        // TODO(M7): return the populated .dualspec family. Currently empty.
        return &commandTable;
    }
}
