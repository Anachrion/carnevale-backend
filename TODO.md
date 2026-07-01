# TODO / Roadmap / Leftovers

## Auth

- Password reset email links to the web page, not the app.
  The reset email link still points at the web `/users/password/edit` page
  (Devise's default), not a deep link back into the app. That's fine if the
  app just needs to trigger and complete the reset via its own API calls, but
  if you want the whole thing to stay in-app (no browser hop), the mailer
  template would need a follow-up change to link back into the app instead.
