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

    void VanillarestoreModule::OnInitialize()
    {
        const VanillarestoreModuleConfig* cfg = GetConfig();
        map530Gate.Configure(cfg->map530Gate_enable, cfg->map530Gate_allowedZones);
    }

    bool VanillarestoreModule::OnPreTeleport(Player* player, uint32 mapid, float x, float y, float z)
    {
        return map530Gate.OnPreTeleport(player, mapid, x, y, z);
    }
}
