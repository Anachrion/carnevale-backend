# Deployment

How the Carnevale backend is deployed to production, why it's set up this way,
and what to do to make it truly production-ready.

> **Status:** Live for early testing with friends — **not** yet hardened for real
> production. See [Known limitations](#known-limitations) and
> [Road to production-ready](#road-to-production-ready).

---

## TL;DR

| | |
|---|---|
| **Live URL** | https://62.238.30.155.sslip.io |
| **Host** | Hetzner Cloud **CX23** (2 vCPU / 4 GB / 40 GB SSD), Ubuntu 24.04, Helsinki |
| **Deploy tool** | [Kamal 2](https://kamal-deploy.org) (Rails 8 default) |
| **Cost** | ~€7.19/mo (server €6.59 + IPv4 €0.60) |
| **Database** | PostgreSQL 17, running as a Kamal accessory container on the same VM |
| **TLS** | Automatic Let's Encrypt via kamal-proxy, on a free `sslip.io` hostname |
| **Redeploy** | `infisical run --env=prod -- bundle exec kamal deploy` |

---

## Architecture

A single small VM runs everything as Docker containers, wired together by Kamal:

```
                    Internet
                       │  :443 (HTTPS) / :80 (→301)
                       ▼
┌──────────────────────────────────────────────┐
│  Hetzner VM (62.238.30.155, Ubuntu 24.04)     │
│                                                │
│  ┌────────────┐   TLS termination             │
│  │ kamal-proxy│   + Let's Encrypt cert        │
│  └─────┬──────┘                                │
│        │ http :80                              │
│  ┌─────▼───────────────┐                       │
│  │ app container        │  Puma + Thruster     │
│  │ ghcr.io/anachrion/   │  (Rails 8.1)         │
│  │ carnevale_backend    │                      │
│  └─────┬───────────────┘                       │
│        │ :5432 (kamal docker network)          │
│  ┌─────▼───────┐                               │
│  │ postgres:17  │  accessory container          │
│  │ (db)         │  volume: carnevale_backend_db_data
│  └─────────────┘                               │
│                                                │
│  volume: carnevale_backend_storage (uploads)  │
└──────────────────────────────────────────────┘
```

- **One box, no Redis.** The app, the web proxy, and Postgres all live on one VM.
- **Uploads** (Active Storage `:local` disk) persist in a Docker volume so they
  survive redeploys.
- **Deploys** build the image locally, push to GitHub Container Registry (ghcr.io),
  then Kamal SSHes in and swaps the running container with near-zero downtime.

---

## What we chose, and why

### Host: Hetzner CX23 (single VPS)
Cheapest reliable option for the target scale (~200 users/month), and the repo was
already set up for a Docker/Kamal deploy. Hetzner is ~2–3× cheaper than AWS/DO/GCP
for equivalent specs. We defaulted to a small shared-vCPU box because at this scale
a single 2 vCPU / 4 GB machine comfortably handles app + database.

> We originally wanted an **Arm64 (Ampere / CAX11)** server — it's a touch cheaper and
> would build natively on an Apple Silicon Mac (no emulation). Arm was **out of stock**
> at deploy time, so we fell back to the x86 **CX23**. The only consequence: the Docker
> image builds under **QEMU emulation** on the Mac, making the *first* build slow
> (subsequent builds are cached). If Arm frees up, switching back is a one-line change
> (`builder.arch: arm64`) + recreating the server.

(Fuller comparison of alternatives — Fly.io, Render, Oracle Free Tier, home server,
etc. — lives in the git-ignored `docs/HOSTING_NOTES.md`.)

### Deploy tool: Kamal
It's the Rails 8 default and already in the Gemfile. It turns a plain Linux box into
something that deploys like a PaaS: builds the image, pushes to a registry, and does
zero-downtime container swaps with automatic TLS via kamal-proxy. No proprietary
platform lock-in — the same config deploys to any Linux host.

### Database: Postgres accessory (not managed)
Hetzner has no managed Postgres, and a managed DB elsewhere (€25–40/mo) is overkill
for testing. Running `postgres:17` as a Kamal accessory on the same VM is simple and
free. **Trade-off:** backups and failover are on us (see
[Road to production-ready](#road-to-production-ready)).

### TLS without a domain: sslip.io
`sslip.io` is a DNS service that resolves `<ip>.sslip.io` straight to that IP. So
`62.238.30.155.sslip.io` points at our server with zero DNS setup, and kamal-proxy
provisions a real Let's Encrypt cert for it. This gives proper HTTPS (important —
the Flutter app sends JWTs on every request) **without buying a domain**. Swapping in
a real domain later is a two-line change.

### No Redis
The app ships the `solid_queue` / `solid_cache` / `solid_cable` gems (Postgres-backed
replacements for Redis), so the whole system needs only Postgres. (Caveat: these
aren't fully wired up yet — see below.)

---

## How to deploy

### Prerequisites (one-time, on your Mac)
- **Docker Desktop** running (Kamal builds the image locally).
- **Infisical CLI**, logged in against EU Cloud and linked to this repo:
  ```bash
  brew install infisical
  infisical login --domain https://eu.infisical.com
  infisical init --domain https://eu.infisical.com   # writes .infisical.json (committed)
  ```
  The Production environment of the `carnevale` project holds the three secrets Kamal
  needs: `KAMAL_REGISTRY_PASSWORD` (GitHub PAT, `write:packages`), `RAILS_MASTER_KEY`,
  and `CARNEVALE_BACKEND_DATABASE_PASSWORD`. `POSTGRES_PASSWORD` is not stored — it is
  derived from the DB password in `.kamal/secrets`, since both must be the same value.

  > ⚠️ **The DB password must never change.** The Postgres data volume was initialized
  > with it on the first deploy. If you lose or change it, the app can no longer log in
  > to its own database.

  > The `--domain` flag is required: the CLI defaults to the US instance
  > (`app.infisical.com`) and this org lives on EU Cloud. `infisical init` does **not**
  > persist it, so `.infisical.json` carries a hand-added `"domain"` field — that is what
  > makes every later `infisical run` hit the EU instance on any machine. Without it the
  > CLI falls back to per-machine login state, which a fresh checkout doesn't have.

### Redeploy (the normal case)
After committing code changes:
```bash
cd ~/Workspace/carnevale-backend
infisical run --env=prod -- bundle exec kamal deploy
```
Kamal builds from your **committed** git HEAD (uncommitted changes are ignored), so
**commit before deploying**.

### First-time setup (already done; for reference / rebuilds)
```bash
infisical run --env=prod -- bundle exec kamal setup
```
`setup` also installs Docker on the server and boots the Postgres accessory + proxy.
Use it when provisioning a fresh server; use `deploy` for everyday updates.

### Useful commands
```bash
bundle exec kamal logs -f          # tail app logs
bundle exec kamal console          # rails console on the server
bundle exec kamal shell            # bash inside the app container
bundle exec kamal dbc              # rails dbconsole
bundle exec kamal rollback         # revert to the previous image
bundle exec kamal app boot         # restart the app container
```

### Key files
| File | Purpose | Committed? |
|---|---|---|
| `config/deploy.yml` | The entire Kamal config (server, image, proxy, env, accessory, volumes) | ✅ yes |
| `.kamal/secrets` | Secret *references* only (`$VAR`) — no real values | ✅ yes |
| `.infisical.json` | Which Infisical project/environment this repo reads — no values | ✅ yes |
| Infisical, `carnevale` → Production | The real secret **values** | — not in the repo |
| `Dockerfile` | Production image build (Rails 8 default) | ✅ yes |

### A build-time gotcha to know about
The image build runs `assets:precompile` **without the master key** (using
`SECRET_KEY_BASE_DUMMY=1`), so encrypted credentials can't be decrypted at build time.
Any code that reads a credential or a required ENV var **at boot** must tolerate its
absence during the build. We guard these with `ENV["SECRET_KEY_BASE_DUMMY"]`:
- `config/environments/production.rb` → `FRONTEND_URL`
- `config/initializers/devise.rb` → `devise_jwt_secret_key!`

If you add another boot-time credential/ENV read and the build fails with a `KeyError`,
apply the same guard.

---

## Current state

✅ Working:
- HTTPS JSON API (devise-jwt auth for the Flutter clients)
- Devise web backoffice
- PostgreSQL with all app tables (23) migrated
- Persistent file uploads
- HTTP→HTTPS redirect, HSTS, secure cookies (`force_ssl`)

---

## Known limitations

These are fine for testing but **must** be addressed before real production:

1. **No database backups.** Postgres runs in a single container. If the VM or volume
   dies, data is lost. _(Resolved — CARNEVALEB-11; nightly off-site backups now run, see
   `DATA_AND_BACKUPS.md`. This gaps list is refreshed in full under CARNEVALEB-54.)_
2. **Background jobs disabled.** `solid_queue` / `solid_cache` / `solid_cable` gems and
   separate `queue`/`cache`/`cable` databases are configured, but their **schemas were
   never generated**, so the Solid Queue worker is turned off (it would crash on missing
   tables). Nothing uses it yet (Active Job falls back to in-process `:async`), but
   durable jobs won't work until it's installed.
3. **WebSockets won't work.** `config/cable.yml` production is still set to the `redis`
   adapter, and no Redis is running. Any Action Cable / live-gameplay feature fails.
4. **No email.** SMTP isn't configured, so password-reset and other mailer emails don't
   send.
5. **Raw-IP URL.** `sslip.io` on the server's IP works, but the IP changes if the server
   is rebuilt, and `sslip.io` is a shared third-party service (subject to its uptime and
   Let's Encrypt rate limits).
6. **No firewall.** All ports are open by default (only 22/80/443 are used, but nothing
   restricts the rest).
7. **`FRONTEND_URL` is a placeholder** (points at the API's own URL) until a real
   frontend URL exists.
8. **Single point of failure.** One VM; a reboot or host issue = downtime.

---

## Road to production-ready

Roughly in priority order.

### 1. Database backups (highest priority)
- Add a nightly `pg_dump` to off-site storage (e.g. Hetzner Storage Box, S3-compatible
  bucket, or `docker exec` + upload on a cron).
- Enable **Hetzner Backups** on the server (~+20% cost) for full-disk snapshots.
- Or move to a managed Postgres once the app matures.

### 2. A real domain + DNS
- Buy a domain (Cloudflare Registrar / Porkbun — **not** via Hetzner).
- Point an `A` record at `62.238.30.155`, then set `proxy.host` and `FRONTEND_URL`
  in `config/deploy.yml` to the domain and redeploy.
- Removes the `sslip.io` dependency and survives server rebuilds (with a static/floating IP).

### 3. Finish the Solid stack (jobs, cache, cable)
- Generate the Solid Queue schema (`bin/rails solid_queue:install` or equivalent) and
  load it into the `queue` DB. **Note:** the DBs already exist, so `db:prepare` won't
  auto-load their schema — use `db:schema:load:queue` or a migration.
- Set `config.active_job.queue_adapter = :solid_queue`, then re-add
  `SOLID_QUEUE_IN_PUMA: true` to `config/deploy.yml`.
- Switch `config/cable.yml` production from `redis` to `solid_cable` (drops the Redis
  dependency) and load the `cable` schema. Do the same for `solid_cache` if you want a
  durable cache.

### 4. Email
- Configure an SMTP provider (Postmark, Resend, SES, …) in credentials, uncomment the
  `action_mailer.smtp_settings` block in `config/environments/production.rb`, and set a
  real `action_mailer.default_url_options[:host]`.

### 5. Hardening & operations
- Add a **Hetzner firewall** allowing only 22/80/443.
- Rotate/scope the GitHub deploy token; consider a fine-grained PAT.
- Set up **error tracking** (e.g. Sentry) and **uptime monitoring** on `/up`.
- Consider a **remote/CI build** (`builder.remote` is stubbed in `deploy.yml`) or a
  GitHub Actions deploy pipeline to avoid slow local emulated builds.
- Move Active Storage to object storage (S3/Hetzner Object Storage) if uploads grow —
  a single VM disk doesn't scale or replicate.

### 6. Scaling (only if/when needed)
- Vertically resize the CX23 in the Hetzner console (no rebuild needed).
- If one box isn't enough, split Postgres onto its own server and/or add app replicas —
  Kamal supports multiple servers and roles.
```
