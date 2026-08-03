# Deployment

How the Carnevale backend is deployed to production, and why it's set up this way.

For the big picture across backend *and* frontend, start with
[`DEPLOY_OVERVIEW.md`](./DEPLOY_OVERVIEW.md). This document is the backend detail:
the reasoning behind each choice, and the two procedures that are easy to get wrong.

---

## TL;DR

| | |
|---|---|
| **Live URL** | https://carnevale-app.com |
| **Host** | One Hetzner Cloud shared-vCPU VM (2 vCPU / 4 GB / 40 GB SSD), Ubuntu 24.04, Helsinki |
| **Deploy tool** | [Kamal 2](https://kamal-deploy.org) (Rails 8 default) |
| **Cost** | ~€7.19/mo (server €6.59 + IPv4 €0.60) |
| **Database** | PostgreSQL 17, running as a Kamal accessory container on the same VM |
| **TLS** | Automatic Let's Encrypt via kamal-proxy |
| **Redeploy** | `infisical run --env=prod -- kamal deploy` |

---

## Architecture

A single small VM runs everything as Docker containers, wired together by Kamal:

```
                    Internet
                       │  :443 (HTTPS) / :80 (→301)
                       ▼
┌──────────────────────────────────────────────┐
│  Hetzner VM (Ubuntu 24.04)                    │
│                                                │
│  ┌────────────┐   TLS termination             │
│  │ kamal-proxy│   + Let's Encrypt cert        │
│  └─────┬──────┘                                │
│        │ http :80                              │
│  ┌─────▼───────────────┐                       │
│  │ app container        │  Puma + Thruster     │
│  │ carnevale_backend    │  (Rails 8.1)         │
│  └─────┬───────────────┘                       │
│        │ :5432 (kamal docker network)          │
│  ┌─────▼───────┐                               │
│  │ postgres:17  │  accessory container          │
│  │ (db)         │  volume: …_db_data            │
│  └─────────────┘                               │
│                                                │
│  volumes: …_storage (uploads), …_cards        │
└──────────────────────────────────────────────┘
```

- **One box, no Redis.** The app, the web proxy, and Postgres all live on one VM.
- **Uploads** (Active Storage `:local` disk) and **rendered card images** persist in
  Docker volumes so they survive redeploys.
- **Deploys** build the image locally, push to GitHub Container Registry, then Kamal
  SSHes in and swaps the running container with near-zero downtime.

---

## What we chose, and why

### Host: a single small Hetzner VPS
Cheapest reliable option for the target scale (~200 users/month), and the repo was
already set up for a Docker/Kamal deploy. Hetzner is ~2–3× cheaper than AWS/DO/GCP
for equivalent specs, and at this scale a single 2 vCPU / 4 GB machine comfortably
handles app + database.

> We originally wanted an **Arm64 (Ampere)** server — a touch cheaper, and it would
> build natively on an Apple Silicon Mac. Arm was **out of stock** at deploy time, so we
> fell back to x86. The only consequence: the Docker image builds under **QEMU emulation**
> on the Mac, making the *first* build slow (subsequent builds are cached). Switching back
> is a one-line change (`builder.arch: arm64`) plus recreating the server.

### Deploy tool: Kamal
It's the Rails 8 default and already in the Gemfile. It turns a plain Linux box into
something that deploys like a PaaS: builds the image, pushes to a registry, and does
zero-downtime container swaps with automatic TLS via kamal-proxy. No proprietary
platform lock-in — the same config deploys to any Linux host.

### Database: Postgres accessory (not managed)
Hetzner has no managed Postgres, and a managed DB elsewhere (€25–40/mo) is overkill at
this size. Running `postgres:17` as a Kamal accessory on the same VM is simple and free.
**Trade-off:** backups are on us — see [`DATA_AND_BACKUPS.md`](./DATA_AND_BACKUPS.md),
which covers the nightly off-site `pg_dump` and how to restore from it.

### No Redis
The app uses `solid_queue` / `solid_cache` / `solid_cable` — Postgres-backed replacements
for Redis — so the whole system needs only Postgres. Action Cable runs on `solid_cable`
(`config/cable.yml`), and Solid Queue runs **inside Puma** via `SOLID_QUEUE_IN_PUMA`
rather than as a separate container, which suits a two-core box with light job traffic.

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
  The Production environment holds the secrets Kamal needs: `KAMAL_REGISTRY_PASSWORD`
  (a GitHub PAT with `write:packages`), `RAILS_MASTER_KEY`, and
  `CARNEVALE_BACKEND_DATABASE_PASSWORD`. `POSTGRES_PASSWORD` is not stored separately —
  it is derived from the DB password in `.kamal/secrets`, since both must be the same
  value.

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
infisical run --env=prod -- kamal deploy
```
Kamal builds from the **working tree** (not `git archive`) so LFS card images ship as
real bytes — run `git lfs pull` once so they're materialised, and **commit your code
changes** before deploying.

### First-time setup (for a rebuild or a fresh server)
```bash
infisical run --env=prod -- kamal setup
```
`setup` also installs Docker on the server and boots the Postgres accessory + proxy.
Use `deploy` for everyday updates.

### Useful commands
```bash
kamal logs -f        # tail app logs
kamal console        # rails console on the server
kamal shell          # bash inside the app container
kamal dbc            # rails dbconsole
kamal rollback       # revert to the previous image
kamal app boot       # restart the app container
```
(These are aliases defined at the bottom of `config/deploy.yml`.)

### Key files
| File | Purpose | Committed? |
|---|---|---|
| `config/deploy.yml` | The entire Kamal config (server, image, proxy, env, accessory, volumes) | ✅ yes |
| `.kamal/secrets` | Secret *references* only (`$VAR`) — no real values | ✅ yes |
| `.infisical.json` | Which Infisical project/environment this repo reads — no values | ✅ yes |
| Infisical → Production | The real secret **values** | — not in the repo |
| `Dockerfile` | Production image build (Rails 8 default) | ✅ yes |

---

## Two things that are easy to get wrong

### Rotating or enabling `API_KEY`

`API_KEY` is a shared client key identifying a build as an official Carnevale frontend.
It is **not** per-user auth (that's the JWT) — a key baked into a public client can't
stay secret. It only raises the bar against casual scraping, alongside Rack::Attack
throttling and CORS.

The check in `app/controllers/concerns/authenticates_client.rb` **fails open**: a blank
`API_KEY` means no check at all. That makes enabling or rotating it a breaking change
with a strict ordering, because clients bake the key in at build time:

1. Set the new value in Infisical (Production).
2. Rebuild **and ship** every client with the new key:
   - Web — `infisical run --env=prod -- bin/release-web`
   - Android — `infisical run --env=prod --recursive -- bin/publish-play` from the
     frontend repo
3. Only then `infisical run --env=prod -- kamal deploy`.

Get the order wrong and every client gets `401 Unauthorized` until a new build reaches
it. The web bundle ships inside the image, so it updates atomically with the backend —
but **installed APKs cannot be fixed remotely**. Any tester on an older build is locked
out until they install a new one. Treat an `API_KEY` change as a coordinated release,
never a config tweak.

There is deliberately no transition mode that accepts both old and new keys. If you need
one, that's a code change to `authenticates_client.rb`, not a deploy-time option.

### Boot-time credential reads break the build

The image build runs `assets:precompile` **without the master key** (using
`SECRET_KEY_BASE_DUMMY=1`), so encrypted credentials can't be decrypted at build time.
Any code that reads a credential or a required ENV var **at boot** must tolerate its
absence during the build. We guard these with `ENV["SECRET_KEY_BASE_DUMMY"]`:

- `config/environments/production.rb` → `FRONTEND_URL`
- `config/initializers/devise.rb` → `devise_jwt_secret_key!`

If you add another boot-time credential/ENV read and the build fails with a `KeyError`,
apply the same guard.

---

## What's running

- HTTPS JSON API (Devise + JWT for the Flutter clients, with rotating refresh tokens)
- Devise-gated web backoffice for authoring the card catalog
- The Flutter web app, served by Rails from the same image
- PostgreSQL with all app tables migrated
- Solid Queue / Cache / Cable on Postgres; transactional email via Postmark SMTP
- Persistent file uploads and rendered card images on Docker volumes
- HTTP→HTTPS redirect, HSTS, secure cookies (`force_ssl`), Rack::Attack throttling
- Nightly off-site database backups — see [`DATA_AND_BACKUPS.md`](./DATA_AND_BACKUPS.md)
