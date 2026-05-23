# DualSpec

WotLK-style dual talent specialization for cmangos-tbc (2.4.3). A
level-40+ character can purchase a second talent build for 1000g and
switch between them at runtime — live swap, no relog.

Mirrors AzerothCore / WotLK retail data model and activation flow as
faithfully as the TBC 2.4.3 client and cmangos-tbc API permit.

## Design

- Architecture and rationale: `zzDocumentation/Research/TBC/dualspec_module/dualspec_research.md`
- Milestone plan: `zzDocumentation/Research/TBC/dualspec_module/dualspec_plan.md`

Key points:
- **Live swap**, no force-relog. Talents, spec-tagged spells, and action
  bars are swapped in place via the existing learn/unlearn +
  `SMSG_INITIAL_SPELLS` + `SMSG_ACTION_BUTTONS` packet surface, with
  per-spell packets suppressed (`addSpell(..., learning=false)` /
  `removeSpell(..., sendUpdate=false, learn_low_rank=false)`) and a
  single bulk reconcile at the end.
- **Schema** follows AzerothCore canonical names:
  `character_talent.specMask`, `character_spell.specMask`,
  `character_action.spec`, `characters.activeTalentGroup`,
  `characters.talentGroupsCount`. Module-owned tables that mirror retail
  shape, not `custom_dualspec_*`.
- **Three input paths** converge on the module's internal `ActivateSpec`:
  gossip option (NPC), chat command (`.dualspec 1|2`), and addon channel
  message (`DUALSPEC ACTIVATE <n>` — phase 2 only).
- **Switch gating**: not in combat, casting, dueling, BG/arena
  in-progress, on taxi, shapeshifted, or dead.

## Status

Scaffold only. Hook stubs in place; no behavior. Milestone progression:

| # | Milestone | Status |
|---|---|---|
| M1 | Schema + DB migration + existing-character backfill | not started |
| M2 | Player state load/save via hooks; LearnTalent integration | not started |
| M3 | `ActivateSpec` live swap (incl. debug `.dualspec_debug` hook) | not started |
| M4 | Gating predicate | not started |
| M5 | Spec-aware `resetTalents` | not started |
| M6 | `UpdateSpecCount` unlock primitive (transactional) | not started |
| M7 | Chat command surface (`.dualspec` family) | not started |
| M8 | Gossip integration + master enable switch wiring | not started |
| M9 | Addon UX layer | deferred |

## Install

Built when configured with `-DBUILD_MODULES=ON -DBUILD_MODULE_DUALSPEC=ON`.
The Dockerfile on `feature/dualspec` flips both flags on by default, so
`docker compose build` produces a binary with this module compiled in.

SQL bundled under `sql/install/characters/` is auto-applied on every
`docker compose up` per the cmangos-modules framework's db-import flow,
with sentinel-table gating (`character_talent`) so existing player
state is not clobbered on subsequent restarts.

The master enable switch lives in `dualspec.conf`. `DualSpec.Enable = 0`
ships disabled by default; flip to `1` to activate all entrypoints.

## Uninstall

`sql/uninstall/characters/` mirrors each install file with its reverse
(drop `character_talent`, drop `character_spell.specMask`, restore
`character_action` PK to `(guid, button)`, drop the new `characters`
columns). Apply manually if removing the module.
