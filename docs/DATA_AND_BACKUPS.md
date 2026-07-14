# Data, source of truth, and backups

Which copy of a thing wins when two disagree, what protects it if the server dies tonight, and what
does not. Written after the first production `catalog:export`, when the catalog stopped living on a
single box and nothing else changed.

The short version: **the catalog is safe, the players' data is not.**

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
| **Users, lists, games** | Postgres | **NO. Nothing. Anywhere.** |

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

### The gap that should scare you

**There is no database backup.** Player data — accounts, gang lists, games in progress — exists only
on that single Hetzner box's volume. No `pg_dump`, no off-site copy, no rotation. If the disk dies,
it is gone, and no snapshot in this repo brings it back. `catalog:export` protects the *catalog*, not
the players.

This is the P1 item in `docs/TODO.md` and it is the most valuable thing left undone in this project.

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
6. **Player data: unrecoverable.** Until the `pg_dump` exists, accept this or fix it first.

### Someone broke the catalog in production

`db/catalog/` is a readable diff and git remembers every snapshot. Check out the good version and
`catalog:import` it. Because import never deletes, a record that was *added* by mistake stays —
remove it in the backoffice.

---

## Where this should go

In the order I would do it:

1. **Nightly `pg_dump`, off the box** (`docs/TODO.md` P1). Everything else here is a nice-to-have
   next to it. Test the restore before trusting it — an untested backup is a rumour.
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
