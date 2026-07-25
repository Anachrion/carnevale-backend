# Play Store Publishing

How the Carnevale Android app gets from this repo to a public Google Play listing.
The Flutter app lives in the sibling repo `~/Workspace/carnevale`; this doc is here
because the release checklist touches the backend too (privacy policy hosting, a
demo account for Google's reviewers, production readiness).

- **Play Console:** app `Carnevale`, developer account `6427498619610644613`
- **Package name:** `app.carnevale.mobile` — **permanent** once the first bundle is
  uploaded. It cannot be changed afterwards; a different package name means a new
  listing with zero installs and zero reviews.
- **Account type:** personal (not organisation) → **closed testing with 12+ testers
  for 14 continuous days is mandatory** before production access can even be requested.

---

## The critical path

Most of the work parallelises; only one thing is pure calendar time.

```
privacy policy live ─┐
declarations filled ─┼─→ AAB to closed track ─→ ⏳ 14-day test ─→ production
store assets ready ──┘                             (immovable)      application
                                                                        ↓
                                                                   review (days
                                                                   to ~2 weeks)
```

Realistically **3–5 weeks** to public availability. Only the left-hand column can
be compressed, so start the 14-day clock as early as possible.

---

## 1. Signing keys

Two different keys are involved. This trips people up, so:

| Key | Held by | Role |
|---|---|---|
| **Upload key** | us — in Infisical (`/android` folder, Production) | signs the AAB we upload to Play |
| **App signing key** | Google | signs the APKs actually delivered to devices |

Play App Signing is mandatory for new apps, so Google generates and holds the second
key. Our upload key only proves to Play that an upload is genuinely from us.

**Status: already created** (18 July 2026).

- Keystore + passwords live in **Infisical** (project `carnevale`, Production, `/android`
  folder): `ANDROID_UPLOAD_KEYSTORE_B64` (base64 of the .jks), `ANDROID_UPLOAD_STORE_PASSWORD`,
  `ANDROID_UPLOAD_KEY_ALIAS`. Alias `upload`.
- Certificate: `CN=Carnevale, OU=Anachrion, O=Carnevale, C=FR`
- `~/Workspace/carnevale/bin/android-signing` materializes `android/key.properties`
  and `android/upload-keystore.jks` (both git-ignored) from those secrets. Gradle reads
  `key.properties` from there. Run before a release build:

  ```sh
  infisical run --env=prod --path=/android -- bin/android-signing
  ```

  There is no longer a standalone `~/carnevale-upload.jks` — Infisical is the source of
  truth, and the working copy is regenerated on demand.

> **Do not regenerate it.** `android/app/build.gradle.kts` silently falls back to
> the *debug* keys when `key.properties` is missing, which produces an AAB Play will
> reject. If a build ever seems mis-signed, verify rather than re-create:
>
> ```sh
> jarsigner -verify -verbose -certs <path>.aab | grep "CN="
> # expect CN=Carnevale …   (CN=Android Debug means key.properties wasn't picked up)
> ```

The `.jks` and its passwords are backed up in Infisical (see above), so losing the
laptop no longer loses the key. Even if it were lost, it's recoverable — Google
supports an upload-key reset precisely because they hold the real signing key — but
that costs days of support turnaround, so Infisical is the fast path.

## 2. Building the bundle

Play requires an **AAB** (App Bundle), not an APK. An AAB is a publishing format:
Play generates a per-device APK from it at install time, shipping only the ABI,
screen density and languages that device needs. APKs remain the format for
sideloading and the GitHub prerelease flow — an AAB cannot be installed directly.

```sh
cd ~/Workspace/carnevale
infisical run --env=prod --projectId 5924d033-10b3-4a0a-abb0-bb6766ede058 -- \
  flutter build appbundle --release \
    --dart-define=API_HOST=carnevale-app.com \
    --dart-define=API_USE_TLS=true \
    --dart-define=API_KEY="$API_KEY"
# → build/app/outputs/bundle/release/app-release.aab
```

**The `--dart-define` flags are mandatory.** `lib/services/api_client.dart` defaults
to `localhost:3000`; omit them and the store build cannot reach the backend at all.
Store builds point at `carnevale-app.com`, never at the `sslip.io` address used for
alpha APKs.

`API_KEY` comes from Infisical (backend project, Production). Omit it and the build
gets **401 on every request** — the backend requires `X-Api-Key` once `API_KEY` is set
there. `--projectId` is needed because the frontend repo has no `.infisical.json`.

After switching branches, run `flutter clean` first so no stale generated sources
end up in a bundle that becomes permanent on upload.

**Version codes:** `pubspec.yaml` carries `version: <name>+<code>`. Play rejects any
upload whose code is not strictly greater than the previous one. Bump the `+N` on
every single upload, including re-uploads to the same track.

## 3. Store listing assets

| Asset | Spec | Status |
|---|---|---|
| App icon | 512×512 PNG, 32-bit | ✅ downscale of `assets/icon/carnevale_icon.png` (1024²) |
| Feature graphic | 1024×500 PNG/JPG, no transparency | ✅ generated (navy `#021f49` + gold `#EEBE4F`, Cinzel) |
| Phone screenshots | 2–8, 320–3840 px, 16:9 or 9:16 | ❌ **outstanding** |
| Short description | ≤80 chars | ❌ |
| Full description | ≤4000 chars | ❌ |

Brand values live in `~/Workspace/carnevale/flutter_launcher_icons.yaml`
(background `#021f49`); the gold `#EEBE4F` is sampled from the icon foreground. The
app's typeface is **Cinzel** (via `google_fonts`, so there's no TTF in the repo —
fetch from Google Fonts when producing assets).

Screenshots must be real captures of the running app. There is currently **no
Android emulator configured** on the dev machine (`flutter emulators` finds none),
so this needs either an AVD created, a physical device, or Chrome at a phone
viewport via the Flutter web build.

Tablet screenshots are optional, but omitting them gets the app labelled "not
optimised for tablets" on those devices.

## 4. Declarations in Play Console

All mandatory; all block submission.

1. **Privacy policy URL** — must be live and public *before* submitting. Cheapest
   option is a static route on `carnevale-app.com`, which already serves the Flutter
   web app from Rails. It must accurately describe what we collect (accounts, email
   via auth) and must not contradict the data safety form.
2. **Data safety form** — declare collected data types, encryption in transit (yes,
   HTTPS), and deletion path. Mismatches with the privacy policy cause rejection.
3. **Content rating questionnaire** (IARC).
4. **Target audience** — declare 13+; any under-13 audience pulls in the whole
   Families Policy.
5. **Ads declaration** — none.
6. **App access — ⚠️ the most common rejection cause for this app.** Carnevale is
   login-gated, so reviewers *must* be given working credentials or they will reject
   it as unusable. Create a dedicated demo account on production and enter it here.
7. **Category, contact email** (published publicly), external marketing opt-out.

## 5. Closed testing — the 14-day clock

1. Create a closed track and upload the AAB.
2. Recruit **12+ testers**, each opted in through the tester opt-in link.
3. They must remain opted in for **14 continuous days**. Recruit 15+ — if the count
   dips below 12 the eligibility period can reset.
4. Testers should actually install and use the app; a bare opt-in is not reliably
   sufficient.

## 6. Production access application

Unlocks only after step 5 completes. Google asks how testers were recruited, what
feedback came back, and what changed as a result — they expect substantive answers.
Then production review: days to a couple of weeks for a first-time developer.

---

## Backend readiness

A public listing points strangers at a single Hetzner CX23. Before the closed test
widens, worth confirming:

- **Rate limiting** on the API, particularly auth endpoints.
- **Graceful degradation** in the app when the backend is down or slow — a store
  reviewer hitting a hung request will fail the review.
- **Demo account** exists on production and survives data resets (see §4.6).
- **Catalog backups** — see [`DATA_AND_BACKUPS.md`](./DATA_AND_BACKUPS.md); the
  catalog is DB-authored in production with no automated blob backup.

## Related

- [`DEPLOY_OVERVIEW.md`](./DEPLOY_OVERVIEW.md) — how backend and web app ship
- [`DATA_AND_BACKUPS.md`](./DATA_AND_BACKUPS.md) — catalog snapshot/restore
