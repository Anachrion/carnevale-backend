# Moderator autonomy over the catalog

Goal: let a few hand-picked players (moderators) **patch or create cards using only the
backoffice**, with no technical expertise, so the app stays maintained with minimal developer
involvement.

Finding: **the backoffice already covers about 80% of the way**. What is missing is access control,
safeguards, and a handful of settings that today can only be changed in code.

---

## 1. The process today

### Patching a card

1. Sign in to `/backoffice`. This needs an `admin: true` account, granted by hand through
   `kamal console`.
2. Edit the profile: stats, keywords, abilities, weapons and special rules (picked from lists),
   spell pools, granted spells, exclusive weapons. The card preview updates live.
3. Save. The validity of every gang that uses this profile is recomputed, and the card is flagged
   as out of date (`CardReference#stale?`).
4. **Publish** page: the card is re-rendered by headless Chrome (Grover), converted to WebP, and its
   `internal_version` is bumped. The manifest reflects it, so the app re-downloads the card.
5. Optional: **Rebuild printable sheets** to regenerate the PDFs on `/cards`.

Nothing to do on the developer side afterwards: the nightly backup copies the catalog and any
uploaded art off the box (CARNEVALEB-82), and every change is in the History (CARNEVALEB-81).

### Creating a card

Same path, plus:

- entering the identifier (a single card or an A/B pair) at creation;
- uploading the illustration from the profile editor;
- framing it in the illustration editor (offset, zoom, flip).

A moderator can therefore already do steps 2 to 5 alone. What blocks them is step 1 (access is
granted by a developer, on purpose) and everything the form does not cover.

---

## 2. What still requires a developer

### A. Access control (blocking)

- `admin` is a plain boolean. Since the backoffice only covers the catalog, a moderator needs the
  same rights as an admin, so **there is no separate moderator role**: moderators are admins.
- **Granting and revoking access stays a console operation** (`kamal console`), on purpose: who gets
  access remains a deliberate, developer-side decision, and there is no screen to build or secure.
- ~~**No change history**~~. **Done** (CARNEVALEB-81): the backoffice History shows who changed
  what, and any card, weapon or special rule can be restored to an earlier version.

### B. Profile settings missing from the form

**Mostly done** (CARNEVALEB-84). These were set by rake tasks that targeted hard-coded names;
they are now in the profile form's "Advanced options" and in the spell pool editor:

| Setting | Now |
|---|---|
| `recruitable`, `companion_upgrade_ducats`, companions | Advanced options |
| `flexible_leader`, `flexible_leader_with` | Advanced options |
| `distinct_discipline_per_copy` | Advanced options |
| `mage_slot_count` and `distinct_from_other_pools` on spell pools | Spell pool editor. Both were missing, so every save reset them |
| Transformation pairs (Yune ⇄ The Beast Within) | Still the `TRANSFORM_PAIRS` constant, `app/models/gang/entry.rb` (CARNEVALEB-85) |

### C. Reference data that only lives in the seeds

Abilities, Spells, Equipment, Agendas and Scenarios can only be changed in `db/seeds/*.rb`.

The most painful point: the profile form **rejects any ability that is not in the glossary**
(`validates_ability_glossary`). A card that introduces a new ability cannot be saved without a
deploy.

### D. Backups

**Settled** (CARNEVALEB-82): the nightly backup to R2 protects the moderators' work — the
`pg_dump` for the catalog and its history, plus an `rclone copy` of the uploaded art, which the dump
only references. `db/catalog/` is no longer a backup but the development seed, refreshed by hand.
See `docs/DATA_AND_BACKUPS.md`.

- The snapshot now carries everything the backoffice edits, the glossary and spells included
  (CARNEVALEB-84). The seed's rake tasks retire once `db/catalog/` is refreshed from production.

### E. Pitfalls for a non-technical author

- **Keywords are free text**, yet the logic depends on them: `LeaderResolver` looks for exactly
  `"Leader"`. A typo silently breaks gang validation.
- **Weapons and special rules are shared**: editing "Stiletto" changes every card that carries it.
  `cards_affected` exists but is not surfaced before saving.
- **Saving is visible immediately**: the new stats (ducats, etc.) reach the API and gang validation
  as soon as they are saved, while the card image stays the old one until it is published. There is
  no draft and no review.
- **Overlong text is clipped silently**: the card template is fixed-size and hides overflow. The
  preview helps, but nothing flags it.
- **Profiles cannot be deleted**: a card created by mistake can only be made non-recruitable (and
  even that setting is not in the form).

### F. What will stay developer work

- **A new faction**: the list is fixed in `HasFaction::FACTIONS`, and the Flutter app hard-codes the
  palette, the icons and `faction_rule.dart`. It requires a store release.
- **A new spell discipline**: also a fixed list (enum) in `Catalog::Spell`.
- **A new mechanic** the app must enforce itself (like transformation, companions or flexible
  Leaders). A rule that is only text on the card works fine; a rule the app has to apply will
  always need code.

---

## 3. Roadmap

### Tier 1: delegate safely (small)

1. ~~A change history on the catalog, with a "who changed what" view and a revert.~~ **Done**
   (CARNEVALEB-81, #51).
2. ~~Complete and automate `CatalogSnapshot`, or rely on the `pg_dump` alone.~~ **Done**
   (CARNEVALEB-82): rely on the nightly backup, now extended to the uploaded art.
3. A "this weapon appears on N cards" warning before saving a shared weapon or rule.

Access itself needs no work: moderators are made admins from `kamal console`.

### Tier 2: cover every kind of card (medium)

4. ~~Expose the settings from section B in an "Advanced options" part of the form, and add them
   to `CatalogSnapshot`.~~ **Done** (CARNEVALEB-84). Moving `TRANSFORM_PAIRS` into the database
   remains (CARNEVALEB-85).
5. Create and edit Abilities and Spells in the backoffice, then Equipment, Agendas and Scenarios if
   needed.
6. Replace free-text keywords with a pick list for the ones the app acts on (Leader, Hero,
   Henchman…).
7. Detect overflowing text in the preview (a height comparison in JS) and flag it clearly.

### Tier 3: comfort and safety net (optional)

8. A draft mode: changes only reach the API when published. This is the heaviest change, and not
   essential once the history (item 1) exists.
9. A moderator guide inside the backoffice (the process from section 1, plus the pitfalls from
   section E).

### After tiers 1 and 2

Developer involvement would only be needed for a new faction, a new discipline or a new mechanic.
Patching or creating a card would happen entirely in the backoffice.
