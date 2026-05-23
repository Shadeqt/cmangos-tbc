#pragma once
#include "ModuleConfig.h"

namespace cmangos_module
{
    class DualspectbcModuleConfig : public ModuleConfig
    {
    public:
        DualspectbcModuleConfig();
        bool OnLoad() override;

    public:
        // Master switch. When false: gossip option hidden, chat commands
        // rejected, addon-channel handler short-circuits. Existing
        // character_talent / talentGroupsCount data preserved.
        bool enabled;

        // Minimum character level to purchase a second talent spec.
        // WotLK retail default = 40.
        uint32 minLevel;

        // Purchase cost in copper. 10000000 = 1000 gold (WotLK default).
        uint32 cost;
    };
}
