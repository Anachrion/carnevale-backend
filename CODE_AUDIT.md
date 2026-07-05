# Code Audit — Carnevale Backend & Frontend

_Generated 2026-07-05. Covers the Rails 8 API (`carnevale-backend`) and the Flutter app (`~/Workspace/carnevale`, excluding the generated `lib/api_client/`)._

Severity key:
- **P1** — correctness, security, data-integrity/data-loss, crashes, memory leaks, user-facing breakage. Fix first.
- **P2** — performance (N+1s), significant duplication, maintainability/God-objects, inconsistent API contracts.
- **P3** — dead code, minor cleanup, style/consistency.

## Summary counts

| Area | P1 | P2 | P3 |
|------|----|----|----|
| Backend — controllers & queries | 2 | 9 | 6 |
| Backend — models & services | 4 | 10 | 6 |
| Frontend — screens | 3 | 9 | 5 |
| Frontend — services/models/widgets | 3 | 5 | 7 |

Cross-cutting themes: **N+1 queries all funnel through the polymorphic `entry`→`profile` chain and Ruby-side `sum(&:cost)`**; **UI chrome is copy-pasted across ~10 screens instead of extracted**; **`lib/models/**` hand-duplicates the generated API client**; **error/response contracts are inconsistent** on both sides.

---

# BACKEND

## P1 — Correctness / Security / Data integrity

### B-P1-1 · Catalog endpoints have no authentication — FIXED (2026-07-05)
`profiles_controller.rb:1`, `equipment_controller.rb:1`, `scenarios_controller.rb:1`, `spells_controller.rb:1`
These four inherit `BaseController`, which does **not** call `authenticate_user!` (unlike `GamesController`/`ListsController`/`ListEntriesController`). All catalog data is served to anonymous callers. Either an access-control gap or an undocumented, silently divergent intent — decide and make it explicit.
**Resolution (intent: catalog stays public — no login to browse cards):** protected with layered defense instead of user auth — Rack::Attack per-IP throttling (`config/initializers/rack_attack.rb`), a shared `X-Api-Key` client key baked into the frontends (`base_controller.rb#authenticate_client!`, fail-open when `API_KEY` unset so dev/test keep working), CORS restricted to configured origins (`config/initializers/cors.rb`), and `stale?`/`expires_in` cache headers on the catalog endpoints. Honest limits: a static client key is discoverable by anyone inspecting the app's traffic, and a true volumetric DDoS still has to be absorbed at the edge (CDN/WAF). Covered by `spec/requests/api/v1/{client_authentication,catalog_caching,rate_limiting}_spec.rb`. Shipped in commit `aff0040`.

### B-P1-2 · Re-selecting a gang can 500 / orphan a snapshot list — FIXED (2026-07-05)
`games_controller.rb:79-87` (`select_gang`)
No game-status guard; only `ensure_roles_resolved!`. Calling it again reassigns `has_one :list`. Because `list.owner_id` is `NOT NULL`, nullifying the previous snapshot's FK raises `RecordNotSaved`, or leaves an orphaned snapshot list. Needs an idempotency/status guard.
**Resolution:** `select_gang` now guards on `@game.gang_selection?` (gangs are frozen once the game advances) and, when re-selecting during selection, destroys the previous snapshot inside a transaction before creating the new one — no orphan, no NOT-NULL violation. Covered by request specs in `spec/requests/api/v1/games_spec.rb` ("re-selecting a gang").

### B-P1-3 · Polymorphic `entry` association has no FK or cleanup → orphaned list entries — WON'T FIX (by design, 2026-07-05)
`gang/entry.rb:6` (`belongs_to :entry, polymorphic: true`)
No DB foreign key. In theory, destroying a `Catalog::CardReference`/`Catalog::Equipment` still referenced by any `list_entries` row would leave dangling entries.
**Resolution:** the entire catalog (cards, equipment, profiles, weapons, special rules, spells) is immutable, seed-managed reference data created via `find_or_create_by!` and never destroyed. The reverse relationships were deliberately omitted for this reason; adding `dependent:` guards would be dead defensive code against a path that cannot occur.

### B-P1-4 · Missing `dependent:` on catalog associations → orphaned join rows / destroy failures — WON'T FIX (by design, 2026-07-05)
`catalog/profile.rb:5-13` (`card_references`, `illustrations`, `profile_weapons`, `profile_special_rules`), `catalog/weapon.rb:3`, `catalog/special_rule.rb:3`, and `catalog/spell.rb` (no `has_many :entry_spells`).
**Resolution:** same as B-P1-3 — catalog records are never destroyed, so the `InvalidForeignKey`/orphan paths are unreachable. Left as-is intentionally.

### B-P1-5 · Position reordering/sorting run outside a transaction — FIXED (2026-07-05)
`list_entry_reorder_service.rb:13-31`, `list_sorting_service.rb:12-17`
A multi-row `update_columns` sequence with no wrapping transaction. A mid-way failure leaves positions inconsistent (gaps/dupes); because `(list_id, position)` is UNIQUE, a retry can hit `RecordNotUnique`.
**Resolution:** both services now wrap the full multi-row shuffle in a `Gang::Entry.transaction`, so a mid-way failure rolls the whole thing back to the original ordering. Covered by atomicity specs in each service's spec ("rolls back … if a write fails partway through").

## P2 — Performance / Maintainability

### B-P2-1 · N+1 on `profile` for every rendered entry _(flagged by both backend agents)_
`base_controller.rb:29-48` (`entry_json`)
`list_json` eager-loads `includes(:entry, :entry_state, entry_spells: :spell)` but `list_entry.profile` resolves via `CardReference#profile` (`gang/entry.rb:19`), which is **not** preloaded. N models = N extra profile queries on every list render (create/update/destroy/spells/player_list/index). This same chain also powers `create_entry_states!` (`game.rb:153-161`, N+1 via `entry_state.rb:26`) and `ListSortingService#role_rank` (`list_sorting_service.rb:12,22-25`).

### B-P2-2 · `total_cost` is a Ruby-side `sum(&:cost)` that re-triggers the profile N+1 _(dup-flagged)_
`base_controller.rb:18` and `gang/list.rb:22` (`as_json_summary`)
`list_entries.sum(&:cost)` loads each entry and delegates `cost`→`entry.cost`→`CardReference#cost`→`profile&.ducats`, compounding B-P2-1. Implemented in two places (see B-P3-6).

### B-P2-3 · `cantrip_for` query per entry
`base_controller.rb:47`
`Catalog::Spell.cantrip_for(list_entry.spell_discipline)` runs a fresh `WHERE cantrip AND discipline=?` per entry. The cantrip set is tiny/static — load once.

### B-P2-4 · `GamesController#index` N+1 across players' lists, scores, agendas
`games_controller.rb:11-15` + `player.rb:37-55`
Preload omits `game_players.list`, so `list&.as_json_summary` reloads each player's list+entries+profiles. Per player also: `score` COUNT (`player.rb:33`), `hand_agenda_ids` two `pluck`s (`player.rb:28-30`), plus `Catalog::Agenda.where` for the viewer. ~O(G × players × several) queries.

### B-P2-5 · `available_lists` loads lists with no eager loading
`games_controller.rb:66-68`
`current_user.lists.map { … l.as_json_summary … }` — N+1 over the user's lists (compounds B-P2-2).

### B-P2-6 · Redundant re-validation storm via `after_commit` callbacks _(flagged by both backend agents)_
`gang/list.rb:12`, `gang/entry.rb:16`, `gang/entry_spell.rb:10` → `ListValidationService.call`; amplified in `list_entries_controller.rb:34-44` (`spells`)
`entry.update!` + `entry_spells.destroy_all` + each `entry_spells.create!` each fire an `after_commit` running the full multi-query validation. `Gang::List#snapshot_for` (`list.rb:28-40`) re-runs it after every `entry_spells.create!`. Editing one model's spells re-validates the whole list many times instead of once.

### B-P2-7 · `Encounter::Game` is a God object (199 lines, 5 concerns)
`encounter/game.rb:23-135`
One model owns join-code generation, roll-off/role assignment, the whole agenda-deck subsystem (`draw_agendas!`/`draw_agenda!`/`score_agenda!`/`discard_agenda!`/`draw_one_agenda_id`), turn advancement, entry-state creation, JSON serialization, **and** ActionCable broadcasting (`broadcast_state!`, `game.rb:131-135` — transport in a domain model). The deck logic shows feature envy on `Player`. Extract a deck/service object and a serializer.

### B-P2-8 · Serialization scattered across models, no shared convention
`game.rb:114` `as_json_for`, `player.rb:37,59` `as_json_for`/`agenda_history_json`, `list.rb:21` `as_json_summary`, `scenario.rb:5` `as_json_for_game`, `entry_state.rb:43` `as_json_for_display`
Presentation logic lives in models under five ad-hoc names. Move to serializers/presenters with one convention.

### B-P2-9 · `draw_one_agenda_id` is an unbounded loop
`game.rb:139-149`
`loop do … next if candidates.empty? end` has no termination guard; if every sampled bucket is exhausted it spins forever. Add a bound/fallback.

### B-P2-10 · Preloads built then discarded in `ListsController`
`lists_controller.rb:8-9,13`
`index`/`show` build `includes(list_entries: :entry)`, but `list_json` immediately re-queries a different relation (`base_controller.rb:23`), wasting the preload every call.

### B-P2-11 · Fragile count parsing (primitive obsession)
`game.rb:51` — `scenario.agendas.first.to_s[/\A(\d+)/, 1].to_i`
Deriving the initial draw count by regex-scraping the first JSON array element; a format change silently falls back to 3.

## P3 — Dead code / Cleanup / Consistency

### B-P3-1 · Inconsistent error-response shapes
`base_controller.rb:8-10` emits `{ errors: { base: [msg] } }`, while `games#create` (`:29`), lists create/update, `update_entry_state!` (`:221`), registrations, passwords emit `{ errors: <ActiveModel::Errors> }`. The Flutter client must handle two schemas. _(Pairs with frontend F-P2-2.)_

### B-P3-2 · Inconsistent success shapes / status codes
`games_controller.rb` — most actions return the full game (`as_json_for`), but `update_counters`/`update_stats` return only the entry state (`:219`) and `draw_agendas` returns `{ agendas: … }` (`:105`). `list_entries` `create` uses `:created` while `update`/`spells` return implicit 200.

### B-P3-3 · Dead and broken jbuilder views
`views/api/v1/lists/{_list,index,show}.json.jbuilder`
No controller renders these (all use `render json: list_json`). Also broken: `show.json.jbuilder:4-7` calls `entry.reference_id`/`entry.reference.*`, but the association is the polymorphic `entry`. Remove.

### B-P3-4 · Routes generate nonexistent actions
`routes.rb:20` — `resources :lists` generates `new`/`edit`, but the controller has no such actions. Constrain with `only:` like the other resources.

### B-P3-5 · Dead code: `Spell.choosable` scope (`spell.rb:8`); `ListValidationService` `adding:` path (`list_validation_service.rb:2-8,34-39`, only specs use it); empty `catalog.rb` module; `list_json` `with_entries: false` default branch (`base_controller.rb:12,22`, never passed).

### B-P3-6 · Duplication: `user_json` copy-pasted in `sessions_controller.rb:20-22`, `registrations_controller.rb:32-34`, `passwords_controller.rb:29-31` (move to `User`); `total_cost` in `base_controller.rb:18` vs `list.rb:22`; `refresh_list_selection_validity` in `gang/entry.rb:25-27` vs `gang/entry_spell.rb:14-16` (extract concern); `DRAW_ORIGINS`/`DISCARD_ORIGINS` (`games_controller.rb:4-5`) duplicate & can drift from `AgendaEvent::ORIGINS_BY_ACTION` (`agenda_event.rb:4-8`).

### B-P3-7 · Consistency nits: string-enum fields split between `enum` (`game.rb:10`, `player.rb:13`, `spell.rb:5`) and `validates inclusion` (`player.rb:16`, `agenda_event.rb:14`); two different temp-position hacks in the ordering services (`list_sorting_service.rb:15-16` negative positions vs `list_entry_reorder_service.rb:16` `position: 0`, the latter bypassing the `greater_than: 0` validation via `update_columns`); magic `75` threshold in `list_validation_service.rb:75`; `AgendaEvent` unique index `(game_player_id, agenda_id, action)` has no model `validates uniqueness` → raw `RecordNotUnique` 500.

---

# FRONTEND

## P1 — Crash / Correctness / Leak / Security

### F-P1-1 · Auth token passed in the WebSocket URL query string — FIXED (2026-07-05)
`game_service.dart:177` — `ActionCableClient('${ApiClient.cableUrl}?token=$authToken')`
The session JWT is embedded in the WS URL, which lands in server access logs, proxy logs, and history — leaking the credential out of secure storage into plaintext. Move to a header/subprotocol or a short-lived ticket.
**Resolution (short-lived ticket, chosen because it's the only option that's both browser-safe and makes a leak harmless):** new backend `CableTicket` model + `POST /api/v1/cable_tickets` mints a single-use, ~30s ticket over authenticated REST (JWT in the header); the connection (`ApplicationCable::Connection`) redeems `?ticket=...` instead of decoding a JWT from the URL. The client (`ApiClient.cableConnectionUrl`) fetches a fresh ticket for every connect, so the reusable JWT never rides in the WS URL. Tickets are keyed per-ticket (not per-user), so the same game can be open on several devices at once. Covered by `spec/models/cable_ticket_spec.rb`, `spec/channels/application_cable/connection_spec.rb`, `spec/requests/api/v1/cable_tickets_spec.rb`.

### F-P1-2 · `setState` after `await` with no `mounted` check — pervasive — FIXED (2026-07-05)
Gang builder: `gang_builder_screen.dart` `_loadData` (l.89), `_add` (129/131), `_addEquipment` (139/141), `_remove` (152/154), `_removeEntry` (163/165), `_editSpells` (107/109), `_reorderEntry` (241/243). Loaders: `cards_screen.dart` `_load`/`_onSearch` (60/71), `gangs_screen.dart` `_load` (62/65), `game_home_screen.dart` `_load` (77/84) & `_CreateGameSheet._load` (621/628), `game_session_screen.dart` `_init` (64).
Navigating away while a request is in flight throws `setState() called after dispose()`. Highest exposure on the builder (each action is one tap).
**Resolution:** added `if (!mounted) return;` after every `await` that precedes a `setState` (and `if (mounted)` on the `finally`/`catch` branches that set `_busy`/`_loading`) across all the listed sites. `flutter analyze` clean (no `use_build_context_synchronously` lint). NB: the repo has no widget-test harness (the only `test/` file is stale `flutter create` scaffolding), so this is analyzer-verified rather than covered by an automated regression test — worth adding widget-test scaffolding as a follow-up.

### F-P1-3 · WebSocket reconnect never refetches the snapshot (silent stale state) — FIXED (2026-07-05)
`action_cable_client.dart:80-84` reconnects/re-subscribes on `welcome`, but `GameService` fetches the full game only once in `watch()` (`game_service.dart:169-180`). Broadcasts during downtime are lost; after reconnect `currentGame` stays stale with no error. Reconnect also reuses the original (possibly expired) `?token=`.
**Resolution:** `ActionCableClient` now fires an `onReconnect` callback on any `welcome` after the first, and `GameService` uses it to refetch the full snapshot — so state can't stay silently stale after a drop. And because the connection URL is produced fresh per attempt (see F-P1-1), each reconnect mints a new ticket rather than reusing a dead credential.

### F-P1-4 · Unhandled deserialize throw inside the socket stream callback — FIXED (2026-07-05)
`game_service.dart:194` — `deserializeWith(...)` in `_onChannelMessage`
It guards a `null` result, but a malformed/schema-drifted `message['game']` makes `deserializeWith` **throw**. The throw escapes the `stream.listen` callback with no `onError`. Wrap in try/catch.
**Resolution:** wrapped the deserialize + map in a try/catch; a malformed broadcast is now logged and ignored (keeping the last-known snapshot) instead of killing the live-update stream — the next broadcast or reconnect resync recovers.

### F-P1-5 · Live game updates trigger a full double network re-fetch per broadcast
`gang_viewer_screen.dart:238` — `_onGameUpdate() => _load()`
Both `_GangTab`s listen to `GameService`, so each `game_state` broadcast fires two `playerList` HTTP fetches; on a chatty game this is continuous refetching and races with `_applyEntryState`'s optimistic update (tapped counter flickers back to stale). _(Server side compounds via B-P2-1/B-P2-4.)_

## P2 — Maintainability / Duplication

### F-P2-1 · `lib/models/**` duplicates the generated api_client models (headline smell)
Every class in `lib/models/` has a 1:1 generated built_value counterpart in `lib/api_client/lib/src/model/` (`Gang`↔`model_list`, `ListEntry`↔`list_entry`, `Game`↔`game`, `GamePlayer`↔`game_player`, `EntryState`, `Profile`, etc.). Each service then carries walls of hand-written converters (`gang_service.dart:92-146`, `game_service.dart:200-247`, `profile_service.dart:38-86`, `equipment_service.dart:17-22`) that must be updated by hand on every schema change. Use the generated models directly.

### F-P2-2 · Inconsistent error handling: only `AuthService` wraps `DioException`
`auth_service.dart` catches `DioException` and rethrows typed `AuthException` via `parseAuthError`. `gang_service`, `game_service`, `profile_service`, `equipment_service` have **no** try/catch — raw `DioException`s and `res.data!` null-bang crashes propagate to the UI. Two different error contracts. _(Pairs with backend B-P3-1.)_

### F-P2-3 · Massive UI-chrome duplication across screens
- **Full-screen background scaffold** (bg image + `BackdropFilter` scrim + `SafeArea`, ~25 lines) copy-pasted in 10 screens: `home_screen.dart:19-83`, `reset_password_screen.dart:73-96`, `cards_screen.dart:89-111`, `account_screen.dart:42-64`, `settings_screen.dart:65-87`, `gangs_screen.dart:107-129`, `game_home_screen.dart:179-199`, `game_session_screen.dart:85-105`, `gang_viewer_screen.dart:38-60`, `gang_builder_screen.dart:252-274`. Extract one `AppBackground`.
- **Glass-panel chrome hand-rolled despite `GlassPanel` existing**: `home_screen.dart:195-207`, `cards_screen.dart:163-175`, `settings_screen.dart:295-307`, `gangs_screen.dart:282-294`, `gang_viewer_screen.dart:383-395`, `gang_builder_screen.dart` (344-356, 465-477, 732-744).
- **Bottom-sheet chrome** duplicated 4×: `game_home_screen.dart` (526-546, 667-689, 860-881), `gangs_screen.dart:445-469`.
- **Screen header / loading / error / logged-out blocks** copy-pasted: headers in `cards/account/settings/gangs/game_home`; the `wifi_off`+Retry / `lock_outline`+Log-In blocks verbatim between `gangs_screen.dart:176-227` and `game_home_screen.dart:255-296`.
- **`_decoration(label)` gold-underline `InputDecoration`** re-inlined in `reset_password_screen.dart:62`, `account_screen.dart:262 & 470-475`, `game_home_screen.dart` (717/729/740/897), `gangs_screen.dart` (488-493/505-510).

### F-P2-4 · Builder ↔ viewer share a visual language but no code
`_showEquipmentDetail` is byte-identical in `gang_builder_screen.dart:169-216` and `gang_viewer_screen.dart:478-513`. `_buildPointsBar` (builder 334 / viewer 377) and `_buildGangHeader` (builder 296 / viewer 349) are near-identical, as is the entry-tile faction gradient (`_EntryTile` builder 991 / `_ReadOnlyEntryTile` viewer 534). `_SortChip` (`gang_builder_screen.dart:823-878`) duplicates the inline sort chip in `cards_screen.dart:197-242`; the three sort-toggle blocks (builder 778-813) are three copies of the same asc/desc-flip logic.

### F-P2-5 · God widgets & inconsistent global-state pattern
`gang_builder_screen.dart` (1640 lines: loading + filter/sort + 7 async mutations + ~10 `_build*` + 8 private widget classes) and `gang_viewer_screen.dart` (1106 lines, incl. two full stateful edit dialogs + a `CustomPainter`) should be decomposed; builder's `build`→`_buildTabContent`→`_buildHireTab`→`buildTile` nesting (603-701) is especially deep.
Separately, global state is inconsistent: `ApiClient`/`AuthService`/`GameService`/`GangService`/`ProfileService`/`EquipmentService` are `static final _instance` singletons, but `SettingsService` is a plain top-level global (`main.dart:11`). Singletons also make services hard to substitute in tests.

## P3 — Dead code / Cleanup / Style

### F-P3-1 · `gang_validation.dart` is entirely dead + duplicates server rules — FIXED (2026-07-05)
`lib/models/gang_validation.dart` (`GangValidator`/`ValidationResult`/`canAdd`) is never imported. It re-implements ducat/faction/unique-hire rules the server already enforces and returns via `selectionValid`/`selectionErrors` (what the screens actually use, `gang_builder_screen.dart:280`). Delete.
**Resolution:** deleted; confirmed no references anywhere in `lib/` or `test/`, `flutter analyze` unchanged.

### F-P3-2 · Other dead code — FIXED (2026-07-05)
Widgets never instantiated: `home_screen.dart` `_GoldDivider` (158-176) & `_NewsCard` (262-322); `cards_screen.dart` `_AllChip` (295-326), `_ProfileTile._statBadge` (425-432), `_factionLabel` defined twice (292 & 434), both unused. Dead hooks/params: `action_cable_client.dart:26` `onConnected` (only self-invoked); `profile_service.dart:36` `invalidateCache()` (never called — cache also never invalidates); `gang_service.dart:56` `removeEntry(listId)` param unused.
**Resolution:** deleted the unused widgets (`_GoldDivider`, `_NewsCard`, `_AllChip`), the `_ProfileTile._statBadge` and both `_factionLabel` methods, and `ProfileService.invalidateCache()`; dropped the unused `listId` param from `GangService.removeEntry` (updating both call sites); `onConnected` was already removed with the F-P1-1/F-P1-3 rewrite. Also deleted the stale stock `test/widget_test.dart` (it tested a `MyApp` counter that never existed). `flutter analyze` now reports 0 errors and 0 `unused_element` warnings.

### F-P3-3 · Deprecated `Color.withOpacity` mixed with `withValues` _(flagged by both frontend agents)_
`withValues(alpha:)` is used in newer files (`account_screen`, `settings_screen`, `reset_password_screen`, `app_toast`, `app_colors`), while `withOpacity` (deprecated, precision loss) is used 100+ times elsewhere — `gang_builder_screen` (34), `game_home_screen` (21), `app_drawer` (32-33/225), `spell_chips` (48/72-73/79/84), `themed_dialog_card:26`. Pick one.

### F-P3-4 · Inconsistent error surface
`settings_screen.dart:52` (`_sendResetEmail`) uses `ScaffoldMessenger.showSnackBar`, whereas every other screen uses `showAppToast` or inline red `Text`; the app otherwise never uses SnackBars.

### F-P3-5 · Config & correctness nits
Hardcoded `api_client.dart:8` `_host = 'localhost:3000'` feeds both REST and cable URLs — no env switch, ships only against localhost. `profile.dart:64` `cardReferenceId` returns magic `0` sentinel that callers send straight to the hire API (`gang_builder_screen.dart:128`). `auth_service.dart:175` `isTokenExpired` treats a missing `exp` as **not** expired. `game_service.dart:182-190` `stopWatching` clears `currentGame` without `notifyListeners()`. `card_viewer_screen.dart:139-151` uses literal `3.14159`/`1.5708` instead of `math.pi`.

### F-P3-6 · Performance nits
`gang_builder_screen.dart:74` search listener does `setState` + full `_filteredProfiles` copy+sort inside `build` on every keystroke; `cards_screen.dart:66` fires a network search per keystroke with no debounce, `_sortedResults` (30) re-sorts every build. `IndexedStack` in `_buildTabContent` (505) builds both tabs eagerly.

### F-P3-7 · Verified non-issue
`app_palette.dart` (brand tokens) vs `app_colors.dart` (theme-aware `BuildContext` getters re-exporting palette) is an intentional, documented split — **not** duplication.

---

## Suggested attack order

1. **Security/data-integrity P1s first**: B-P1-1 (catalog auth), F-P1-1 (token in WS URL), B-P1-3/4/5 (orphan/FK/transaction), B-P1-2 (re-select gang).
2. **Frontend crash class**: F-P1-2 `mounted` guards + F-P1-4 socket try/catch — small, high-value.
3. **Query storm** (one coherent pass): B-P2-1/2/3/4/5 all trace to the polymorphic `entry`→`profile` chain + Ruby `sum(&:cost)`; add a `profile` preload path + SQL-side cost, then B-P2-6 (collapse the validation callbacks) and F-P1-5/F-P1-3 (websocket refetch) stop compounding it.
4. **Duplication sweep**: F-P2-3/F-P2-4 (extract `AppBackground`, reuse `GlassPanel`, shared header/state/decoration widgets) and F-P2-1 (drop hand-written models) remove the most lines; B-P3-6 on the backend.
5. **God-object decomposition** (larger refactors): B-P2-7/8 (Game/serializers), F-P2-5 (builder/viewer).
6. **P3 cleanup** as capacity allows — dead code (F-P3-1/2, B-P3-3/4/5) is safe, quick, and shrinks the surface.
