# Play Store Publishing

How the Carnevale Android app gets from this repo to a public Google Play listing.
The Flutter app lives in the sibling repo `~/Workspace/carnevale`; this doc is here
because the release checklist touches the backend too (privacy policy hosting, a
demo account for Google's reviewers, production readiness).

- **Play Console:** app `Carnevale` (the developer account ID is in Infisical, not here)
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

## 2. Building and uploading the bundle

Play requires an **AAB** (App Bundle), not an APK. An AAB is a publishing format:
Play generates a per-device APK from it at install time, shipping only the ABI,
screen density and languages that device needs. APKs remain the format for
sideloading — an AAB cannot be installed directly.

`bin/publish-play` in the frontend repo does the whole trip: it materializes the
keystore, builds a signed release bundle pointed at production, and uploads it to a
Play track via the Play Developer API.

```sh
cd ~/Workspace/carnevale
infisical run --env=prod --recursive -- bin/publish-play
# --track NAME    Play track (default: alpha = closed testing)
# --status STATUS completed | draft | inProgress | halted
# --dry-run       build + sign only, no upload
```

**`--recursive` is required.** The script needs the `/android` secrets (upload keystore,
Play service account JSON) *and* the root `API_KEY` from the backend project, which live
at different paths in Infisical.

**The build-time defines are mandatory** and the script supplies them. The Flutter client
defaults to `localhost:3000`, so a bundle built without `API_HOST` cannot reach the
backend at all; one built without `API_KEY` gets **401 on every request**, because the
backend requires `X-Api-Key`. Store builds point at `carnevale-app.com`
(override with `PLAY_API_HOST` / `PLAY_API_USE_TLS` if you ever need to).

**Version codes** are handled for you: `versionName` comes from `pubspec.yaml`, and
`versionCode` is the git commit count — strictly increasing and gap-free, with no manual
bookkeeping. Play rejects any upload whose code is not greater than the previous one, so
this matters even for a re-upload to the same track; just make a commit.

After switching branches, run `flutter clean` first so no stale generated sources
end up in a bundle that becomes permanent on upload.

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

A public listing points strangers at a single small VM. Before the closed test widens,
worth confirming:

- **Rate limiting** on the API, particularly auth endpoints. (Rack::Attack is in place;
  the limits are environment variables.)
- **Graceful degradation** in the app when the backend is down or slow — a store
  reviewer hitting a hung request will fail the review.
- **Demo account** exists on production and survives data resets (see §4.6).
- **Backups** — see [`DATA_AND_BACKUPS.md`](./DATA_AND_BACKUPS.md). Player data is backed
  up nightly off-site; the catalog is DB-authored in production and snapshotted to git by
  hand, so run `bin/catalog-snapshot` before a release if you've been authoring.

## Related

- [`DEPLOY_OVERVIEW.md`](./DEPLOY_OVERVIEW.md) — how backend and web app ship
- [`DATA_AND_BACKUPS.md`](./DATA_AND_BACKUPS.md) — sources of truth, snapshots, restore
