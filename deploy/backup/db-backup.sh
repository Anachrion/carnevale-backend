#!/usr/bin/env bash
#
# Nightly off-site Postgres backup for carnevale_backend -> Cloudflare R2.
#
# Runs ON THE PRODUCTION BOX. Installed by bin/install-db-backups and fired by the
# carnevale-db-backup.timer systemd timer (03:00 UTC). Player data -- accounts, lists,
# games -- lives only on this box's single volume; this is the one thing that gets it
# off the box. See docs/DATA_AND_BACKUPS.md.
#
# What it does, once a night:
#   1. pg_dump the production DB in custom format (-Fc, already compressed) straight out
#      of the Postgres accessory container. No DB password is stored on the host: it is
#      read from the container's own env, so this keeps working if the password rotates.
#   2. Sanity-check the dump (non-empty, starts with the "PGDMP" magic bytes) so a broken
#      or truncated dump never gets uploaded over good history.
#   3. rclone copy it to R2 under daily/, and on Sundays also under weekly/.
#   4. Prune to 7 daily + 4 weekly. Files are date-named, so a lexical sort is chronological.
#
# Safe to re-run: a second run the same day just re-uploads today's file.

set -euo pipefail

# --- config (override via the systemd unit's Environment= if the box ever changes) ---
DB_CONTAINER="${DB_CONTAINER:-carnevale_backend-db}"
REMOTE="${BACKUP_REMOTE:-r2:carnevale-backups}"
export RCLONE_CONFIG="${RCLONE_CONFIG:-/root/.config/rclone/rclone.conf}"
KEEP_DAILY="${KEEP_DAILY:-7}"
KEEP_WEEKLY="${KEEP_WEEKLY:-4}"
# -------------------------------------------------------------------------------------

log() { printf '%s  %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*"; }
die() { log "ERROR: $*" >&2; exit 1; }

command -v rclone >/dev/null || die "rclone not installed"
docker inspect "$DB_CONTAINER" >/dev/null 2>&1 || die "container $DB_CONTAINER not found"

stamp="$(date -u +%F)"                 # e.g. 2026-07-21
filename="carnevale-${stamp}.dump"

tmp="$(mktemp -t carnevale-backup.XXXXXX.dump)"
trap 'rm -f "$tmp"' EXIT

log "Dumping ${DB_CONTAINER}"
# Read DB coords + password from the container's own env. -Fc is a compressed archive.
docker exec "$DB_CONTAINER" sh -c \
  'PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -U "$POSTGRES_USER" -Fc "$POSTGRES_DB"' > "$tmp"

# Custom-format dumps begin with the ASCII magic "PGDMP".
[ -s "$tmp" ] || die "dump is empty"
[ "$(head -c 5 "$tmp")" = "PGDMP" ] || die "dump is missing PGDMP magic bytes -- refusing to upload"
log "Dump OK ($(du -h "$tmp" | cut -f1))"

log "Uploading ${REMOTE}/daily/${filename}"
rclone copyto "$tmp" "${REMOTE}/daily/${filename}"

# ISO weekday 7 == Sunday -> also keep a weekly copy.
if [ "$(date -u +%u)" = "7" ]; then
  log "Sunday -> also ${REMOTE}/weekly/${filename}"
  rclone copyto "$tmp" "${REMOTE}/weekly/${filename}"
fi

prune() {  # $1 = subdir, $2 = keep count
  local dir="$1" keep="$2" victims
  victims="$(rclone lsf --files-only "${REMOTE}/${dir}/" 2>/dev/null | sort | head -n "-${keep}")" || true
  [ -n "$victims" ] || return 0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    log "Pruning ${dir}/${f}"
    rclone deletefile "${REMOTE}/${dir}/${f}"
  done <<< "$victims"
}

prune daily  "$KEEP_DAILY"
prune weekly "$KEEP_WEEKLY"

log "Done."
