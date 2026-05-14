# vmangos Docker

Multi-stage docker setup for vmangos: builds `mangosd` + `realmd` + extractors,
runs them against a managed MySQL instance, bootstraps schemas + world dump,
and optionally extracts client data from a 1.12 WoW install.

## Prerequisites

- Docker Desktop with Compose v2
- For client-data extraction: a WoW 1.12 client install on the host

## First run

```sh
cd docker/
cp .env.example .env          # adjust ports / passwords / client path
docker compose build          # builds mangosd, realmd, db-import, extractor (~10-30 min cold)
docker compose up -d          # boots db, runs db-import, starts realmd + mangosd
```

The `vm-db-import` one-shot:
1. Creates `realmd`, `mangos`, `characters`, `logs` databases
2. Imports the schemas from `sql/*.sql`
3. Downloads the latest world dump from
   [vmangos/core releases](https://github.com/vmangos/core/releases/tag/db_latest)
4. Applies migrations from `sql/migrations/`

It's idempotent — already-imported databases are skipped on subsequent runs.

## Client data

mangosd needs `dbc/`, `maps/`, `vmaps/`, `mmaps/` extracted from a real WoW 1.12
client. Point `VM_CLIENT_DIR` in `.env` at the client root (the folder
containing `Wow.exe` and `Data/`), then:

```sh
docker compose --profile extractor run --rm vm-extractor
```

Output goes to the `vm-client-data` named volume, which `vm-mangosd` mounts
read-only at `/vmangos/dist/data`. mmap generation takes a while — go get
lunch.

## Default ports

| Port | Service        | Notes |
| ---- | -------------- | ----- |
| 3307 | MySQL          | Offset from acore (3306) |
| 3725 | realmd (auth)  | Set `127.0.0.1:3725` in client `realmlist.wtf` |
| 8086 | mangosd (world) | Advertised via the realm row in the `realmd` DB |

All overridable via `.env`. Defaults are chosen to coexist with acore on the
same host.

## Creating an admin account

mangosd reads commands from stdin while running. Attach and create:

```sh
docker compose attach vm-mangosd
# at the mangos> prompt:
account create admin admin
account set gmlevel admin 3
# Ctrl-P Ctrl-Q to detach
```

## Common operations

```sh
docker compose logs -f vm-mangosd      # tail world log
docker compose down                     # stop, keep DB and client data
docker compose down -v                  # nuke everything (DB + extracted data)
docker compose build --build-arg CACHEBUST=$(date +%s) vm-mangosd  # force rebuild
```

## Layout

```
docker/
├── Dockerfile         # multi-stage: build → runtime → mangosd / realmd / db-import / extractor
├── docker-compose.yml
├── .env.example
├── entrypoint.sh      # renders .conf.dist → .conf with env values
├── db-import.sh       # bootstraps the 4 databases
└── extractor.sh       # runs MapExtractor + vmap + mmap pipeline
```
