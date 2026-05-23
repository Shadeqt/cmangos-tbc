#include "DualspectbcModuleConfig.h"

namespace cmangos_module
{
    DualspectbcModuleConfig::DualspectbcModuleConfig()
    : ModuleConfig("dualspectbc.conf")
    , enabled(false)
    , minLevel(40)
    , cost(10000000)
    , autoGrant(false)
    {
    }

    bool DualspectbcModuleConfig::OnLoad()
    {
        enabled   = config.GetBoolDefault("DualSpec.Enable", false);
        minLevel  = config.GetIntDefault ("DualSpec.MinLevel", 40);
        cost      = config.GetIntDefault ("DualSpec.Cost", 10000000);
        autoGrant = config.GetBoolDefault("DualSpec.AutoGrant", false);
        return true;
    }
}
