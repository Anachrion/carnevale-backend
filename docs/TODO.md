# TODO / Roadmap / Leftovers

## Auth

- P3 (low priority): open password reset emails directly in the native
  Android/iOS app instead of a browser tab.
  The reset email links to `FRONTEND_URL/reset-password?reset_password_token=...`,
  which works everywhere today (the frontend is available on web, Android,
  and iOS): on web it loads the app directly, on Android/iOS it opens the
  phone's browser. To make Android/iOS jump straight into the installed app,
  the link needs to become a verified Android App Link / iOS Universal Link,
  which requires a real production domain (in production `FRONTEND_URL` is
  currently the temporary `…sslip.io` host, not a real domain; dev is still
  `localhost`) hosting `assetlinks.json` / `apple-app-site-association`. See
  `carnevale`'s `TODO.md` for the matching frontend-side note.

## Deployment / Ops

Production runs on a single Hetzner VM via Kamal — see `DEPLOYMENT.md` for the full
picture, and `DATA_AND_BACKUPS.md` for who owns which data, what a restore looks like,
and which of these gaps actually loses information. To make it production-ready
(roughly in priority order):

- **P1: Off-site database backups.** None today — the biggest risk. Add a nightly
  `pg_dump` (from the Postgres container) → gzip → upload *off the server*, with
  rotation (e.g. 7 daily + 4 weekly). Destination TBD: Cloudflare R2 (free at this
  scale, recommended) or Hetzner Storage Box (~€3/mo). Test a restore before trusting it.
  Note: `catalog:export` now snapshots the *catalog* to git, but that is not a substitute —
  it does not cover **player data** (lists, games, users) or Active Storage anything beyond
  illustration blobs. This `pg_dump` is what protects everything on the box's single volume.
- **P2: Real domain + DNS** — replaces the temporary `sslip.io` host (also unblocks the
  App Links note under Auth above).
- **P2: Finish the Solid stack** — generate the solid_queue/cache/cable schemas so
  background jobs and WebSockets (ActionCable) work; both are disabled/Redis-pointed today.
- **P2: Automate the daily catalog snapshot.** `bin/catalog-snapshot` does the whole trip
  (export in the running container → pull the files out → show the diff) but is run by hand.
  A game creator authors ~10 cards/year in the prod backoffice (uploading art as Active
  Storage blobs); those live only on the box until exported. Want a daily
  export → commit → push to git, so the catalog + its blobs land in version control
  automatically. The awkward part is *where it runs*: it needs both prod access (the DB is
  bound to localhost on the box, so the export must run there) and git push rights. Options:
  a GitHub Actions cron (native git creds; needs SSH access to the box) or a host cron with a
  deploy key. A background worker (finish the Solid stack, or add Redis + Sidekiq) could own
  the schedule, but the git-push-from-prod step is the real design question, not the queue.
- **P3:** Email/SMTP, Hetzner firewall (22/80/443 only), error tracking + `/up` uptime
  monitoring, rotate the GitHub deploy token.

## Cards

- **P2: Serve the card images as WebP instead of PNG.** Each card face is a ~1.1 MB PNG,
  so a full catalog sync makes the app download ~750 MB. The same image as WebP (same
  795×1362 pixels, transparent corners preserved) is ~170 KB — about 7× smaller, for no
  loss of resolution. Grover only emits PNG/JPEG, so this means converting the PNG to
  WebP (`cwebp` or libvips, added to the production image next to Chromium) before
  writing into `public/cards`, in `render_to_catalog` and the `cards:render` task. The
  filenames gain a `.webp` extension, so every client re-downloads its catalog once —
  at ~125 MB instead of the ~750 MB it costs them today. The print/PDF path keeps PNG.

## Roadmap

3. Full game/match tracking (DONE)
4. Card versioning (DONE)
5. Share lists via QR code.
6. Merge the backend with the card creator tool
