#!/bin/bash
# Entrypoint for cmangos mangosd and realmd containers.
# Renders configs from the .dist templates on first run, then exec's the CMD.

set -euo pipefail

CONF_DIR=/cmangos/dist/etc
REF_DIR=/cmangos/dist/etc.ref

: "${DB_HOST:=cm-database}"
: "${DB_PORT:=3306}"
: "${DB_USER:=mangos}"
: "${DB_PASSWORD:=mangos}"
: "${DB_REALMD:=tbcrealmd}"
: "${DB_WORLD:=tbcmangos}"
: "${DB_CHARACTERS:=tbccharacters}"
: "${DB_LOGS:=tbclogs}"

render() {
    local src="$1" dst="$2"
    [[ -f "$dst" ]] && return 0
    [[ -f "$src" ]] || return 0

    # cp -n: mangosd and realmd start in parallel and share this etc dir.
    # Without -n, both pass the existence check above, both call cp, and the
    # loser errors out with "File exists" under set -e. -n makes the loser
    # silently no-op while the winner writes.
    cp -n "$src" "$dst"
    local conn_realmd="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_REALMD}"
    local conn_world="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_WORLD}"
    local conn_chars="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_CHARACTERS}"
    local conn_logs="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_LOGS}"

    sed -i \
        -e "s|127.0.0.1;3306;mangos;mangos;tbcrealmd|${conn_realmd}|g" \
        -e "s|127.0.0.1;3306;mangos;mangos;tbcmangos|${conn_world}|g" \
        -e "s|127.0.0.1;3306;mangos;mangos;tbccharacters|${conn_chars}|g" \
        -e "s|127.0.0.1;3306;mangos;mangos;tbclogs|${conn_logs}|g" \
        -e "s|^DataDir = \".*\"|DataDir = \"/cmangos/dist/data\"|" \
        -e "s|^LogsDir = \".*\"|LogsDir = \"/cmangos/dist/logs\"|" \
        -e "s|^StrictVersionCheck *= *1|StrictVersionCheck = 0|" \
        "$dst"

    echo "rendered $dst"
}

render "$REF_DIR/mangosd.conf.dist" "$CONF_DIR/mangosd.conf"
render "$REF_DIR/realmd.conf.dist"  "$CONF_DIR/realmd.conf"

# Module configs: no DB/path substitutions needed, but render() handles the
# "copy only if missing" semantics correctly for them too.
render "$REF_DIR/achievements.conf.dist"   "$CONF_DIR/achievements.conf"
render "$REF_DIR/dualspectbc.conf.dist"    "$CONF_DIR/dualspectbc.conf"
render "$REF_DIR/barber.conf.dist"         "$CONF_DIR/barber.conf"
render "$REF_DIR/trainingdummies.conf.dist" "$CONF_DIR/trainingdummies.conf"

exec "$@"
