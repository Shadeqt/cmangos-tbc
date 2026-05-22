#pragma once
#include "ModuleConfig.h"

#include <string>

namespace cmangos_module
{
    class VanillarestoreModuleConfig : public ModuleConfig
    {
    public:
        VanillarestoreModuleConfig();
        bool OnLoad() override;

    public:
        bool enabled;

        // Map530Gate
        bool map530Gate_enable;
        std::string map530Gate_allowedZones;
    };
}
