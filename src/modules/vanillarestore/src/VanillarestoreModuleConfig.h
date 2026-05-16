#pragma once
#include "ModuleConfig.h"

namespace cmangos_module
{
    class VanillarestoreModuleConfig : public ModuleConfig
    {
    public:
        VanillarestoreModuleConfig();
        bool OnLoad() override;

    public:
        bool enabled;
    };
}
