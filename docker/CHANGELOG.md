# Changelog

Newest entries on top within each section.

---

## Game mechanics

### 2026-05-15 — Block Outland (map 530) access

- Added an early return in `Player::GetAreaTriggerLockStatus()` (`src/game/Entities/Player.cpp`) that rejects any `at->target_mapId == 530` with `AREA_LOCKSTATUS_INSUFFICIENT_EXPANSION`. GMs bypass.

### 2026-05-14 — Cap player level at 60

- Changed `MaxPlayerLevel` from `70` to `60` in `docker/etc/mangosd.conf`.

---

## Technical

### 2026-05-16 — Install cmangos-modules and wire module SQL into DB bootstrap

- Imported flekz `patches/tbc.patch` adding the cmangos-modules hook system (~80 hooks across player/combat/item/quest/BG/AH/group lifecycle).
- Baked `-DBUILD_MODULES=ON` into the docker build stage; binary now links the modules library and registers any module subclasses via `ModuleMgr`.
- Added `VanillaRestore` placeholder module under `src/modules/vanillarestore/` — empty `Module` subclass holding the 2.3.0 creature `Rank`/`HealthMultiplier` revert under `sql/install/world/`. Bundled with togglable `VanillaRestore.Enable` config flag.
- Added a local-modules block to `src/CMakeLists.txt` so any `src/modules/<name>/` outside upstream `modules.conf` gets `add_subdirectory`'d before `src/game/CMakeLists.txt`'s `file(GLOB)` scan tries to link against it.
- Extended `docker/db-import.sh` to apply every module's `sql/install/{world,characters,realmd,logs}/*.sql` after source-tree migrations; files run in alphabetical order within a module, modules in directory order. Files must be self-idempotent.
- Added `COPY src/modules` to the db-import Dockerfile stage so the script can iterate module SQL trees.
- Moved `001_revert_2.3.0_creature_rank_and_hp_world.sql` from `docker/custom-sql/` into the VanillaRestore module. `docker/custom-sql/` remains as an escape hatch for ad-hoc SQL.

### 2026-05-16 — Realmlist port → 8085

- `docker/db-import.sh` seed now points clients at `127.0.0.1:8085` (was `8087`) after the acore/cmangos port swap put cmangos-tbc on the default WoW world port.

### 2026-05-15 — Default account expansion to 1

- Set `account.expansion` schema default to `1` in `tbcrealmd` and backfilled existing rows. New accounts get TBC access without `.account set addon`.
