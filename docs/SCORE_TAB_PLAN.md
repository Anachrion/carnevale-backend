# Score Tab — Implementation Plan

> **Status: implemented.** The Score tab has shipped (`lib/screens/score_tab.dart` in the
> app; agenda draw/score/discard/confirm, the mulligan window, and turn advance/rewind on the
> backend). This document is kept as the historical design plan; it is no longer a to-do.

A **Score** tab in the in-progress game page (first tab, before "My Models" and the
opponent tab). It shows the scenario, the score, the turn counter, and each player's
agendas (in hand / scored / discarded), and lets a player draw, score, and discard
agendas and advance the turn.

Most of the backend already exists (`Encounter::AgendaDeck`, `AgendaEvent`,
`GamesController` draw/score/discard/advance endpoints, `PlayerSerializer`). This plan
covers the gaps: a **structured agenda-rule model** on the scenario, **Secret-aware
opponent visibility**, an **initial-draw mulligan**, and the **Flutter UI**.

Backend repo: `~/Workspace/carnevale-backend` · Frontend repo: `~/Workspace/carnevale`

---

## Agenda rules (canonical, from the rulebook)

The five agenda special rules are a fixed, enumerated set (rulebook p.36):

| Rule | Effect | This round |
| --- | --- | --- |
| `cycle` | Scoring an agenda immediately draws a replacement. | **Enforced** |
| `secret` | Agendas are hidden from the opponent **until achieved**; without it, all agendas are open. | **Enforced** |
| `double` | On achieving, may keep in play instead of scoring; achieving again scores double, else nothing. | Display-only badge |
| `secondary` | Must achieve ≥1 agenda to score **any** VP in the game from any source. | Display-only badge |
| `total` | Must achieve **all** agendas or score no VP from them (primary objective still scores). | Display-only badge |

`double` / `secondary` / `total` change how VP totals are computed (`Player#score`) and are a
larger follow-up; this round shows them as badges but keeps flat **1 VP per scored agenda**.

### Opponent visibility model

From the Secret rule ("keep them secret from your opponent **until they're achieved**") and the
Agendas doc mulligan rule ("if there are any that are completely impossible or duplicated, discard
them and draw replacements"):

| Agenda state | Visible to opponent? |
| --- | --- |
| **Scored** (achieved) | **Always** — revealed once achieved |
| **Discarded** (mulligan or in-play) | **Always** — thrown away; opponent must see it to agree it's unachievable |
| **Hand** (drawn, unresolved) | Only when the scenario is **not** `secret` |

So under Secret, the opponent sees your scored + discarded agendas but **not your current hand**;
without Secret, they see everything.

### Mulligan & the "agree it's unachievable" step

- After the initial draw, a player may discard **impossible or duplicated** agendas and draw
  replacements. Modeled as a new discard origin `unachievable` (used during the `agenda_draw`
  phase), which discards + draws a replacement.
- **Decision: option A (table agreement).** The app tracks the physical game and does not referee
  (consistent with deployment zones, turn order, roll-offs). It lets a player discard + redraw and
  shows the discard to the opponent; the players agree verbally at the table. **No digital
  approval handshake** is built.

---

## Phase 1 — Backend: structural scenario rule model

Replaces the fragile free-text parsing of the `agendas` array (B-P2-11) with structured fields.

1. **Migration** — add to `scenarios`:
   - `agenda_rules` — `json`, `null: false`, `default: []` (subset of the five rule keywords).
   - `agenda_count` — `integer`, `null: false`, `default: 3` (initial hand size).
   - Keep the existing `agendas` free-text array as human-readable display text.
2. **`Catalog::Scenario`**
   - `AGENDA_RULES = %w[cycle secondary double secret total].freeze`.
   - Validate `agenda_rules` is a subset of `AGENDA_RULES`.
   - Predicate helpers: `secret_agendas?`, `cycle_agendas?`, `double_agendas?`,
     `secondary_agendas?`, `total_agendas?`.
   - Replace `initial_agenda_count` (string parse) with the `agenda_count` column.
3. **`Encounter::AgendaDeck#draw_initial`** — read `@game.scenario.agenda_count`.
4. **Seeds** (`db/seeds/scenarios.rb`) — add explicit `agenda_rules` + `agenda_count` per scenario;
   keep `agendas` text. Current mapping:
   | Scenario | `agenda_count` | `agenda_rules` |
   | --- | --- | --- |
   | Gang War | 3 | `["double"]` |
   | Secure Arms | 5 | `["secondary"]` |
   | Acquisition | 3 | `["secret", "cycle", "double"]` |
   | Take What is Theirs | 3 | `["cycle"]` |
   | Street Fight | 3 | `[]` |
5. **Specs** — `Catalog::Scenario` predicates + subset validation; seed integrity
   (every scenario's `agenda_rules ⊆ AGENDA_RULES`).

## Phase 2 — Backend: visibility, Cycle, mulligan

6. **`ScenarioSerializer`** — expose `agenda_rules` (array) and `agenda_count`.
7. **`PlayerSerializer`** — implement the visibility table:
   - Add a `secret` flag (passed down from `GameSerializer`, which has `game.scenario`).
   - `agendas` (hand): shown for self, or for the opponent only when **not** secret; else `[]`.
   - `agenda_history`: for self or non-secret → full history; for the opponent under secret →
     filter to **resolved events only** (`scored` + `discarded`) so the hand doesn't leak via
     `drawn` events.
8. **`GameSerializer`** — pass `secret_agendas: game.scenario.secret_agendas?` into each
   `PlayerSerializer`. Scenario is already preloaded in the games index (`includes(game: [:scenario, …])`),
   so no N+1.
9. **`Encounter::AgendaEvent`** — extend discard origins:
   `ORIGINS_BY_ACTION["discarded"] = %w[unachievable special_rule command_point]`.
10. **`Api::V1::GamesController`**
    - `#discard_agenda` — also allow the `agenda_draw` status when origin is `unachievable`
      (mulligan + redraw); keep the `in_progress` path for `special_rule` / `command_point`.
    - `#score_agenda` / `AgendaDeck#score` — auto-recycle when `@game.scenario.cycle_agendas?`
      instead of relying on a client `recycle` flag. (Keep `recycle` on discard for special-rule /
      command-point redraws, which are not Cycle.)
11. **`doc/openapi.yaml`** — add `agenda_rules` + `agenda_count` to the scenario schema; update the
    `agendas` / `agenda_history` field descriptions to reflect the new opponent-visibility rules;
    add `unachievable` to the discard origin enum; drop the score `recycle` body param.
12. **Specs (request + serializer)** — visibility matrix (secret vs. open; opponent sees
    scored + discarded but not hand under secret); Cycle auto-draw on score; mulligan discard +
    redraw during `agenda_draw`.

## Phase 3 — Frontend: API client + service (`~/Workspace/carnevale`)

13. **Regenerate the API client** from the updated `doc/openapi.yaml` (per the project's OpenAPI
    generation step). Verify new fields land on `Scenario` (`agendaRules`, `agendaCount`) and the
    discard input enum.
14. **`lib/services/game_service.dart`** — add:
    - `scoreAgenda(gameId, agendaId)`
    - `discardAgenda(gameId, agendaId, {required origin})`
    - `advanceTurn(gameId)`
    - `discardUnachievable(gameId, agendaId)` (origin `unachievable`, for the initial draw)
    - extend `drawAgendas(gameId, {String? origin})` — send the origin for in-play draws
      (`special_rule` / `command_point`); no body for the opening draw.

## Phase 4 — Frontend: UI

15. **`lib/screens/game_session_screen.dart` — `_buildInProgressPhase`** — replace the fixed
    two-tab `GangsTabView` with a **three-tab** controller: **Score | My Models | Opponent**
    (Score first). Reuse the existing gang tab bodies for the latter two.
16. **New `ScoreTab` widget:**
    - **Header** — scenario name + primary objective; `Turn X of Y` with an **Advance Turn**
      button; **agenda-rule badges** (Secret / Cycle / Double / Secondary / Total) with tooltips
      from the rulebook wording.
    - **Scoreboard** — your VP vs. opponent VP (`player.score` for both).
    - **Your agendas** — Hand (each with **Score** / **Discard** actions), Scored, Discarded;
      a **Draw Agenda** button with an origin picker (Special Rule / Command Point).
    - **Opponent agendas** — Scored + Discarded always shown; Hand shown only when not Secret,
      otherwise a "hand hidden — Secret scenario" note.
17. **Agenda-draw phase (`_buildAgendaDrawPhase`)** — after the initial draw, add a
    "discard unachievable → redraw" affordance on each drawn agenda (option A: no approval gate;
    the discard is visible to the opponent).

---

## Out of scope (flagged follow-ups)

- Full mechanical enforcement of **Double** (keep-in-play state + double VP), **Secondary**
  (≥1 agenda gates all VP), and **Total** (all-or-nothing) — each changes `Player#score` and
  needs its own model work. Shown as badges only this round.
- A **digital agreement handshake** for the mulligan (option B) — deferred; table agreement for now.

## Testing checklist

- [x] Scenario predicates + `agenda_rules` subset validation. *(Phase 1)*
- [x] Seeds reload cleanly with the new columns; mapping table above holds. *(Phase 1)*
- [x] Opponent visibility: non-secret shows hand; secret hides hand but shows scored + discarded. *(Phase 2)*
- [x] Cycle scenario auto-draws a replacement on score; non-Cycle does not. *(Phase 2)*
- [x] Mulligan: discard `unachievable` during the setup window discards + redraws and is visible to
      the opponent. *(Phase 2)*
- [x] Regenerated client compiles; `GameService` methods hit the right endpoints. *(Phase 3)*
- [x] Score tab renders scenario/turn/score, drives draw/score/discard/advance, and honors the
      opponent-visibility rules. *(Phase 4)*
