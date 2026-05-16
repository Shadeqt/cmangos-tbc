#ifndef CMANGOS_MODULE_VANILLARESTORE_H
#define CMANGOS_MODULE_VANILLARESTORE_H

#include "Module.h"
#include "VanillarestoreModuleConfig.h"

namespace cmangos_module
{
    class VanillarestoreModule : public Module
    {
    public:
        VanillarestoreModule();
        const VanillarestoreModuleConfig* GetConfig() const override;
    };
}

#endif
