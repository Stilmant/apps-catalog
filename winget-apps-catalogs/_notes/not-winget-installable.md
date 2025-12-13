# Not winget-import installable (notes)

This file is documentation only.

Anything listed here is **not** part of the winget catalogs in this repo and is **not** used by any script.
Use it as a triage scratchpad for packages that were:
- not found via winget,
- not reliably installable via `winget import`, or
- better handled as a manual install.

---

## Triage checklist (copy/paste)

When something doesn’t work via `winget import`, capture a minimal, reproducible note:

**App name:**

**Category:** `not-found` | `installs-fail` | `msstore-id` | `manual-preferred` | `other`

**Attempted identifiers / commands:**
- `winget search <name>`
- `winget show <id>`
- `winget install --id <id> --source winget`

**Observed result:**
- (error message, exit code, or what failed)

**Decision / next step:**
- (e.g., “manual install”, “skip”, “revisit later”)

---

## Entries

### Microsoft Store app IDs (MSStore)

These are *Store product IDs* (not classic `Publisher.App` winget identifiers).

**WhatsApp**
- Category: `msstore-id`
- Store ID: `9NKSQGP7F2NH`

**Apple Music**
- Category: `msstore-id`
- Store ID: `9PFHDD62MXS1`

### Not found / not usable as-is

**Composer**
- Category: `installs-fail`
- Attempted: `Composer.Composer`
- Note: previously observed as not installing correctly via winget.

**XAMPP 8.2**
- Category: `not-found` / `manual-preferred`
- Attempted: `ApacheFriends.XAMPP` (not found)
- Note: manual install may be preferable.
- Also seen in notes as: `ApacheFriends.Xampp.8.2` (likely not a valid winget identifier)
