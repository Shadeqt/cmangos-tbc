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

        // When true, the second spec is granted automatically (no cost, no
        // trainer visit) the first time the player is at-or-above minLevel.
        // Fires from OnGiveLevel (catches the crossing live) and from
        // OnLoadFromDB (catches existing characters already past minLevel
        // when the flag is flipped on). When autoGrant=true the gossip
        // option and the gossip cost effectively never fire — minLevel is
        // the same gate for both paths and auto-grant wins.
        bool autoGrant;
    };
}
