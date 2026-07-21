# Interlink — Todo

> **Last updated:** July 12, 2026. Check items off as they're completed; keep this file in sync with actual progress.

## Phase 1: Core entity graph
- [x] Define `EntityType` enum (person, project, object, concept, place)
- [x] Build `Entity` SwiftData model
  - [x] Add `normalizedName` computed at init (lowercased, trimmed)
  - [x] Add `positionX`/`positionY` fields (unused until Phase 3, but defined now)
- [x] Build `Connection` SwiftData model with `from`/`to`/`relationshipType`/`reverseRelationshipType`
- [x] Configure `deleteRule: .cascade` on `Entity.outgoing` and `Entity.incoming`
- [ ] Write a manual test: create an entity with 2+ connections, delete it, confirm no crash and connections are gone
- [x] Build Dedup Search Service (debounced ~200ms, normalized match against `Entity.normalizedName`)
- [x] Build Entity Creation flow (name field with live search results + "create new" option, type picker, notes field)
- [x] Build Home / Entity List view (searchable, type-filterable, empty state)
- [x] Wire navigation: Home → Entity Creation → back to Home/Detail

## Phase 2: Connections & context
- [ ] Define preset relationship-type table (forward → reverse phrasing pairs)
- [ ] Build Add Connection flow (source pre-filled, relationship picker, target via Phase 1 dedup search)
  - [ ] Custom relationship type path: prompt for both forward and reverse phrasing
  - [ ] Block self-connections (source == target)
  - [ ] Warn on duplicate connection (same from/to/relationshipType)
- [ ] Build Entity Detail view
  - [ ] Group outgoing connections by `relationshipType`
  - [ ] Group incoming connections by `reverseRelationshipType`
  - [ ] Empty state for entities with no connections
  - [ ] Edit/delete entity actions
- [ ] Manual test: connect two entities, confirm correct phrasing shows on both sides' detail views

## Phase 3: Visual graph exploration
- [ ] Build Layout Engine (off-main-thread `Task`, radial-by-type or spring-relaxation pass)
- [ ] Wire layout recompute trigger to new entity/connection creation
- [ ] Build Graph Canvas rendering from persisted `positionX`/`positionY`
- [ ] Build parallel hit-region map alongside canvas rendering
- [ ] Implement tap-to-inspect (navigates to Entity Detail)
- [ ] Implement drag-to-reposition (updates position in memory, writes back on gesture end)
- [ ] Build type filter control, wire to in-memory filtering of rendered nodes/edges
- [ ] Manual test: render graph with 50+ synthetic entities, confirm no visible main-thread stall

## Phase 4: Polish & demo readiness
- [ ] Build Image Processing (resize to 200x200, JPEG compress ~0.6-0.7 quality)
- [ ] Wire image capture/picker into Entity Creation flow
- [ ] Build manual re-layout button in Graph View, wired to Layout Engine
- [ ] Pass over empty/loading/error states across all screens (Home, Detail, Creation, Connection Flow, Graph)
- [ ] Confirm accessibility basics: 44x44pt tap targets on graph nodes, Dynamic Type on text screens, VoiceOver labels on list/detail
- [ ] End-to-end manual run-through: create entities → connect them → explore graph → delete an entity → confirm no crash or dead-end

## Phase 5: Smart input & location context
- [ ] Add `latitude`/`longitude` (nullable) fields to `Entity` model
- [ ] Build Name Extraction Service (`NLTagger`, `.nameType` scheme)
- [ ] Build Smart Add screen (sentence input, "Find entities" button, chip results)
  - [ ] Wire extracted names to Dedup Search Service for existing-match detection
  - [ ] Wire chip tap → Add Connection flow with target pre-filled
  - [ ] Empty-state handling for no names found
- [ ] Build Location Service (`MKLocalSearch` wrapper)
- [ ] Add Place-only address search field to Entity Creation and Edit Entity
- [ ] Add embedded `Map` section to Entity Detail (Place entities with coordinates only)
- [ ] Build Map Tab (all Place entities with coordinates, pin tap → Entity Detail)
- [ ] Manual test: sentence "grabbed coffee with Priya and discussed Perkfolio" correctly surfaces both names as chips
- [ ] Manual test: creating a Place entity with a real address shows a correct pin on both its detail view and the Map tab

## Backlog / Unscheduled
Tasks not yet assigned to a phase.
- [ ] Investigate fuzzy/near-duplicate name matching beyond exact normalization
- [ ] Investigate CloudKit sync if multi-device need arises
- [ ] Investigate iPad split-view layout
- [ ] Investigate graph export (image or portable format)
- [ ] Investigate relationship-type suggestion (not full inference) based on common verbs detected near extracted names in Smart Add
