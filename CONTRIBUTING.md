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
