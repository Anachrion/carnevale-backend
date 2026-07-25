# Availability & DoS resilience

Written 2026-07-25. Scope: keeping the single production box responsive. Data
confidentiality is **not** the concern here — see the note at the bottom for why.

---

## The three problems people call "DDoS"

They have different fixes, and conflating them wastes effort.

| Kind | What it looks like | Where it must be solved |
|---|---|---|
| **Volumetric** | Enough raw traffic to saturate the network link | Upstream only. Nothing in Rails can help |
| **Application-layer flood** | Many valid-looking requests, e.g. a scraper with no backoff | Rate limiting — but see the caveat below |
| **Accidental self-DoS** | A client retry loop, a runaway job, one slow query | Timeouts and sane limits |

The third is by far the most likely for an app this size, and the cheapest to fix.
The first is the least likely and the one we can do least about.

---

## Current posture

| | |
|---|---|
| Host | One Hetzner CX23 — **2 vCPU, 3.8 GB RAM** |
| Concurrency | `WEB_CONCURRENCY=2` × 3 threads = **6 concurrent requests** |
| Rate limiting | Rack::Attack, 300 req/300s per IP; 10/60s on login/signup/password |
| Throttle counters | `solid_cache_store` → **Postgres, same box** |
| Background jobs | Solid Queue runs **inside Puma** (`SOLID_QUEUE_IN_PUMA`) — jobs compete with web requests for the same 2 cores |
| Static files | Served by Thruster from `public/`, never enter Rails |
| Postgres | Bound to `127.0.0.1` — not reachable from the internet ✅ |
| Request timeout | **None** — not in Puma, not in kamal-proxy |
| Monitoring | **None** |

Two things follow from this table that aren't obvious:

- **Rack::Attack fires too late to stop a flood.** It is Rails middleware, so a request
  already traversed kamal-proxy → Thruster → Puma and is occupying one of six threads
  before the limiter can reject it. It stops a *misbehaving client*; it does not stop
  volume. Each check also reads/writes Postgres, so under load the limiter competes with
  the database for the same cores.
- **Card images don't count against the throttle.** Thruster serves `public/` directly,
  so the 1628 card files never reach Rack::Attack. Only API calls are throttled.

---

## Steps, in priority order

### 1. Monitoring — do this first

There is currently no way to learn about an outage except someone reporting it. A free
uptime check (UptimeRobot, Better Stack) hitting `https://carnevale-app.com/up` every
minute turns "mysterious outage" into an alert with a timestamp.

`/up` is deliberately exempt from throttling (`UNTHROTTLED_PATHS` in
`config/initializers/rack_attack.rb`), so a monitor can poll it freely.

**Effort:** ~5 minutes, browser signup. **Every step below is worth less without it.**

### 2. A request timeout

Nothing bounds how long a request may run. One pathological query pins one of six
threads indefinitely; six of those and the app is down with no attacker involved.

Add the `rack-timeout` gem with a ~15s limit. This is the single most likely real
failure mode, and it is cheap.

### 3. Tune the throttles

`THROTTLE_REQ_LIMIT` / `THROTTLE_REQ_PERIOD` are already environment variables, so this
is configuration, not code (set them in Infisical — see [DEPLOYMENT.md](DEPLOYMENT.md)).

300 req / 300s is generous. **Shorten the period rather than dropping the limit:** the
app fetches ~7 catalog endpoints at startup, so a low absolute limit would break normal
use. Something like `120` / `60` tolerates the startup burst while still capping
sustained abuse.

### 4. Hetzner Cloud Firewall

Free, configured in Hetzner's console. Allow 80/443 from anywhere; restrict 22 to your
own IP. This is surface reduction, not DoS protection — but it is free and takes minutes.
Postgres already needs nothing (it is bound to localhost).

### 5. Cloudflare free tier — only if justified

The only real answer to volumetric traffic. Two things to know before bothering:

- **It is useless without an origin firewall.** If `62.238.30.155` still accepts :443
  from anywhere, the CDN is bypassed by connecting directly. `62.238.30.155.sslip.io`
  resolves to the box via a public wildcard resolver whether or not Kamal still serves
  that host, and the historical `A` record for `carnevale-app.com` is already recorded by
  passive-DNS services. Hiding an origin after the fact never fully works — the firewall
  is the actual control.
- **The real payoff is caching, not protection.** The 1628 card images already carry
  `public, max-age=1year, immutable`, so a CDN serves nearly all of that from edge cache.
  That is the largest bandwidth item, entirely offloaded.

**Hetzner already includes network-level DDoS mitigation on all servers**, so for a niche
app the volumetric case is largely covered. Add Cloudflare for bandwidth or if actually
targeted — not pre-emptively.

---

## Don't

- **Don't raise `WEB_CONCURRENCY`.** With 2 vCPUs shared between Puma, Postgres and Solid
  Queue, more workers means more contention, not more throughput.
- **Don't mark API responses `public:` to reduce load.** Thruster shared-caches those by
  URL and bypasses the `X-Api-Key` check entirely — see the comment in
  `app/controllers/concerns/authenticates_client.rb`.

---

## Recommendation

Do **1–3**. They are an afternoon's work, they address the failure that is actually
likely, and they help regardless of whether anyone ever attacks. Do 4 whenever
convenient. Treat 5 as conditional.

---

## Why data exposure isn't in scope

Deliberate, not an oversight. The catalog endpoints are protected only by `API_KEY`,
which is extractable in one request from the public web bundle at `/app/main.dart.js`,
and the card art under `public/` is not gated at all. That is accepted: the data is
published game content for a niche tabletop game, with no meaningful personal
information. User-owned data (lists, games, accounts) sits behind real per-user Devise
JWT auth and is unaffected by the shared key being public.
