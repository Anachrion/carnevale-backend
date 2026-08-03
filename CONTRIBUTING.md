# Contributing

Thanks for your interest in contributing to the Carnevale Companion backend!

## License of contributions

This project is licensed under the
[GNU Affero General Public License v3.0](LICENSE). By submitting a contribution
(a pull request, patch, or any other change), you agree that your contribution is
licensed under the same AGPL-3.0 — "inbound = outbound". You also confirm that the
contribution is your own work, or that you have the right to submit it under that
licence.

Note that the AGPL is a copyleft licence with a network clause: because this backend
is reached over a network, anyone who modifies it and serves it to users must offer
those users the source of their modified version. This is deliberate.

## Do not contribute third-party intellectual property

This is an unofficial fan project. It bundles Carnevale artwork, card data, rules
text, and marks that are the intellectual property of **TT Combat**, included with
their permission (see [NOTICE](NOTICE)). **That permission does not extend to
contributors.**

Please do **not** add, or base your contribution on, any third-party intellectual
property — including TT Combat material beyond what is already present, artwork,
text, data, or code — unless you have the right to submit it under AGPL-3.0. If
in doubt, open an issue first.

## Developer Certificate of Origin (sign-off)

We use the [Developer Certificate of Origin](https://developercertificate.org/)
(DCO) instead of a CLA. Every commit must be signed off, certifying that you wrote
the code or otherwise have the right to submit it under the project's license.

Add a sign-off line to each commit with `-s`:

```bash
git commit -s -m "Your message"
```

This appends a line matching your Git `user.name` and `user.email`:

```
Signed-off-by: Jane Doe <jane@example.com>
```

By signing off, you certify the DCO reproduced at the end of this file.

## Development

See the [README](README.md) for setup. Before opening a pull request:

- Run the test suite: `bundle exec rspec`
- Run the linter: `bundle exec rubocop`
- Keep changes focused, and match the style of the surrounding code.

New source files should carry the standard AGPL license header (see any existing
`.rb` file under `app/` for the exact text).

## Adding a new language

The backend serves English (the default and fallback) and French. The translated
text is what the API sends back to the Flutter app — validation errors, Devise's
auth messages — not the app's own UI strings, which live in the frontend repo. The
locale is negotiated per request from the `Accept-Language` header the client sends
(see `app/controllers/concerns/switches_locale.rb`); the backoffice is
English-only.

To add a language — Spanish (`es`) in the examples below:

**1. Check the gems cover it.** Most of the user-facing text comes from
[`rails-i18n`](https://github.com/svenfuchs/rails-i18n/tree/master/rails/locale)
(ActiveModel/ActiveRecord validation messages, dates, number formats) and
[`devise-i18n`](https://github.com/tigrish/devise-i18n/tree/master/rails/locales)
(sign-in/sign-up/reset-password messages). If your language isn't in both, the
missing pieces will silently fall back to English — still worth contributing, but
say so in the pull request.

**2. Register the locale** in `config/application.rb`:

```ruby
config.i18n.available_locales = %i[en fr es]
```

Use the bare language subtag. Locale negotiation matches on the primary subtag
only, so a request asking for `es-MX` resolves to `es`; a regional locale such as
`:"es-MX"` in `available_locales` would never be selected by a header.

**3. Add `config/locales/es.yml`** with the keys the app itself defines under `en:`
in `config/locales/en.yml`. Only app-specific keys belong here — framework and
Devise strings come from the gems above. Anything you leave out falls back to
English (`config.i18n.fallbacks`), so a partial translation is safe to merge.

**4. Mirror any Devise overrides.** `config/locales/devise.en.yml` overrides some
of devise-i18n's English wording (for example, the invalid-login message mentions
usernames). Where our text differs from upstream, add the matching keys to
`config/locales/devise.es.yml`; otherwise skip the file entirely and let
devise-i18n handle it.

**5. Add a spec.** `spec/requests/api/v1/locale_spec.rb` asserts that a request
with `Accept-Language` gets messages in that language. Add a case for yours,
following the French one.

Two known gaps, so you don't go hunting for them: the overridden Devise mailer
views in `app/views/devise/mailer/` are hardcoded English rather than translated,
and the backoffice ERB templates have no `t()` calls. Making either translatable is
a welcome contribution, but it's a separate change from adding a language — open
an issue first.

---

## Developer Certificate of Origin 1.1

```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```
