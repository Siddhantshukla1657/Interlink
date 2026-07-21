# Interlink — Phases

> **Status:** Draft | **Last updated:** July 12, 2026

## Roadmap Summary
| Phase | Name | Goal | Target duration |
|---|---|---|---|
| Phase 1 | Core entity graph | A single user can create, dedupe-search, list, and safely delete entities | 3-4 days |
| Phase 2 | Connections & context | Entities can be linked with correctly-worded bidirectional relationships and reviewed via detail view | 3-4 days |
| Phase 3 | Visual graph exploration | The full network renders as an interactive, filterable graph | 4-5 days |
| Phase 4 | Polish & demo readiness | Images, manual re-layout, and rough edges are cleaned up for a stable demo | 2-3 days |
| Phase 5 | Smart input & location context | Sentence-assisted connection creation and real-world locations for Place entities | 3-4 days |

---

## Phase 1: Core entity graph
**Goal:** A single user can create, search, list, and safely delete entities, with no duplicate-name fragmentation and no crash-on-delete risk.

**Scope:**
- SwiftData model for `Entity` (with `normalizedName`, `positionX`/`positionY` fields defined even though layout isn't used yet)
- Cascade delete rules configured and tested
- Entity creation flow with debounced, normalized dedup search
- Entity list / home view with search and type filter

**Out of scope for this phase:**
- Connections between entities (Phase 2)
- Any graph rendering (Phase 3)
- Image capture (Phase 4)

**Deliverables:**
- Working `Entity` SwiftData model, verified safe under delete
- Entity creation screen with dedup search
- Home list view

**Dependencies:** None — this is the starting phase.

**Exit criteria:** A user can create several entities of different types, search for one by partial/case-varied name and get the existing match instead of a duplicate, and delete an entity without a crash.

---

## Phase 2: Connections & context
**Goal:** Entities can be meaningfully linked to each other, and every entity's full context is visible in one place.

**Scope:**
- `Connection` SwiftData model with `relationshipType` and `reverseRelationshipType`
- Preset relationship-type list with paired reverse phrasing
- Custom relationship type entry (prompts for both directions)
- Structured connection-creation flow (source → relationship → target via Phase 1 dedup search)
- Entity detail view showing grouped, correctly-directioned connections

**Out of scope for this phase:**
- Any free-text/NLP-based connection creation (permanently deferred, not just phased out)
- Graph visualization (Phase 3)

**Deliverables:**
- Connection creation flow
- Entity detail view

**Dependencies:** Phase 1 (entity model, dedup search).

**Exit criteria:** A user can connect two entities, see the relationship worded correctly from both entities' detail views, and confirm that deleting one entity removes the connection from the other's view too.

---

## Phase 3: Visual graph exploration
**Goal:** The full entity network is explorable as an interactive visual graph, not just lists.

**Scope:**
- Persisted graph layout engine (computed off the main thread, written to `positionX`/`positionY`)
- `Canvas`-based graph rendering from persisted positions
- Parallel hit-region map for tap-to-inspect and drag-to-reposition
- Type-based filter to reduce visual density

**Out of scope for this phase:**
- Live force-directed physics (permanently deferred)
- Manual re-layout trigger UI (Phase 4 — the engine exists here, the button comes later)

**Deliverables:**
- Graph view screen with tap and drag interaction
- Type filter control

**Dependencies:** Phase 1, Phase 2 (needs entities and connections to render).

**Exit criteria:** A user can open the graph tab, see all entities and connections laid out without overlapping badly at typical personal-graph scale (~30-50 nodes), tap a node to open its detail view, drag a node without the layout breaking, and filter down to one entity type.

---

## Phase 4: Polish & demo readiness
**Goal:** The app is stable, visually presentable, and has no obvious rough edges for a demo or daily use.

**Scope:**
- Profile image capture with resize/compression before storage
- Manual re-layout trigger button in the graph view
- Empty states, loading states, and error states across all screens
- Pass over edge cases identified in feature.md (duplicate connections, self-connections, etc.)

**Out of scope for this phase:**
- Any deferred feature (NLP parsing, live physics, fuzzy matching, multi-device sync)

**Deliverables:**
- Image capture + thumbnailing
- Re-layout button
- Consistent empty/loading/error states

**Dependencies:** Phase 1, Phase 2, Phase 3.

**Exit criteria:** The app can be demoed start-to-finish — create entities, connect them, explore the graph, delete something — without a crash, visual glitch, or dead-end screen.

---

## Phase 5: Smart input & location context
**Goal:** Users can create connections from natural sentences (via on-device name extraction, confirmed manually) and Place entities carry real-world locations shown on a map.

**Scope:**
- On-device NLP extraction service (`NLTagger`, `.nameType` scheme) for names in free text
- "Smart Add" entry point: sentence input, extracted names shown as confirmable chips, hands off into the existing Add Connection flow (Phase 2)
- `latitude`/`longitude` fields added to `Entity`, populated via `MKLocalSearch`-backed address field for Place-type entities
- Embedded map on a Place entity's detail view
- Map tab plotting all Place entities with coordinates as pins

**Out of scope for this phase:**
- Automatic relationship-type inference from sentence structure (permanently deferred — extraction identifies names only, the user still picks the relationship)
- Reverse geocoding or live location tracking

**Deliverables:**
- Smart Add screen
- Updated `Entity` model with location fields
- Place-specific address search in Entity Creation/Edit
- Map tab

**Dependencies:** Phase 1 (entity model, dedup search), Phase 2 (connection flow, reused as the confirmation step for Smart Add).

**Exit criteria:** A user can type "grabbed coffee with Priya and discussed Perkfolio," see "Priya" and "Perkfolio" offered as candidate entities, confirm one, and complete a connection through the existing flow with the relationship type left to them to choose. Separately, a user can create a Place entity with a real address and see it as a pin both on its own detail view and in the Map tab.

---

## Future / Not Yet Scheduled
Ideas explicitly deferred beyond the current roadmap, so they aren't lost but also aren't scope for any active phase.
- Full relationship-verb inference from sentence structure (beyond Phase 5's name-only extraction)
- Live force-directed graph physics
- Fuzzy/near-duplicate name matching (similarity scoring beyond exact normalization)
- Multi-device sync via CloudKit
- Reverse geocoding / live location tracking
