# VanillaRestore

Local cmangos-modules module hosting content reverts that pull TBC 2.4.3
behavior back toward vanilla 1.12.1.

Currently contains:

- `sql/install/world/001_revert_2.3.0_creature_rank_and_hp_world.sql` —
  restores pre-2.3.0 `Rank` and `HealthMultiplier` for 267 creatures
  whose values shifted between vanilla 1.12.1 (vmangos truth) and TBC
  2.4.3 (cmangos truth). Generated from
  `zzDocumentation/Research/TBC/data/creature_rank_changes.csv`.

The C++ class is a placeholder — no hooks are overridden beyond the
runtime gate listed below. The module exists primarily to bundle the
SQL reverts with a togglable config flag (`VanillaRestore.Enable`),
with code overrides added as research surfaces gameplay (non-data)
divergences worth reverting.

Runtime gates currently in place:

- `src/features/Map530Gate.cpp` — blocks non-GM teleport to Outland
  outside whitelisted starter zones (Eversong, Ghostlands, Silvermoon,
  Azuremyst, Bloodmyst, The Exodar, Isle of Quel'Danas).

## Install

Built when configured with `-DBUILD_MODULES=ON -DBUILD_MODULE_VANILLARESTORE=ON`.
The Dockerfile bakes both flags in on the `modules` branch, so a normal
`docker compose build` produces a binary with this module compiled in.

The Docker `db-import` flow auto-discovers SQL placed under
`sql/install/<target>/` for each module on every `docker compose up`,
where `<target>` ∈ `{world, characters, realmd, logs}`. Files within a
module run in alphabetical order (use `001_`, `002_` prefixes to control
sequencing). The `_world.sql` filename suffix is a convention for
clarity — routing is determined by the `world/` directory placement,
not the suffix.

For manual one-shot application, apply each file with `mysql` against
DB_WORLD (default `tbcmangos`) after base + updates load:

```sh
mysql -u <user> -p<password> <world_db> \
    < src/modules/vanillarestore/sql/install/world/001_revert_2.3.0_creature_rank_and_hp_world.sql
```

## Uninstall

`sql/uninstall/world/` mirrors each install file with its reverse —
re-applies the TBC 2.4.3 stock values, undoing the vanilla revert.
Apply manually against DB_WORLD if removing the module.

- `001_revert_2.3.0_creature_rank_and_hp_world.sql` — restores TBC
  Rank + HealthMultiplier on the same 267 creatures (21 grouped UPDATEs
  by `(tbc_rank, tbc_HealthMultiplier)` histogram desc).

## Research provenance

All reverts in this module are sourced from per-table research docs
under `zzDocumentation/Research/TBC/` with grouped diff queries against
the `wow-dbc` cross-version reference DB. See the master plan at
`zzDocumentation/Research/TBC/vanilla_restore_plan_v1.md` for the
10-domain server-side rollout sequence + open cross-domain decisions
(D1-D6).
