# Interlink — Feature List

> **Status:** Draft | **Last updated:** July 12, 2026

## Feature Summary
| # | Feature | Category | Phase | Priority | Status |
|---|---|---|---|---|---|
| 1 | Entity data model with safe delete | Core / Data | Phase 1 | Must-have | Planned |
| 2 | Entity creation with dedup search | Entity management | Phase 1 | Must-have | Planned |
| 3 | Entity list / home view | Entity management | Phase 1 | Must-have | Planned |
| 4 | Structured connection flow with reverse-relationship presets | Connections | Phase 2 | Must-have | Planned |
| 5 | Entity detail view (grouped connections) | Entity management | Phase 2 | Must-have | Planned |
| 6 | Persisted graph layout engine | Graph view | Phase 3 | Must-have | Planned |
| 7 | Interactive graph canvas (tap, drag) | Graph view | Phase 3 | Must-have | Planned |
| 8 | Filter graph by entity type | Graph view | Phase 3 | Should-have | Planned |
| 9 | Profile image capture with thumbnailing | Polish | Phase 4 | Nice-to-have | Planned |
| 10 | Manual re-layout trigger | Graph view | Phase 4 | Nice-to-have | Planned |
| 11 | Sentence-assisted connection creation (on-device NLP) | Smart input | Phase 5 | Should-have | Planned |
| 12 | Place entities with real-world location (MapKit) | Location | Phase 5 | Should-have | Planned |
| 13 | Map tab (all Place entities as pins) | Location | Phase 5 | Nice-to-have | Planned |

*Priority: Must-have / Should-have / Nice-to-have. Status: Planned / In progress / Done.*

---

## 1. Entity data model with safe delete
**Category:** Core / Data
**Phase:** Phase 1
**Priority:** Must-have

**What it does:**
Defines the SwiftData schema for `Entity` and `Connection`, with cascade delete rules so removing an entity cleanly removes every connection referencing it instead of crashing or leaving orphaned rows.

**User story:**
As a user, I want to delete an entity from my graph without the app crashing or leaving broken connections behind, so that I can trust the data stays clean as I edit it.

**Why it's necessary:**
This is the foundation everything else is built on. SwiftData's default relationship behavior does not safely handle non-optional relationships being removed — without explicit `deleteRule: .cascade` on both `outgoing` and `incoming`, deleting any connected entity is a guaranteed crash or data-corruption path. Every other feature (connections, graph view, detail view) assumes this layer is correct; getting it wrong invalidates the whole app.

**How it works:**
1. Trigger: user deletes an `Entity` (from list, detail view, or graph).
2. Logic: SwiftData cascades the delete rule set on `Entity.outgoing`/`Entity.incoming`, removing every `Connection` where that entity is `from` or `to`.
3. Result: the entity and all its edges disappear from list, detail, and graph views consistently, with no dangling references.

**Inputs:** Delete action on any `Entity`.

**Outputs:** Entity removed from store; all associated `Connection` rows removed.

**Edge cases & error handling:**
- Edge case: entity has connections to multiple other entities → all are removed, none of the other entities are deleted.
- Error case: delete attempted mid-edit elsewhere in the UI → operation should be atomic via SwiftData's save context to avoid partial state.

**Dependencies:** None — this is the base layer.

---

## 2. Entity creation with dedup search
**Category:** Entity management
**Phase:** Phase 1
**Priority:** Must-have

**What it does:**
Lets a user create a new Person, Project, Object, Concept, or Place, with a debounced search that surfaces existing matches before allowing a duplicate to be created.

**User story:**
As a user, I want the app to warn me when an entity with a similar name already exists, so that my graph doesn't fragment into duplicate nodes that should be the same thing.

**Why it's necessary:**
The entire value of Interlink is a connected graph, not a list. If "Person B" and "person b" silently become two separate nodes, connections split across them and the graph stops representing reality. This feature exists specifically to prevent the fragmentation failure mode identified as the biggest threat to the core premise.

**How it works:**
1. Trigger: user types a name into the entity-creation or connection-target field.
2. Logic: input is normalized (lowercased, trimmed) on every keystroke, debounced ~200ms, and matched against each existing `Entity.normalizedName`. Matches are shown as selectable results above a "create new: [name]" option.
3. Result: user either selects an existing entity (no duplicate created) or explicitly confirms creating a new one.

**Inputs:** Free-text name, entity type selection, optional notes/image.

**Outputs:** New `Entity` row (with `normalizedName` set), or a link to an existing one.

**Edge cases & error handling:**
- Edge case: near-duplicate names ("Sid" vs "Siddhant") are not caught by exact normalization → surfaced as a known limitation, not silently merged.
- Error case: empty name submitted → creation blocked with inline validation.

**Dependencies:** Feature 1 (data model).

---

## 3. Entity list / home view
**Category:** Entity management
**Phase:** Phase 1
**Priority:** Must-have

**What it does:**
The app's landing screen — a searchable, filterable list of every entity in the graph, grouped or filterable by type.

**User story:**
As a user, I want to see and search everything I've added at a glance, so that I have a reliable way into the app besides the graph view.

**Why it's necessary:**
The graph view (Phase 3) is visually rich but not a reliable way to find one specific entity among many. A plain searchable list is the low-risk, always-works navigation path — necessary as a fallback and as the first thing a user sees before any graph rendering exists.

**How it works:**
1. Trigger: app launch or tab selection.
2. Logic: fetches all `Entity` records, sorted by name or `createdAt`; live-filters as the user types using the same normalized search as Feature 2.
3. Result: tappable rows navigate to the entity's detail view (Feature 5).

**Inputs:** Search text, type filter selection.

**Outputs:** Filtered entity list.

**Edge cases & error handling:**
- Edge case: zero entities exist yet → empty state prompting entity creation.

**Dependencies:** Feature 1.

---

## 4. Structured connection flow with reverse-relationship presets
**Category:** Connections
**Phase:** Phase 2
**Priority:** Must-have

**What it does:**
Lets a user link two entities with a relationship type, automatically filling in the grammatically correct reverse phrasing (e.g. "works on" ↔ "worked on by") so the connection reads correctly from both ends.

**User story:**
As a user, I want to connect two entities and have the relationship make sense when viewed from either side, so that the graph reads naturally instead of backwards.

**Why it's necessary:**
Directional relationships are the core mechanic of the app, and a naive single-verb model reads broken from the reverse side (a Project showing "working on" a Person, instead of "worked on by"). This feature replaces the originally-proposed free-text natural-language auto-creation ("type 'with Person B'") with a structured, reliable flow, since unconstrained NLP parsing was identified as undemonstrable and high-risk for a hackathon timeline.

**How it works:**
1. Trigger: user selects a source entity and taps "add connection."
2. Logic: user picks a relationship type from a preset list (each with a paired reverse phrase) or enters a custom one, in which case the app prompts for both forward and reverse phrasing explicitly. User then selects or creates the target entity via the Feature 2 search flow.
3. Result: a `Connection` row is created with both `relationshipType` and `reverseRelationshipType` set; both entities' detail views immediately reflect the new edge.

**Inputs:** Source entity, relationship type (preset or custom + reverse), target entity.

**Outputs:** New `Connection` record.

**Edge cases & error handling:**
- Edge case: user selects the same entity as both source and target → blocked with inline message.
- Edge case: connection between the same two entities with the same relationship type already exists → warn, don't silently duplicate.
- Error case: custom relationship type left blank → creation blocked.

**Dependencies:** Feature 1, Feature 2.

---

## 5. Entity detail view (grouped connections)
**Category:** Entity management
**Phase:** Phase 2
**Priority:** Must-have

**What it does:**
Shows a single entity's full profile — name, type, notes, image — and every connection it has, grouped by relationship type, with the correct forward or reverse phrasing depending on direction.

**User story:**
As a user, I want to open any entity and immediately see everything and everyone connected to it, so that I can understand its context without navigating the graph manually.

**Why it's necessary:**
This is the primary way most users will actually consume the graph day-to-day — the visual graph is for exploration, the detail view is for reference. It's also the feature that surfaces whether Features 1 and 4 (safe deletes, correct reverse phrasing) actually work correctly.

**How it works:**
1. Trigger: user taps an entity from the list (Feature 3) or graph (Feature 7).
2. Logic: fetches the entity's `outgoing` connections (displayed using `relationshipType`) and `incoming` connections (displayed using `reverseRelationshipType`), grouped by type.
3. Result: a scrollable profile with grouped, correctly-worded connection lists, each tappable to navigate to the connected entity.

**Inputs:** Selected entity.

**Outputs:** Rendered detail screen; navigation to connected entities; entry point to edit/delete.

**Edge cases & error handling:**
- Edge case: entity has no connections yet → empty state with a prompt to add one.

**Dependencies:** Feature 1, Feature 4.

---

## 6. Persisted graph layout engine
**Category:** Graph view
**Phase:** Phase 3
**Priority:** Must-have

**What it does:**
Computes and stores an (x, y) position for every entity, so the graph view has something stable to render instead of recalculating layout live every frame.

**User story:**
As a user, I want the graph to look the same each time I open it (until I explicitly rearrange it), so that it's a reliable map rather than something that reshuffles unpredictably.

**Why it's necessary:**
Live force-directed physics was identified as the highest-risk, least-demonstrable part of the original concept — no algorithm was specified, and running one on every frame on the main thread risks visible jank in front of a judge. Persisting computed positions and only recomputing on an explicit action turns the graph from an open-ended physics problem into a bounded, testable feature.

**How it works:**
1. Trigger: a new entity or connection is added, or the user requests a re-layout (Feature 10).
2. Logic: a layout pass (radial-by-type or a single off-main-thread spring-relaxation calculation) runs in the background and writes results to each `Entity.positionX`/`positionY`.
3. Result: positions are available for the graph canvas (Feature 7) to render directly, with no on-screen recomputation needed.

**Inputs:** Current entity/connection set.

**Outputs:** Updated `positionX`/`positionY` on affected entities.

**Edge cases & error handling:**
- Edge case: large entity count (50+) → layout pass must run off the main thread to avoid blocking the UI.

**Dependencies:** Feature 1.

---

## 7. Interactive graph canvas (tap, drag)
**Category:** Graph view
**Phase:** Phase 3
**Priority:** Must-have

**What it does:**
Renders all entities and connections as a visual graph using SwiftUI `Canvas`, with tap-to-inspect and drag-to-reposition interaction.

**User story:**
As a user, I want to see my whole network as a visual map and interact with it directly, so that I can explore relationships spatially instead of only through lists.

**Why it's necessary:**
This is the headline feature of the app — the thing that makes it a "knowledge graph" rather than a database browser. It's built last among the core features specifically because it depends on Features 1, 2, 4, and 6 all being correct first; building it earlier would mean building on an unstable data layer.

**How it works:**
1. Trigger: user opens the graph tab.
2. Logic: entities are drawn as nodes at their persisted positions (Feature 6); connections are drawn as lines between them. A parallel hit-region map (built during the same render pass) backs `DragGesture` and tap gestures, since `Canvas` has no built-in hit-testing.
3. Result: tapping a node navigates to its detail view (Feature 5); dragging a node updates its position in memory and writes back to the model on gesture end.

**Inputs:** Tap location, drag gesture.

**Outputs:** Navigation to detail view; updated entity position on drag.

**Edge cases & error handling:**
- Edge case: two nodes rendered very close together → hit-test map must resolve to the nearest center, not just the first match.
- Edge case: large graph (50+ nodes) → render density degrades readability; filter (Feature 8) is the mitigation, not smarter rendering.

**Dependencies:** Feature 6.

---

## 8. Filter graph by entity type
**Category:** Graph view
**Phase:** Phase 3
**Priority:** Should-have

**What it does:**
Lets the user show or hide nodes by entity type (e.g. only Persons connected to a given Project) to reduce visual density in the graph.

**User story:**
As a user, I want to narrow the graph down to just the entity types I care about right now, so that a large graph stays readable.

**Why it's necessary:**
Without this, the graph view's usefulness degrades quickly past a modest node count, since there's no smarter rendering strategy planned for the hackathon timeline. It's the cheap mitigation for that known limitation, not a nice-to-have on its own.

**How it works:**
1. Trigger: user selects one or more entity types from a filter control.
2. Logic: filters the already-fetched entity list in memory by `EntityType` (no predicate/query needed at hackathon scale) and re-renders only matching nodes and the connections between them.
3. Result: graph canvas shows a reduced, more readable subset.

**Inputs:** Selected type filters.

**Outputs:** Filtered graph render.

**Edge cases & error handling:**
- Edge case: filter results in zero visible nodes → empty state message on the canvas.

**Dependencies:** Feature 7.

---

## 9. Profile image capture with thumbnailing
**Category:** Polish
**Phase:** Phase 4
**Priority:** Nice-to-have

**What it does:**
Lets a user attach a photo to a Person or Object entity, automatically resized and compressed before storage.

**User story:**
As a user, I want to add a photo to a person or object, so that I can recognize entities visually in the list and graph.

**Why it's necessary:**
Storing full-resolution images directly in the SwiftData store was flagged as a scaling risk — it bloats the local store and slows graph rendering, which depends on decoding images per visible node. Resizing/compressing at capture time (not after the fact) keeps this from becoming a performance problem later.

**How it works:**
1. Trigger: user picks or captures a photo during entity creation or edit.
2. Logic: image is resized to a fixed thumbnail size (e.g. 200×200) and JPEG-compressed (~0.6–0.7 quality) before being written to `Entity.imageData`.
3. Result: a small, consistent-size thumbnail is stored and used in list, detail, and graph rendering.

**Inputs:** Photo from camera or library.

**Outputs:** Compressed thumbnail stored on the entity.

**Edge cases & error handling:**
- Edge case: user removes a photo → `imageData` set to nil, UI falls back to a type-based placeholder icon.

**Dependencies:** Feature 1.

---

## 10. Manual re-layout trigger
**Category:** Graph view
**Phase:** Phase 4
**Priority:** Nice-to-have

**What it does:**
An explicit button/action that recomputes and re-persists graph layout from scratch, for when manual dragging has left the graph messy.

**User story:**
As a user, I want a way to reset the graph to a clean auto-arranged state after I've been moving nodes around, so that I don't have to manually tidy up a cluttered layout.

**Why it's necessary:**
Since layout is persisted rather than live (Feature 6), there needs to be a deliberate way to regenerate it — otherwise a user who drags nodes into a mess has no way back to an organized view short of deleting and recreating entities.

**How it works:**
1. Trigger: user taps "re-layout" in the graph view.
2. Logic: re-runs the Feature 6 layout pass across all currently visible (filtered) entities, overwriting their stored positions.
3. Result: graph animates or snaps to the newly computed positions.

**Inputs:** Re-layout action.

**Outputs:** Updated positions for all affected entities.

**Edge cases & error handling:**
- Edge case: triggered while a filter (Feature 8) is active → only re-lays-out the currently visible subset, not hidden nodes.

**Dependencies:** Feature 6, Feature 7.

---

## 11. Sentence-assisted connection creation (on-device NLP)
**Category:** Smart input
**Phase:** Phase 5
**Priority:** Should-have

**What it does:**
Lets a user type a natural sentence (e.g. "grabbed coffee with Priya and discussed Perkfolio") and have candidate entity names extracted automatically as confirmable suggestions, which then feed into the existing structured connection flow rather than replacing it.

**User story:**
As a user, I want to jot down what happened in my own words and have the app pull out the people and projects involved, so that logging a connection is faster than manually picking source/target/relationship every time.

**Why it's necessary:**
This was cut from the original concept during the initial redteam because full free-text parsing (inferring *both* which words are entities *and* what relationship they imply) isn't reliably demonstrable. Apple's on-device `NLTagger` (NaturalLanguage framework, `.nameType` scheme) solves the narrower, actually-tractable half of that problem — reliably tagging `PersonalName`/`PlaceName`/`OrganizationName` spans in text, on-device, with no training or network call. Relationship inference is deliberately *not* attempted — the user confirms extracted names and still picks/edits the relationship type through Feature 4's existing flow. This makes the feature honest about what it does (name extraction) rather than overclaiming (full sentence understanding).

**How it works:**
1. Trigger: user types a free-text sentence into a "Smart Add" field.
2. Logic: `NLTagger` runs `.nameType` tagging on the input; extracted name spans are matched against existing entities via the Feature 2 dedup search and shown as tappable chips (existing entity, or "create new").
3. Result: user taps to confirm which chips are correct/relevant, selects a target chip, and is dropped into the existing Add Connection flow (Feature 4) with the target pre-filled and relationship type left for the user to pick — extraction never auto-creates a connection without this confirmation step.

**Inputs:** Free-text sentence.

**Outputs:** Confirmed entity chips; hands off into Feature 4's connection flow with target pre-filled.

**Edge cases & error handling:**
- Edge case: no names detected in the sentence → fall back to a message suggesting manual Add Connection instead of a dead end.
- Edge case: a detected name doesn't match any existing entity and isn't a plausible new one (e.g. tagger false-positive) → user can dismiss a chip without creating anything.
- Edge case: multiple names detected → all shown as separate chips; user picks one at a time to connect (one connection created per confirmation, not a batch auto-link).

**Dependencies:** Feature 2 (dedup search), Feature 4 (connection flow) — this feature is an alternate entry point into both, not a parallel system.

---

## 12. Place entities with real-world location (MapKit)
**Category:** Location
**Phase:** Phase 5
**Priority:** Should-have

**What it does:**
Lets Place-type entities carry a real latitude/longitude, captured via an address search field, and displays that location on an embedded map in the entity's detail view.

**User story:**
As a user, I want to add a real place to my graph and see exactly where it is, so that Place entities are more than just a name and a type badge.

**Why it's necessary:**
Place is already one of the five entity types in the original model but had no location data behind it — it was functionally identical to a Concept. MapKit is a native, free framework that closes this gap cleanly, and it's low-risk (pure data + UI, no inference involved) compared to the NLP feature above.

**How it works:**
1. Trigger: user creates or edits an entity with type "Place."
2. Logic: the notes field is supplemented with an `MKLocalSearch`-backed address field; selecting a search result writes `latitude`/`longitude` onto the `Entity`.
3. Result: the entity's detail view renders a small embedded `Map` with a pin at the stored coordinates, above or below notes.

**Inputs:** Address search text, selected search result.

**Outputs:** `latitude`/`longitude` set on the `Entity`; map rendered on detail view.

**Edge cases & error handling:**
- Edge case: Place entity created without selecting a search result (freeform name only) → no coordinates stored, detail view simply omits the map section rather than showing an error.
- Error case: location search fails (no network, no results) → inline message, entity can still be saved without coordinates.

**Dependencies:** Feature 1 (data model — adds `latitude`/`longitude` fields to `Entity`).

---

## 13. Map tab (all Place entities as pins)
**Category:** Location
**Phase:** Phase 5
**Priority:** Nice-to-have

**What it does:**
A dedicated tab showing every Place entity with stored coordinates plotted as pins on a single map.

**User story:**
As a user, I want to see all the places in my graph at once, so that I have a spatial view of my network the way the graph tab gives me a relational one.

**Why it's necessary:**
This is a genuinely different browsing mode from the node graph (spatial vs. relational) rather than a duplicate of it, and it's a natural, low-cost extension once Feature 12 exists — each Place entity already has coordinates, this just aggregates them.

**How it works:**
1. Trigger: user opens the Map tab.
2. Logic: fetches all `Entity` records of type Place with non-nil `latitude`/`longitude`.
3. Result: each renders as a pin on a `Map`; tapping a pin opens that entity's detail view.

**Inputs:** None (read-only view).

**Outputs:** Navigation to a Place entity's detail view on pin tap.

**Edge cases & error handling:**
- Edge case: no Place entities have coordinates yet → empty state prompting the user to add one via Feature 12.

**Dependencies:** Feature 12.

---

## Deferred / Future Features
Features considered but not currently planned for any phase, so they're captured without inflating current scope.
- **Full relationship-verb inference from free text** (e.g. auto-detecting that "with" implies "works with" vs. "collaborates with") — deferred; Feature 11 deliberately stops at name extraction and leaves relationship-type selection to the user rather than guessing it.
- **Live force-directed graph physics** — deferred; persisted static layout (Feature 6) with manual re-layout (Feature 10) is the intentional replacement, not a stepping stone.
- **Fuzzy/near-duplicate name matching** (e.g. "Sid" vs "Siddhant") — deferred beyond exact-normalized dedup (Feature 2); would need a similarity-scoring approach (Levenshtein or similar) that adds real complexity for uncertain benefit.
- **Multi-device sync (CloudKit)** — deferred; no requirement identified yet for the app to work across more than one device.
- **Reverse geocoding / live location tracking** — deferred beyond Feature 12's search-and-select flow; no requirement identified for tracking the user's current location.
