# Carnevale Backend

Backend server for [Carnevale](https://github.com/Anachrion/carnevale), a fan-made mobile app for the board game [Carnevale](https://ttcombat.com/pages/carnevale).

Built with Ruby on Rails. Serves both a JSON API for the Flutter app and a backoffice interface.

> **Disclaimer:** This is an unofficial fan project, not affiliated with or endorsed by TT Combat.

## Requirements

- Ruby 3.4.9
- PostgreSQL 17 (via Docker)
- Bundler

## Setup

**1. Install dependencies**

```bash
bundle install
```

**2. Start the database**

```bash
docker compose up -d
```

**3. Create and seed the database**

```bash
bin/rails db:create db:migrate db:seed
```

**4. Start the server**

```bash
bin/rails server
```

## Stack

| Layer    | Technology          |
|----------|---------------------|
| Language | Ruby 3.4.9          |
| Framework| Rails 8.1.3         |
| Database | PostgreSQL 17        |
| Runtime  | rbenv               |

## License

The **source code** in this repository is licensed under the [Apache License 2.0](LICENSE).

This project bundles artwork, card data, rules text, faction symbols, and other content that is the intellectual property of **TT Combat** ("Carnevale"). That content is **not** covered by the Apache License — it is included with TT Combat's permission and remains © TT Combat, all rights reserved. See [NOTICE](NOTICE) for the full carve-out. If you reuse this code, you are responsible for removing that content or obtaining your own permission from TT Combat.

This is an unofficial fan project, not affiliated with or endorsed by TT Combat.
