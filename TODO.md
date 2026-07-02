# TODO / Roadmap / Leftovers

## Auth

- P3 (low priority): open password reset emails directly in the native
  Android/iOS app instead of a browser tab.
  The reset email links to `FRONTEND_URL/reset-password?reset_password_token=...`,
  which works everywhere today (the frontend is available on web, Android,
  and iOS): on web it loads the app directly, on Android/iOS it opens the
  phone's browser. To make Android/iOS jump straight into the installed app,
  the link needs to become a verified Android App Link / iOS Universal Link,
  which requires a real production domain (`FRONTEND_URL` is still
  `localhost`) hosting `assetlinks.json` / `apple-app-site-association`. See
  `carnevale`'s `TODO.md` for the matching frontend-side note.

## Roadmap

3. Full game/match tracking (big chunk of work).
4. Card versioning.
5. Share lists via QR code.
