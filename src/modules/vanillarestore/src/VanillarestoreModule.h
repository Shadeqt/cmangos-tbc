#ifndef CMANGOS_MODULE_VANILLARESTORE_H
#define CMANGOS_MODULE_VANILLARESTORE_H

#include "Module.h"
#include "VanillarestoreModuleConfig.h"
#include "features/Map530Gate.h"

namespace cmangos_module
{
    class VanillarestoreModule : public Module
    {
    public:
        VanillarestoreModule();
        const VanillarestoreModuleConfig* GetConfig() const override;

        void OnInitialize() override;
        bool OnPreTeleport(Player* player, uint32 mapid, float x, float y, float z) override;

    private:
        Map530Gate map530Gate;
    };
}

#endif
