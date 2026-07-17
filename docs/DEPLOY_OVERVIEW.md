# Deploy Overview

A short, big-picture guide to how Carnevale ships to production — backend **and**
frontend. For the deep backend detail (hosting rationale, hardening, known
limitations) see [`DEPLOYMENT.md`](./DEPLOYMENT.md).

- **Live URL:** https://62.238.30.155.sslip.io
- **API:** `…/api/v1/…` · **Web app:** `…/app/` · **Backoffice:** `…/backoffice`
- **Host:** one Hetzner CX23 VM (`62.238.30.155`), everything as Docker containers.

---

## What is Kamal?

[Kamal](https://kamal-deploy.org) is the Rails 8 default deploy tool. It turns a
plain Linux box into something that deploys like a PaaS, with no proprietary
platform. On a deploy it:

1. **Builds** the Docker image locally (on your Mac).
2. **Pushes** it to GitHub Container Registry (`ghcr.io/anachrion/carnevale_backend`).
3. **SSHes** into the server, pulls the image, and swaps the running container with
   near-zero downtime.
4. Runs **kamal-proxy**, which terminates TLS (free Let's Encrypt cert on the
   `sslip.io` host) and routes `:443 → :80` into the app container.

The entire configuration is one file: [`config/deploy.yml`](../config/deploy.yml).

### What runs on the server

| Container | Role |
|---|---|
| `carnevale_backend-web` | Rails 8 app (Puma + Thruster) — the API, web app, backoffice |
| `carnevale_backend-db` | PostgreSQL 17 accessory (data in a Docker volume) |
| `carnevale_backend-redis` | Redis 7 accessory — Action Cable pub/sub only, no persistence |
| `kamal-proxy` | TLS termination + routing |

Persistent Docker volumes survive redeploys: `…_storage` (Active Storage uploads),
`…_db_data` (Postgres), `…_cards` (rendered card images).

---

## Deploying the backend

Prerequisites (one-time, on your Mac): **Docker running**, and a populated
`.kamal/deploy.env` (git-ignored secrets — see onboarding notes / Bitwarden).

Kamal builds from the **working tree** (not `git archive`), so that LFS card images
ship as real bytes. Run `git lfs pull` once so they're materialised, and **commit
your code changes** before deploying.

```bash
cd ~/Workspace/carnevale-backend
source .kamal/deploy.env && kamal deploy
```

### Everyday commands

```bash
kamal logs -f        # tail app logs
kamal console        # rails console on the server
kamal shell          # bash inside the app container
kamal dbc            # rails dbconsole
kamal rollback       # revert to the previous image
kamal app boot       # restart the app container
```

(These are aliases defined at the bottom of `config/deploy.yml`.)

---

## Deploying the frontend

The Flutter frontend lives in a **separate repo** (`~/Workspace/carnevale`, sibling
to this one). It ships two ways:

### Web app → served by Rails at `/app/`

[`bin/release-web`](../bin/release-web) compiles the Flutter **web** build with the
production API host baked in and drops it into `public/app` (git-ignored — it's a
build artifact). The next Kamal deploy ships it inside the image.

```bash
# from carnevale-backend/
bin/release-web            # build + stage into public/app
bin/release-web --deploy   # ...and run `kamal deploy` immediately

# or stage, then deploy manually:
bin/release-web
source .kamal/deploy.env && kamal deploy
```

It builds with `--dart-define=API_HOST=62.238.30.155.sslip.io
--dart-define=API_USE_TLS=true --base-href=/app/`, so the web app talks to the live
API over HTTPS. Override the frontend location with `CARNEVALE_FRONTEND_DIR` if your
checkout isn't at `../carnevale`.

### Android APK → GitHub prereleases

The mobile app is built from the frontend repo and published as **prereleases** on
the private `Anachrion/carnevale` repo:

```bash
# from the carnevale frontend repo/
flutter build apk \
  --dart-define=API_HOST=62.238.30.155.sslip.io \
  --dart-define=API_USE_TLS=true
```

Both the web and APK builds point at the same production API — bumping the API host
means updating it in `bin/release-web` **and** the APK build command.

---

## Where the pieces live

| Path | What |
|---|---|
| `config/deploy.yml` | The entire Kamal config (committed) |
| `.kamal/secrets` | Secret *references* only — no real values (committed) |
| `.kamal/deploy.env` | The real secret **values** (git-ignored) |
| `bin/release-web` | Build + stage the Flutter web app for deploy |
| `docs/DEPLOYMENT.md` | Full backend deploy detail, rationale, and TODOs |
| `docs/DATA_AND_BACKUPS.md` | Catalog snapshots & the backup gap |
| `~/Workspace/carnevale` | The Flutter frontend repo (separate) |
