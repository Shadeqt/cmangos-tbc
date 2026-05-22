#include "VanillarestoreModuleConfig.h"

namespace cmangos_module
{
    VanillarestoreModuleConfig::VanillarestoreModuleConfig()
    : ModuleConfig("vanillarestore.conf")
    , enabled(false)
    , map530Gate_enable(false)
    , map530Gate_allowedZones("")
    {
    }

    bool VanillarestoreModuleConfig::OnLoad()
    {
        enabled = config.GetBoolDefault("VanillaRestore.Enable", false);
        map530Gate_enable = config.GetBoolDefault("VanillaRestore.Map530Gate.Enable", false);
        map530Gate_allowedZones = config.GetStringDefault(
            "VanillaRestore.Map530Gate.AllowedZones",
            "3430,3433,3487,3524,3525,3557");
        return true;
    }
}
