# Data, source of truth, and backups

Which copy of a thing wins when two disagree, what protects it if the server dies tonight, and what
does not. Written after the first production `catalog:export`, when the catalog stopped living on a
single box and nothing else changed.

The short version: **everything authored in production — the catalog, the art uploaded through the
backoffice, and the players' data — is backed up nightly, off the box, to Cloudflare R2.** The
catalog's change history (who changed which card, with a revert) lives in the same database, so it
is in that backup too. `db/catalog/` in git is the **development seed**, not a backup.

(Until 2026-11-22 the catalog's backup was `db/catalog/`, refreshed by hand after every authoring
session — see [CARNEVALEB-82](#why-the-catalog-is-no-longer-backed-up-in-git) below.)

---

## Who is the source of truth

Three kinds of data, three different answers. Getting these confused is how you overwrite a month of
someone's work with a seed file.

### 1. Authored in production → the production database wins

Everything the backoffice can edit. A game creator signs in at `/backoffice`, edits a profile, and
that edit exists **only in production** until the next nightly backup copies it to R2:

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

- **`public/cards/*`** — the rendered card faces. Produced by *Publish cards*, from the catalog
  and the art. **Not in git** (gitignored since 2026-08-03): they are derived, they cost ~67 MB in
  every clone, and each re-render added another generation to LFS storage. They still reach a new
  server, because Kamal builds the image from the *working tree* — so whatever is in `public/cards`
  on the deploy machine ships inside the image. In production they then live on a Docker volume
  (`carnevale_backend_cards`) that, after the first deploy, **masks the image's directory** — so
  from that point on a newer card in the image no longer reaches the server. Publish on the server
  instead.
- **`public/cards/pdf/*`** — the printable per-faction sheets the public `/cards` page hands out
  (`FactionCardPdf`). Built from the faces above, so they are derived data of derived data, and they
  sit inside `public/cards` — same volume, same gitignore, same "publish on the server" caveat.
  Rebuild them from *Publish cards* → **Rebuild printable sheets** (a background job), or
  `kamal app exec "bin/rails cards:pdf"`. They only ever show what was last published, so rebuild
  them **after** a render pass, never instead of one. Budget ~165 MB of the cards volume: a rebuild
  keeps only each faction's newest sheet and deletes the one it supersedes.
- **`internal_version` and the staleness digests** — render bookkeeping. Rebuilt by publishing.
  `catalog:export` deliberately does not carry them.

Losing derived data costs time, not information. Everything above can be rebuilt by publishing.

---

## What is backed up today

| Data | Where it lives in production | Backed up? |
|---|---|---|
| Catalog records and their change history | Postgres | **Yes** — nightly `pg_dump` to R2 |
| Uploaded art | `carnevale_backend_storage` volume | **Yes** — nightly `rclone copy` to R2 `storage/` |
| Committed art | in the image, from git | **Yes** — it *is* git |
| Rendered cards | `carnevale_backend_cards` volume | **No** — not in git either; regenerable by publishing |
| **Users, lists, games** | Postgres | **Yes** — nightly `pg_dump` to R2 |

All of it comes from one systemd timer: see [The nightly backup](#the-nightly-database-backup).

### The catalog snapshot (development seed)

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

**What it is for.** `db/seeds.rb` calls `CatalogSnapshot.import`, so `db/catalog/` is how
`bin/setup` gives a contributor a catalog on their machine — a production dump cannot be handed out,
since it holds the players' accounts. Refresh it now and then, when local work needs newer cards;
there is no freshness requirement, because it is not a backup.

**What it carries**: everything the backoffice can edit (CARNEVALEB-84): the ability glossary
(`abilities.yml`), the spells (`spells.yml`), weapons, special rules, and per profile its stats,
keywords, abilities, advanced options (recruitable, flexible Leader and partner, distinct
Discipline per copy, companion upgrade cost, transformation form), spell pools, granted spells, companions, card
references and illustrations. References between records are portable: rules by stable key,
spells by discipline and name, profiles by their anchor identifier. Only render bookkeeping and
player data stay out.

Snapshots committed before CARNEVALEB-84 lack the pools, grants, companions and options, so
`db/seeds.rb` still rebuilds them from the `spell_pools:`, `leaders:` and
`companions:configure_exceptions` rake tasks until `db/catalog/` is refreshed from production;
those tasks then retire.

#### Why the catalog is no longer backed up in git

Decided in CARNEVALEB-82 (2026-11-22). The snapshot was the catalog's backup, but it was only as
fresh as the last time someone remembered to run it, and it does not carry the data listed above.
The nightly `pg_dump` already covered the whole catalog; its short retention (7 daily + 4 weekly)
matters little now that a card broken weeks ago can be restored from its history in the backoffice.
The one gap was uploaded art, which `pg_dump` references but does not contain — hence the
`rclone copy` of the storage volume, added at the same time.

### The nightly database backup

This is what protects everything authored in production — the catalog and its history, the art
uploaded through the backoffice, the player data (accounts, gang lists, games in progress) — that
otherwise lives only on the box's volumes.

**What runs.** A systemd timer on the box, `carnevale-db-backup.timer`, fires nightly at **03:00
UTC** and runs `/opt/carnevale/db-backup.sh` (source: `deploy/backup/db-backup.sh`). Each night it:

1. `pg_dump -Fc` the production database straight out of the Postgres accessory container — the DB
   password is read from the container's own env, so nothing is stored on the host and it survives a
   password rotation.
2. Sanity-checks the dump (non-empty, starts with the `PGDMP` magic bytes) so a truncated dump never
   overwrites good history.
3. `rclone copy`s it to **Cloudflare R2**, under `daily/`, and on Sundays also under `weekly/`.
4. Prunes to **7 daily + 4 weekly** copies (files are date-named, so a lexical sort is chronological).
5. `rclone copy`s the `carnevale_backend_storage` volume (Active Storage, i.e. the uploaded art) to
   `storage/`. A dump holds only the *reference* to an uploaded file, so this is what keeps the
   bytes. It is `copy`, not `sync`: nothing is ever deleted on R2, so an image removed or replaced
   by mistake on the box is still there. Only new files are sent; a few hundred KB per image.

**Where the copies live.** `daily/carnevale-YYYY-MM-DD.dump`, `.../weekly/…` and `storage/` (the
Active Storage tree, as on disk) in the backup bucket. R2 is off-Hetzner, so it survives the box —
and the provider — dying. Everything together is well within R2's free 10 GB.

**Credentials.** A bucket-scoped R2 API token, written to the server's rclone config (mode 600)
by `bin/install-db-backups`, which reads `R2_ACCOUNT_ID` / `R2_ACCESS_KEY_ID` /
`R2_SECRET_ACCESS_KEY` / `R2_BUCKET` from the environment (Infisical, Production). Two
rclone options matter for R2 and are set in that config: `no_check_bucket` (a bucket-scoped token
can't do the account-level bucket check rclone runs before an upload) and `no_head` (R2 flaps 501 on
the post-PUT HEAD; the PUT is integrity-checked via Content-MD5 anyway).

**Install / update.** From a machine with SSH to the box:
`infisical run --env=prod -- bin/install-db-backups`. Idempotent — re-run it to push a
script change or after rotating the R2 token. Every `kamal deploy` also runs it (with
`--no-run`) from the `post-deploy` hook, so a script change ships with the next deploy
(CARNEVALEB-92).

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
3. **The database:** restore the latest nightly dump over it with
   `bin/db-restore --file <path> --production` — see below. It holds everything: rulebook, catalog,
   change history, players.
4. **The uploaded art:** copy it back into the storage volume, on the box:
   `rclone copy r2:carnevale-backups/storage/ "$(docker volume inspect carnevale_backend_storage -f '{{.Mountpoint}}')"`
   (`bin/install-db-backups` has set rclone up there). Without this, the cards whose art was
   uploaded through the backoffice render with an empty frame.
5. Card images ride in the image from whatever is in `public/cards` on the deploy machine, and the
   first deploy seeds the cards volume from it. They are **not** in git, so on a machine that never
   had them — a fresh clone — the directory is empty and the volume is seeded empty. That is
   recoverable: publish from the backoffice once the database and art are back.

`db:seed` and `catalog:import` are for a **new, non-production environment** (a contributor's
machine, a staging box): they give it the day-one rulebook and the catalog from `db/catalog/`, which
may be weeks behind production. Never use them to restore production.

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

Use the backoffice: **History** shows who changed what, and each card's history page restores an
earlier version of the whole card (stats, weapons, rules, spells, companions); a weapon or special
rule is undone from its own edit page (CARNEVALEB-81). No developer needed.

If the damage predates the history, or touches data it does not cover, restore a dump into a side
database (`bin/db-restore --file <path> --into carnevale_inspect`) and copy the good values from
there.

---

## Where this should go

In the order I would do it:

1. **Nightly `pg_dump`, off the box** (CARNEVALEB-11). **Done** (2026-07-20) — nightly to R2, 7+4
   rotation, restore tested. See [The nightly database backup](#the-nightly-database-backup).
2. ~~**Automate the catalog snapshot**~~. **Dropped** (CARNEVALEB-82, 2026-11-22): the nightly
   backup covers the catalog, and now the uploaded art too; `db/catalog/` is the development seed.
   See [why](#why-the-catalog-is-no-longer-backed-up-in-git).
3. **Point `db/seeds.rb` at `CatalogSnapshot.import`** for profiles, weapons and rules, so a fresh
   install reproduces *production* rather than the day-one catalog. The hand-written faction files
   then retire, and the two sources of truth become one. (The rulebook seeds stay as they are — the
   backoffice cannot edit them.)
4. **Only then consider moving the committed illustrations into Active Storage.** It buys one code
   path instead of two. It also moves 89 MB of art out of git — versioned, replicated, restorable by
   clone — and into a single Docker volume. That volume is now copied to R2 nightly, so the art
   would no longer be lost with the box, but it would lose git's history and its restore-by-clone.
   Still a trade to weigh, not an obvious win.
