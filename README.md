# Carnevale Companion — Backend

A fan-made companion app for [Carnevale](https://ttcombat.com/collections/carnevale), TT Combat's
tabletop skirmish game set in a flooded, monster-haunted Venice.

The app carries the parts of a game that are tedious on paper: browsing the card catalog,
building a gang within a Ducat limit, and tracking a live two-player game — hit points, will,
command points and secret agendas — synchronised between both players' devices in real time.
The tabletop stays on the table; this handles the bookkeeping.

This repository is the **backend**: a Ruby on Rails server providing the JSON API, the
WebSocket layer for live games, and a web backoffice for authoring the card catalog.

> **Disclaimer:** This is an unofficial fan project, not affiliated with or endorsed by
> TT Combat.

---

## Links

| | |
|---|---|
| 🎬 **Walkthrough video** | [Carnevale App Walkthrough](https://www.youtube.com/watch?v=z1iAEC28lCA) — the fastest way to see what it does |
| 🌐 **Web app** | [carnevale-app.com](https://carnevale-app.com) |
| 📱 **Android** | [Google Play](https://play.google.com/store/apps/details?id=app.carnevale.mobile) — currently in **closed testing**, so the listing isn't public yet |
| 📦 **Frontend repo** | [Anachrion/carnevale](https://github.com/Anachrion/carnevale) — the Flutter client |
| 🎲 **The game itself** | [Carnevale by TT Combat](https://ttcombat.com/collections/carnevale) |

---

## What it does

**Catalog** — every profile, weapon, special rule and spell, browsable and filterable by
faction, with rendered card faces (front and back).

**Gang building** — create a gang against a faction and a Ducat limit, add and remove models,
with the list validated against the rules. Gangs sync across all of a player's devices.

**Live games** — one player creates a game and shares a join code; the other joins. Both pick
a gang, draw their agendas privately, and play. Every state change is pushed over WebSocket to
both clients, so there's no polling and no "who has the right numbers" argument. A player can
close the app, switch devices, sign back in and pick up exactly where they were.

**Backoffice** — a Devise-gated web UI where the card catalog is authored and card images are
rendered.

---

## Architecture at a glance

| Layer | Technology |
|---|---|
| Language | Ruby 3.4.9 |
| Framework | Rails 8.1.3 (full stack — JSON API *and* server-rendered backoffice) |
| Database | PostgreSQL 17 |
| Auth | Devise + devise-jwt — short-lived access tokens with rotating refresh tokens |
| Realtime | Action Cable over `solid_cable` |
| Jobs / cache | Solid Queue / Solid Cache — Postgres-backed, no Redis |
| Client | Flutter (separate repo), talking REST + WebSocket |

The server is the single source of truth. Clients apply changes optimistically and reconcile
against the server's response, and the server broadcasts a full state snapshot rather than
deltas — which is what makes reconnecting from anywhere free.

---

## Documentation

| Doc | What's in it |
|---|---|
| [`ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Stack, features, and the source-of-truth model |
| [`GAME_SETUP_FLOW.md`](docs/GAME_SETUP_FLOW.md) | The two-player setup flow in detail — sequence diagram, state machine, endpoints |
| [`DEPLOY_OVERVIEW.md`](docs/DEPLOY_OVERVIEW.md) | How the backend, web app and Android build ship — start here |
| [`DEPLOYMENT.md`](docs/DEPLOYMENT.md) | Backend deploy detail: Kamal, the hosting rationale, and the two procedures that are easy to get wrong |
| [`DATA_AND_BACKUPS.md`](docs/DATA_AND_BACKUPS.md) | Which copy of a thing wins, catalog snapshots, nightly backups and restore |

---

## Getting started

**Requirements:** Ruby 3.4.9, Docker (for PostgreSQL), Bundler.

```bash
bundle install
docker compose up -d                      # PostgreSQL 17, published on port 5433
bin/rails db:create db:migrate db:seed
bin/rails server
```

The API is then at `http://localhost:3000/api/v1`, and the backoffice at `/backoffice`.

Card artwork is stored in Git LFS — if images come out missing, run `git lfs pull`.

### Development

```bash
bundle exec rspec        # test suite (RSpec)
bin/rubocop              # style
bin/ci                   # style + security audits (Brakeman, bundler-audit) + seed check
```

---

## Deployment

Production runs on a single VM, deployed with [Kamal](https://kamal-deploy.org) — the Rails
app, PostgreSQL and the TLS proxy all as Docker containers, with the Flutter web build served
from the same image. See [`DEPLOY_OVERVIEW.md`](docs/DEPLOY_OVERVIEW.md) for the whole picture
and [`DEPLOYMENT.md`](docs/DEPLOYMENT.md) for the details.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — in particular the section on third-party intellectual
property, which is the rule that matters most here.

---

## License

The **source code** in this repository is licensed under the
[GNU Affero General Public License v3.0](LICENSE).

This is a network-served application, so §13 matters: if you modify it and let users interact
with it over a network, you must offer those users the source of your modified version.
(Versions published before 2026-08-03 were Apache 2.0; that grant still stands for them.)

This project bundles artwork, card data, rules text, faction symbols, and other content that is
the intellectual property of **TT Combat** ("Carnevale"). That content is **not** covered by the
AGPL — it is included with TT Combat's permission and remains © TT Combat, all rights reserved.
See [NOTICE](NOTICE) for the full carve-out. If you reuse this code, you are responsible for
removing that content or obtaining your own permission from TT Combat.

This is an unofficial fan project, not affiliated with or endorsed by TT Combat.
