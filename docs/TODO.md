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
picture. To make it production-ready (roughly in priority order):

- **P1: Off-site database backups.** None today — the biggest risk. Add a nightly
  `pg_dump` (from the Postgres container) → gzip → upload *off the server*, with
  rotation (e.g. 7 daily + 4 weekly). Destination TBD: Cloudflare R2 (free at this
  scale, recommended) or Hetzner Storage Box (~€3/mo). Test a restore before trusting it.
- **P2: Real domain + DNS** — replaces the temporary `sslip.io` host (also unblocks the
  App Links note under Auth above).
- **P2: Finish the Solid stack** — generate the solid_queue/cache/cable schemas so
  background jobs and WebSockets (ActionCable) work; both are disabled/Redis-pointed today.
- **P3:** Email/SMTP, Hetzner firewall (22/80/443 only), error tracking + `/up` uptime
  monitoring, rotate the GitHub deploy token.

## Roadmap

3. Full game/match tracking (DONE)
4. Card versioning (DONE)
5. Share lists via QR code.
6. Merge the backend with the card creator tool
