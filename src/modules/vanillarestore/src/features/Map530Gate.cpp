#include "Map530Gate.h"

#include "Entities/Player.h"
#include "Maps/GridMap.h"
#include "Module.h"
#include "Server/WorldSession.h"

namespace cmangos_module
{
    Map530Gate::Map530Gate()
    : enabled(false)
    {
    }

    void Map530Gate::Configure(bool enabledIn, const std::string& allowedZonesCsv)
    {
        enabled = enabledIn;
        allowedZones.clear();
        for (const std::string& token : helper::SplitString(allowedZonesCsv, ","))
        {
            if (helper::IsValidNumberString(token))
                allowedZones.insert(static_cast<uint32>(std::stoul(token)));
        }
    }

    bool Map530Gate::OnPreTeleport(Player* player, uint32 mapid, float x, float y, float z) const
    {
        if (!enabled || mapid != 530 || player->IsGameMaster())
            return false;

        const uint32 targetZone = sTerrainMgr.GetZoneId(530, x, y, z);
        if (allowedZones.count(targetZone))
            return false;

        player->GetSession()->SendTransferAborted(mapid, TRANSFER_ABORT_INSUF_EXPAN_LVL, 1);
        return true;
    }
}
