# Deploy Overview

A short, big-picture guide to how Carnevale ships to production — backend **and**
frontend. For the deep backend detail (hosting rationale, hardening, known
limitations) see [`DEPLOYMENT.md`](./DEPLOYMENT.md).

- **Live URL:** https://carnevale-app.com
- **API:** `…/api/v1/…` · **Web app:** `/` (bundle under `/app/`) · **Backoffice:** `/backoffice`
- **Host:** one small Hetzner VM, everything as Docker containers.

---

## What is Kamal?

[Kamal](https://kamal-deploy.org) is the Rails 8 default deploy tool. It turns a
plain Linux box into something that deploys like a PaaS, with no proprietary
platform. On a deploy it:

1. **Builds** the Docker image locally (on your Mac).
2. **Pushes** it to GitHub Container Registry (`ghcr.io/anachrion/carnevale_backend`).
3. **SSHes** into the server, pulls the image, and swaps the running container with
   near-zero downtime.
4. Runs **kamal-proxy**, which terminates TLS (a free Let's Encrypt cert per host in
   `proxy.hosts`) and routes `:443 → :80` into the app container.

The entire configuration is one file: [`config/deploy.yml`](../config/deploy.yml).

### What runs on the server

| Container | Role |
|---|---|
| `carnevale_backend-web` | Rails 8 app (Puma + Thruster) — the API, web app, backoffice |
| `carnevale_backend-db` | PostgreSQL 17 accessory (data in a Docker volume) |
| `kamal-proxy` | TLS termination + routing |

There is no Redis: Action Cable, the job queue and the cache all run on Postgres via
`solid_cable` / `solid_queue` / `solid_cache`, and the Solid Queue worker runs inside
Puma (`SOLID_QUEUE_IN_PUMA`) rather than as its own container.

Persistent Docker volumes survive redeploys: `…_storage` (Active Storage uploads),
`…_db_data` (Postgres), `…_cards` (rendered card images).

---

## Deploying the backend

Prerequisites (one-time, on your Mac): **Docker running**, and the **Infisical CLI**
logged in against EU Cloud (`infisical login --domain https://eu.infisical.com`).
Secrets live in the `carnevale` project, Production environment.

Kamal builds from the **working tree** (not `git archive`), so that LFS card images
ship as real bytes. Run `git lfs pull` once so they're materialised, and **commit
your code changes** before deploying.

```bash
cd ~/Workspace/carnevale-backend
infisical run --env=prod -- kamal deploy
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
bin/release-web                                        # build + stage into public/app
infisical run --env=prod -- bin/release-web --deploy   # ...and run `kamal deploy` immediately

# or stage, then deploy manually:
bin/release-web
infisical run --env=prod -- kamal deploy
```

It builds with `--dart-define=API_HOST=carnevale-app.com --dart-define=API_USE_TLS=true
--dart-define=API_KEY=… --base-href=/app/`, so the web app talks to the live API over
HTTPS. Rails serves that bundle at the site root as well as at `/app/`, and at the
deep-link paths (`/reset-password`, `/join`) so emailed links land in the SPA. Override
the frontend location with `CARNEVALE_FRONTEND_DIR` if your checkout isn't at
`../carnevale`.

### Android → Google Play

The mobile app is built and published from the frontend repo, which has its own
`bin/publish-play`: it signs a release App Bundle with the upload keystore and uploads
it to a Play track (closed testing by default) through the Play Developer API.

```bash
# from the carnevale frontend repo
infisical run --env=prod --recursive -- bin/publish-play
```

`--recursive` matters: the script needs both the `/android` secrets (keystore, Play
service account) and the root `API_KEY`. See
[`PLAY_STORE_PUBLISHING.md`](./PLAY_STORE_PUBLISHING.md) for the keystore, the store
listing, and the release process around it.

Both the web and Android builds point at the same production API — bumping the API host
means updating it in `bin/release-web` **and** in `bin/publish-play`.

`API_KEY` must be baked in: the backend rejects requests without `X-Api-Key`. A build
made without it gets 401 on every request, and an installed APK **cannot be fixed
remotely** — testers have to install a new build. The older `sslip.io` host stays in
`config/deploy.yml` `proxy.hosts` purely so pre-`carnevale-app.com` alpha builds keep
resolving; it can be dropped once nobody is on one.

---

## Where the pieces live

| Path | What |
|---|---|
| `config/deploy.yml` | The entire Kamal config (committed) |
| `.kamal/secrets` | Secret *references* only — no real values (committed) |
| `.infisical.json` | Which Infisical project/environment this repo reads (committed) |
| Infisical → `carnevale` → Production | The real secret **values** |
| `bin/release-web` | Build + stage the Flutter web app for deploy |
| `docs/DEPLOYMENT.md` | Full backend deploy detail and rationale |
| `docs/DATA_AND_BACKUPS.md` | Sources of truth, catalog snapshots, nightly backups & restore |
| `docs/PLAY_STORE_PUBLISHING.md` | Getting the Android app onto Google Play |
| `~/Workspace/carnevale` | The Flutter frontend repo (separate) |
