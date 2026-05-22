#ifndef CMANGOS_MODULE_VANILLARESTORE_MAP530_GATE_H
#define CMANGOS_MODULE_VANILLARESTORE_MAP530_GATE_H

#include "Platform/Define.h"

#include <string>
#include <unordered_set>

class Player;

namespace cmangos_module
{
    class Map530Gate
    {
    public:
        Map530Gate();

        void Configure(bool enabled, const std::string& allowedZonesCsv);

        // Returns true to block the teleport. Sends the appropriate
        // SendTransferAborted packet to the client when blocking.
        bool OnPreTeleport(Player* player, uint32 mapid, float x, float y, float z) const;

    private:
        bool enabled;
        std::unordered_set<uint32> allowedZones;
    };
}

#endif
