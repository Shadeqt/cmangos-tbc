#ifndef CMANGOS_MODULE_DUALSPEC_H
#define CMANGOS_MODULE_DUALSPEC_H

#include "Module.h"
#include "DualspecModuleConfig.h"

namespace cmangos_module
{
    class DualspecModule : public Module
    {
    public:
        DualspecModule();
        const DualspecModuleConfig* GetConfig() const override;

        void OnInitialize() override;

        // M2: Player state hydration / persistence. Per-spec talent +
        // action-bar storage keyed by ObjectGuid. OnLoad/SaveActionButtons
        // replace the core storage backend (return true).
        void OnLoadFromDB(Player* player) override;
        void OnSaveToDB(Player* player) override;
        void OnLogOut(Player* player) override;
        void OnCharacterCreated(Player* player) override;
        bool OnLoadActionButtons(Player* player, ActionButtonList& actionButtons) override;
        bool OnSaveActionButtons(Player* player, ActionButtonList& actionButtons) override;

        // M2 (LearnTalent integration) + M5 (spec-aware reset).
        void OnLearnTalent(Player* player, uint32 spellId) override;
        void OnResetTalents(Player* player, uint32 cost) override;

        // M8: gossip-driven unlock + switch on the Talent Specialist NPC.
        bool OnPreGossipHello(Player* player, Creature* creature) override;
        bool OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 action, const std::string& code, uint32 gossipListId) override;

        // M7: chat command surface (.dualspec / .dualspec 1|2 / .dualspec buy
        // / .dualspec grant) plus the M3 debug hook removed at M7.
        std::vector<ModuleChatCommand>* GetCommandTable() override;

    private:
        std::vector<ModuleChatCommand> commandTable;
    };
}

#endif
