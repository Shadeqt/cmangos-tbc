# VanillaRestore

Local cmangos-modules module hosting content reverts that pull TBC 2.4.3
behavior back toward vanilla 1.12.1.

Currently contains:

- `sql/install/world/001_revert_2.3.0_creature_rank_and_hp.sql` — restores
  pre-2.3.0 `Rank` and `HealthMultiplier` for 297 creatures whose values
  shifted between vanilla 1.12.1 (vmangos truth) and TBC 2.4.3 (cmangos
  truth). Generated from `zzDocumentation/zzResearch/2.3.0/data/creature_rank_changes.csv`.

The C++ class is a placeholder — no hooks are overridden. The module exists
purely to bundle the SQL with a togglable config flag (`VanillaRestore.Enable`)
and a corresponding uninstall path. Code overrides may be added later as
research surfaces gameplay (non-data) divergences worth reverting.

## Install

Built when configured with `-DBUILD_MODULES=ON -DBUILD_MODULE_VANILLARESTORE=ON`.
The Dockerfile bakes both flags in on the `modules` branch, so a normal
`docker compose build` produces a binary with this module compiled in.

Apply the SQL to your world database (DB_WORLD, default `tbcmangos`) after
base + updates load:

```sh
mysql -u <user> -p<password> <world_db> \
    < src/modules/vanillarestore/sql/install/world/001_revert_2.3.0_creature_rank_and_hp.sql
```

The docker `db-import` flow on `master` already auto-discovers SQL placed
under `docker/custom-sql/`. Integrating module SQL auto-discovery into that
flow is separate work.

## Uninstall

`sql/uninstall/world/001_revert_2.3.0_creature_rank_and_hp.sql` is a stub —
generate the reverse UPDATEs from the CSV before relying on it.
