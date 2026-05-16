#include "VanillarestoreModuleConfig.h"

namespace cmangos_module
{
    VanillarestoreModuleConfig::VanillarestoreModuleConfig()
    : ModuleConfig("vanillarestore.conf")
    , enabled(false)
    {
    }

    bool VanillarestoreModuleConfig::OnLoad()
    {
        enabled = config.GetBoolDefault("VanillaRestore.Enable", false);
        return true;
    }
}
