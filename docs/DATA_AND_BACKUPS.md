# Data, source of truth, and backups

Which copy of a thing wins when two disagree, what protects it if the server dies tonight, and what
does not. Written after the first production `catalog:export`, when the catalog stopped living on a
single box and nothing else changed.

The short version: **the catalog is safe in git, and the players' data is now backed up nightly,
off the box, to Cloudflare R2.** (Until 2026-07-20 the second half of that sentence read "the
players' data is not" — see [The nightly database backup](#the-nightly-database-backup) below.)

---

## Who is the source of truth

Three kinds of data, three different answers. Getting these confused is how you overwrite a month of
someone's work with a seed file.

### 1. Authored in production → the production database wins

Everything the backoffice can edit. A game creator signs in at `/backoffice`, edits a profile, and
that edit exists **only in the production Postgres** until it is snapshotted:

- profiles (stats, keywords, abilities)
- weapons and special rules (shared records)
- card references (the cards the app downloads)
- illustration records (which art, and how it is framed: offsets, zoom, flip)
- **uploaded art** — illustrations replaced through the backoffice, stored as Active Storage blobs

Nothing in git is authoritative for these. `db/seeds/*.rb` looks like it is, but it is only the
*genesis* data — what the catalog was on day one. Production has moved on.

### 2. Authored in git → the repository wins

The backoffice cannot edit these, so they are hand-written and version-controlled:

- rulebook data: `db/seeds/abilities.rb`, `spells.rb`, `scenarios.rb`, `equipment.rb`, `agendas.rb`
- the **committed illustrations**: `app/assets/images/illustrations/<faction>/*.png` (~375 files,
  89 MB, in git LFS) — the art every seeded profile still uses
- the card template: `app/views/backoffice/profiles/card.html.erb`, `public/card-template/*`
- the code

An illustration has two possible sources: the committed asset named by `path`, or an uploaded blob.
**The upload wins when both exist.** So git holds the art until someone replaces a piece of it in the
backoffice, and from that moment production holds the newer copy.

### 3. Derived → nobody, regenerate it

- **`public/cards/*.png`** — the rendered card faces. Produced by *Publish cards*, from the catalog
  and the art. In production these live on a Docker volume (`carnevale_backend_cards`) that, after
  the first deploy, **masks the image's directory** — so a card image committed to git no longer
  reaches the server on deploy. Publish it on the server instead.
- **`internal_version` and the staleness digests** — render bookkeeping. Rebuilt by publishing.
  `catalog:export` deliberately does not carry them.

Losing derived data costs time, not information. Everything above can be rebuilt by publishing.

---

## What is backed up today

| Data | Where it lives in production | Backed up? |
|---|---|---|
| Catalog records | Postgres | **Yes** — `db/catalog/*.yml` in git, by hand |
| Uploaded art | `carnevale_backend_storage` volume | **Yes** — `db/catalog/blobs/` in git LFS, by hand (none uploaded yet) |
| Committed art | in the image, from git | **Yes** — it *is* git |
| Rendered cards | `carnevale_backend_cards` volume | **No** — but regenerable by publishing |
| **Users, lists, games** | Postgres | **Yes** — nightly `pg_dump` to Cloudflare R2 (see below) |

### The catalog snapshot

```
bin/catalog-snapshot
```

Exports the catalog inside the running production container, pulls `db/catalog/` back into the
working tree, and stops so a human can read the diff before committing it.

Two details it exists to get right, both easy to lose an afternoon to:

- `kamal app exec` **without `--reuse`** starts a *fresh* container, writes the export into it, and
  throws it away.
- A container's filesystem does not survive the next deploy, so the files must be pulled out
  immediately — over `tar`, so image bytes arrive intact.

It is safe to re-run: if production already matches what is committed, it says so and exits.

Run it **after any session of authoring in the production backoffice**, and commit the result. Until
you do, that work exists on exactly one disk.

### The nightly database backup

This is what protects the player data — accounts, gang lists, games in progress — that lives only on
the box's single Postgres volume. `catalog:export` protects the *catalog*, not the players; this
`pg_dump` protects everything.

**What runs.** A systemd timer on the box, `carnevale-db-backup.timer`, fires nightly at **03:00
UTC** and runs `/opt/carnevale/db-backup.sh` (source: `deploy/backup/db-backup.sh`). Each night it:

1. `pg_dump -Fc` the production database straight out of the Postgres accessory container — the DB
   password is read from the container's own env, so nothing is stored on the host and it survives a
   password rotation.
2. Sanity-checks the dump (non-empty, starts with the `PGDMP` magic bytes) so a truncated dump never
   overwrites good history.
3. `rclone copy`s it to **Cloudflare R2**, bucket `carnevale-backups`, under `daily/`, and on Sundays
   also under `weekly/`.
4. Prunes to **7 daily + 4 weekly** copies (files are date-named, so a lexical sort is chronological).

**Where the copies live.** `r2:carnevale-backups/daily/carnevale-YYYY-MM-DD.dump` and
`.../weekly/…`. R2 is off-Hetzner, so it survives the box — and the provider — dying.

**Credentials.** An R2 API token scoped to the one bucket, written to `/root/.config/rclone/rclone.conf`
(mode 600) by `bin/install-db-backups`, which reads them from the gitignored `.kamal/backup.env`. Two
rclone options matter for R2 and are set in that config: `no_check_bucket` (a bucket-scoped token
can't do the account-level bucket check rclone runs before an upload) and `no_head` (R2 flaps 501 on
the post-PUT HEAD; the PUT is integrity-checked via Content-MD5 anyway).

**Install / update.** From a machine with SSH to the box: `bin/install-db-backups`. Idempotent —
re-run it to push a script change or after rotating the R2 token.

**Check it is healthy.** On the box:

```
systemctl list-timers carnevale-db-backup.timer      # next/last run
journalctl -u carnevale-db-backup.service -n 40       # last run's log
```

Or list what actually made it off-box from a dev machine: `bin/db-restore --list`.

---

## How to restore

### The server is gone; rebuild it

1. Provision, then `kamal setup` (see `docs/DEPLOYMENT.md`).
2. `kamal app exec "bin/rails db:prepare"` — schema, empty database.
3. `kamal app exec "bin/rails db:seed"` — rulebook data (abilities, spells, scenarios…).
4. `kamal app exec "bin/rails catalog:import"` — the catalog, from `db/catalog/`. Additive and
   idempotent: it matches on natural keys, never deletes, and is safe to re-run.
5. Card images arrive from git: the first deploy seeds the cards volume from the image. Anything
   still out of date, publish from the backoffice.
6. **Player data:** restore the latest nightly dump over the fresh database — see below. (Steps 3–4
   become redundant once you do this: the dump already contains the seeded rulebook and the catalog.
   Run them only if you deliberately want day-one data instead of the last backup.)

### Restore the database from a backup

`bin/db-restore` does the whole trip from a dev machine: it pulls a dump from R2 down to the box
(where Postgres lives) and `pg_restore`s it. By default it restores into a **throwaway scratch
database**, prints the row counts, and drops it — that is how you *verify* a backup without touching
anything real, and it is exactly the test that was run when this was first set up.

```
bin/db-restore --list                                  # what is in R2
bin/db-restore --file daily/carnevale-2026-07-20.dump  # verify: scratch DB, counts, drop
bin/db-restore --file <path> --into carnevale_inspect  # restore + KEEP a named DB to poke at
bin/db-restore --file <path> --production              # DANGER: overwrite production (typed confirm)
```

Restoring **into production** drops and recreates `carnevale_backend_production` from the dump, so it
demands you type the database name to confirm. Reach for it only when production is empty (a rebuilt
box) or knowingly corrupt.

### Someone broke the catalog in production

`db/catalog/` is a readable diff and git remembers every snapshot. Check out the good version and
`catalog:import` it. Because import never deletes, a record that was *added* by mistake stays —
remove it in the backoffice.

---

## Where this should go

In the order I would do it:

1. **Nightly `pg_dump`, off the box** (`docs/TODO.md` P1). **Done** (2026-07-20) — nightly to R2, 7+4
   rotation, restore tested. See [The nightly database backup](#the-nightly-database-backup).
2. **Automate the catalog snapshot** (P2). It is manual, so the safety net is only as fresh as the
   last time someone remembered. `bin/catalog-snapshot` is a cron job away.
3. **Point `db/seeds.rb` at `CatalogSnapshot.import`** for profiles, weapons and rules, so a fresh
   install reproduces *production* rather than the day-one catalog. The hand-written faction files
   then retire, and the two sources of truth become one. (The rulebook seeds stay as they are — the
   backoffice cannot edit them.)
4. **Only then consider moving the committed illustrations into Active Storage.** It buys one code
   path instead of two. It also moves 89 MB of art out of git — versioned, replicated, restorable by
   clone — and into a single Docker volume with no automated backup. That is a downgrade in
   durability bought with tidiness, and it stays a bad trade until (1) and (2) are done.
