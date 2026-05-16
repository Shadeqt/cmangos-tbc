#include "VanillarestoreModule.h"

namespace cmangos_module
{
    VanillarestoreModule::VanillarestoreModule()
    : Module("VanillaRestore", new VanillarestoreModuleConfig())
    {
    }

    const VanillarestoreModuleConfig* VanillarestoreModule::GetConfig() const
    {
        return (VanillarestoreModuleConfig*)Module::GetConfig();
    }
}
