# Carnevale — Architecture & Features

## Tech Stack

### Backend (Rails)
- **Full Rails** — a JSON REST API under `/api/v1` for the clients, plus server-rendered
  views for the Devise-gated `/backoffice` where the card catalog is authored
- **Devise + devise-jwt** — authentication. Login returns a short-lived access JWT (1h)
  and a rotating refresh token (30d); the client sends the access token with every request
  and exchanges the refresh token at `POST /api/v1/token` when it expires
- **Action Cable** — WebSocket server for live game sessions (`solid_cable` in production)
- **PostgreSQL** (dev and prod), also backing Solid Queue / Cache / Cable

### Frontend (Flutter)
- **dio** — HTTP client for all REST calls; JWT interceptor attaches the token automatically
- **web_socket_channel** — WebSocket client for live game sessions
- **shared_preferences** — local cache only (not source of truth once the backend is live)

---

## Communication

| Use case | Protocol |
|---|---|
| Login / register | REST |
| Browse cards | REST |
| Create / edit gangs | REST |
| Sync gangs across devices | REST |
| Live game session | WebSocket (Action Cable) |

---

## Features

### Auth
- Register / login
- Session shared across web and mobile (JWT)

### Cards
- Browse all profiles
- Filter by faction
- View full card (front/back)

### Gangs
- Create a gang (name, faction, point limit — default 100)
- Add/remove profiles from the gang's faction
- Gangs synced across all user devices via the backend

### Game session
- User A creates a game: picks scenario and Ducat limit (deployment zones are agreed at the table, not in-app)
- A unique join code is generated and shared with User B
- User B joins with the code
- Both users pick their gang (its faction comes with the list)
- Both users can see each other's gang and models
- Once the game starts, each player can track per-model:
  - HP (life points)
  - Will points
  - Command points
- Each player records their own hidden objectives privately (not visible to the opponent)
- All state changes are pushed in real time via WebSocket — no polling

---

## Source of Truth

- The **server is always the source of truth**
- The Flutter app sends updates to the server; the server broadcasts to all connected clients
- Local state in the app is optimistic (applied immediately) and reconciled with the server response
