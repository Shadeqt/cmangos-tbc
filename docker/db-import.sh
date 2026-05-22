#!/bin/bash
# Bootstrap cmangos-tbc databases on first run.
#
# Downloads tbc-all-db.zip from cmangos/tbc-db latest (contains schemas +
# populated data for all four DBs), creates the schemas, imports the dumps,
# applies migrations from sql/updates/<db>/. Idempotent — populated DBs
# are skipped on subsequent runs.
#
# After the upstream import:
#   - applies migrations from sql/updates/<db>/ (per-DB subdir layout)
#   - applies SQL bundled with cmangos-modules-style modules at
#     /cmangos/modules/*/sql/install/<target>/*.sql, where <target> is one of
#     world/characters/realmd/logs; files within a module run in alphabetical
#     order, modules themselves run in directory order
#   - applies user-supplied SQL from /cmangos/custom-sql/ on every run
#     (suffix-tagged: *_world.sql, *_realmd.sql, *_characters.sql, *_logs.sql;
#     expected to be self-idempotent)
#   - seeds/refreshes realmlist row id=1
#
# Structure is kept parallel to vmangos-core/docker/db-import.sh so changes
# can be mirrored across both projects.

set -euo pipefail

: "${DB_HOST:=cm-database}"
: "${DB_PORT:=3306}"
: "${DB_ROOT_PASSWORD:?DB_ROOT_PASSWORD must be set}"
: "${DB_USER:=mangos}"
: "${DB_PASSWORD:=mangos}"
: "${DB_REALMD:=tbcrealmd}"
: "${DB_WORLD:=tbcmangos}"
: "${DB_CHARACTERS:=tbccharacters}"
: "${DB_LOGS:=tbclogs}"
: "${WORLD_DUMP_URL:=}"
: "${REALM_ADDRESS:=127.0.0.1}"
: "${REALM_PORT:=8085}"

SQL_DIR=/cmangos/sql
CUSTOM_SQL_DIR=/cmangos/custom-sql
MODULES_DIR=/cmangos/modules

mysql_root() {
    mysql --host="$DB_HOST" --port="$DB_PORT" --user=root --password="$DB_ROOT_PASSWORD" "$@"
}

mysql_user() {
    mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASSWORD" "$@"
}

log() { echo "[db-import] $*"; }

log "creating databases and user"
mysql_root <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_REALMD}\`     DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS \`${DB_WORLD}\`      DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS \`${DB_CHARACTERS}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS \`${DB_LOGS}\`       DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_REALMD}\`.*     TO '${DB_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${DB_WORLD}\`.*      TO '${DB_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${DB_CHARACTERS}\`.* TO '${DB_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${DB_LOGS}\`.*       TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

table_count() {
    mysql_root --skip-column-names --silent \
        -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$1';"
}

need_import=0
for db in "$DB_REALMD" "$DB_WORLD" "$DB_CHARACTERS" "$DB_LOGS"; do
    if [[ "$(table_count "$db")" -eq 0 ]]; then
        need_import=1
        break
    fi
done

if [[ "$need_import" -eq 1 ]]; then
    if [[ -z "$WORLD_DUMP_URL" ]]; then
        log "resolving latest db zip from cmangos/tbc-db latest"
        WORLD_DUMP_URL=$(curl -fsSL https://api.github.com/repos/cmangos/tbc-db/releases/latest \
            | jq -r '.assets[] | select(.name == "tbc-all-db.zip") | .browser_download_url' \
            | head -1)
        if [[ -z "$WORLD_DUMP_URL" ]]; then
            log "ERROR: could not resolve tbc-all-db.zip URL"
            exit 1
        fi
    fi

    log "downloading $WORLD_DUMP_URL"
    zip_path=/tmp/cmangos-db.zip
    curl -fsSL "$WORLD_DUMP_URL" -o "$zip_path"
    log "extracting $(du -h "$zip_path" | cut -f1) zip"
    unzip -q -o "$zip_path" -d /tmp/cmangos-db
    rm -f "$zip_path"

    declare -A db_for_file=(
        [tbcrealmd.sql]="$DB_REALMD"
        [tbcmangos.sql]="$DB_WORLD"
        [tbccharacters.sql]="$DB_CHARACTERS"
        [tbclogs.sql]="$DB_LOGS"
    )

    for fname in "${!db_for_file[@]}"; do
        target_db="${db_for_file[$fname]}"
        src="/tmp/cmangos-db/$fname"
        if [[ ! -f "$src" ]]; then
            log "WARN: $fname missing from archive"
            continue
        fi
        if [[ "$(table_count "$target_db")" -gt 0 ]]; then
            log "skip $fname: $target_db already populated"
            continue
        fi
        log "importing $fname ($(du -h "$src" | cut -f1)) into $target_db"
        pv "$src" | mysql_user "$target_db"
    done

    rm -rf /tmp/cmangos-db
else
    log "all four DBs already have tables — skipping dump download"
fi

# Apply migrations shipped with the source tree. cmangos splits updates by DB
# into separate folders; each file wraps its body in `add_migration` for
# idempotency.
declare -A updates_for_db=(
    [realmd]="$DB_REALMD"
    [mangos]="$DB_WORLD"
    [characters]="$DB_CHARACTERS"
    [logs]="$DB_LOGS"
)

total_applied=0
for subdir in "${!updates_for_db[@]}"; do
    target_db="${updates_for_db[$subdir]}"
    dir="$SQL_DIR/updates/$subdir"
    [[ -d "$dir" ]] || continue
    for migration in $(ls "$dir" | grep -E '\.sql$' | sort); do
        mysql_user "$target_db" < "$dir/$migration" 2>/dev/null || true
        total_applied=$((total_applied + 1))
    done
done
log "applied $total_applied source-tree migration files"

# Used by the modules loop below and the playerbots block further down.
table_exists() {
    local n
    n=$(mysql_user --skip-column-names --silent \
        -e "SELECT COUNT(*) FROM information_schema.tables \
            WHERE table_schema='$1' AND table_name='$2';")
    [[ "$n" -gt 0 ]]
}

# Apply SQL bundled with cmangos-modules-style modules. Each module under
# /cmangos/modules/ may ship sql/install/<target>/*.sql where <target> is one
# of world/characters/realmd/logs. Files within a module run in alphabetical
# order (use 001_, 002_ prefixes to control sequencing). Modules themselves
# run in directory order — modules must be order-independent. Files are
# expected to be self-idempotent (UPDATE…WHERE, INSERT IGNORE, REPLACE INTO):
# they re-run on every container start. The literal name `modules` is skipped
# because it's the cmangos-modules main repo populated by FetchContent, not
# a module itself.
if [[ -d "$MODULES_DIR" ]]; then
    declare -A module_db_for_target=(
        [world]="$DB_WORLD"
        [characters]="$DB_CHARACTERS"
        [realmd]="$DB_REALMD"
        [logs]="$DB_LOGS"
    )

    # Per-module characters-side gates: these modules ship DROP TABLE +
    # CREATE TABLE for the characters DB. Without gating, every container
    # restart would wipe player progress. Skip the characters install
    # once the sentinel table exists.
    declare -A module_characters_sentinel=(
        [achievements]="character_achievement_progress"
        [dualspec]="custom_dualspec_talent"
    )

    module_applied=0
    for module_path in "$MODULES_DIR"/*/; do
        module_name=$(basename "$module_path")
        [[ "$module_name" == "modules" ]] && continue
        for target in "${!module_db_for_target[@]}"; do
            install_dir="${module_path}sql/install/${target}"
            [[ -d "$install_dir" ]] || continue
            target_db="${module_db_for_target[$target]}"
            if [[ "$target" == "characters" ]] && [[ -n "${module_characters_sentinel[$module_name]:-}" ]]; then
                sentinel="${module_characters_sentinel[$module_name]}"
                if table_exists "$DB_CHARACTERS" "$sentinel"; then
                    log "skip modules/$module_name/sql/install/characters: sentinel '$sentinel' exists in $DB_CHARACTERS"
                    continue
                fi
            fi
            for f in $(ls "$install_dir" 2>/dev/null | grep -E '\.sql$' | sort); do
                log "applying modules/$module_name/sql/install/$target/$f → $target_db"
                mysql_user "$target_db" < "$install_dir/$f"
                module_applied=$((module_applied + 1))
            done
        done
    done
    log "applied $module_applied module install SQL files"
fi

# ---------------------------------------------------------------------------
# Playerbots SQL bootstrap — run-once per DB, gated by sentinel-table existence.
#
# cmangos/playerbots SQL uses DROP TABLE IF EXISTS + CREATE TABLE + plain
# INSERT INTO — re-running would wipe persistent bot state (random_bots,
# db_store, cache, custom_strategy) and waste ~45 MB of lookup-table inserts.
# We apply each DB's bundle once, gated by sentinel-table existence.
# To re-seed a side: DROP its sentinel table and restart this container.
#
# The SQL tree is copied into the db-import image from the build stage's
# FetchContent output (see Dockerfile: COPY --from=build .../PlayerBots/sql).
# ---------------------------------------------------------------------------
PLAYERBOTS_SQL=/cmangos/modules/PlayerBots/sql

# table_exists is defined earlier (above the modules loop).

apply_dir() {
    local dir="$1" target_db="$2"
    [[ -d "$dir" ]] || return 0
    for f in $(ls "$dir" | grep -E '\.sql$' | sort); do
        log "  applying $(basename "$dir")/$f → $target_db"
        mysql_user "$target_db" < "$dir/$f"
    done
}

if [[ -d "$PLAYERBOTS_SQL" ]]; then
    if table_exists "$DB_WORLD" "ai_playerbot_named_location"; then
        log "playerbots world SQL already applied — skipping"
    else
        log "seeding playerbots world DB (~45 MB, takes a couple of minutes)"
        apply_dir "$PLAYERBOTS_SQL/world/tbc" "$DB_WORLD"
        apply_dir "$PLAYERBOTS_SQL/world"     "$DB_WORLD"
    fi

    if table_exists "$DB_CHARACTERS" "ai_playerbot_random_bots"; then
        log "playerbots characters SQL already applied — skipping"
    else
        log "seeding playerbots characters DB"
        apply_dir "$PLAYERBOTS_SQL/characters" "$DB_CHARACTERS"
    fi
else
    log "playerbots SQL not present at $PLAYERBOTS_SQL — skipping"
fi

# Apply user-supplied SQL from the bind-mounted custom-sql/ directory. Runs
# on every startup; files are expected to be self-idempotent.
if [[ -d "$CUSTOM_SQL_DIR" ]]; then
    applied=0
    for f in $(ls "$CUSTOM_SQL_DIR" 2>/dev/null | grep -E '\.sql$' | sort); do
        case "$f" in
            *_world.sql)      target_db="$DB_WORLD" ;;
            *_realmd.sql)     target_db="$DB_REALMD" ;;
            *_logon.sql)      target_db="$DB_REALMD" ;;
            *_characters.sql) target_db="$DB_CHARACTERS" ;;
            *_logs.sql)       target_db="$DB_LOGS" ;;
            *)
                log "skip $f: no _<db>.sql suffix"
                continue
                ;;
        esac
        log "applying custom-sql/$f → $target_db"
        mysql_user "$target_db" < "$CUSTOM_SQL_DIR/$f"
        applied=$((applied + 1))
    done
    log "applied $applied custom-sql files"
fi

# Realmlist row 1 — UPDATE-then-INSERT-IGNORE makes this safe whether or not
# the upstream dump pre-populated the row. After the acore/cmangos port swap
# cmangos-tbc holds the default WoW world port 8085 on the host.
log "seeding realmlist id=1 → ${REALM_ADDRESS}:${REALM_PORT}"
mysql_user "$DB_REALMD" <<SQL
UPDATE realmlist SET name='cmangos', address='${REALM_ADDRESS}', port=${REALM_PORT}, realmbuilds='8606' WHERE id=1;
INSERT IGNORE INTO realmlist (id, name, address, port, icon, realmflags, timezone, allowedSecurityLevel, population, realmbuilds)
VALUES (1, 'cmangos', '${REALM_ADDRESS}', ${REALM_PORT}, 1, 0, 1, 0, 0, '8606');
SQL

log "done"
