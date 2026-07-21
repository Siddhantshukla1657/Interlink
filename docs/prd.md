# Interlink — Product Requirements Document

> **Status:** Draft | **Last updated:** July 12, 2026 | **Owner:** Siddhant Shukla

## 1. Overview
Interlink is a personal knowledge graph app for iOS, built in SwiftUI/SwiftData. It lets a single user create entities — people, projects, objects, concepts, places — and connect them with typed, bidirectional relationships, then explore the resulting network as an interactive visual graph. It matters now as a way to externalize and navigate the web of people, projects, and ideas someone accumulates across work, hackathons, and coursework, instead of losing that context across scattered notes apps.

## 2. Problem Statement
People juggling multiple parallel projects, collaborators, and ideas (freelance work, hackathon teams, coursework, side projects) have no single place that captures how these things relate to each other. Notes apps store entities as isolated pages; contacts apps store people without project context. The result is that connections — who worked on what, which project inspired which idea, which object belongs to which context — live only in memory and get lost. This is a real, recurring friction for anyone maintaining more than a handful of concurrent projects and collaborators.

## 3. Goals
- Let a user capture people, projects, objects, concepts, and places as a single connected graph, not siloed lists
- Make relationships between entities explicit, typed, and correctly readable from either direction
- Make the resulting network explorable visually, not just as flat lists
- Keep the graph clean over time — no silent duplicate entities fragmenting the network

## 4. Non-Goals
- Full natural-language understanding that infers *relationships* from sentence structure — Phase 5 extracts candidate entity names from free text on-device, but the user always confirms and picks the relationship type manually; the app never auto-creates a connection from a sentence alone
- Live force-directed physics simulation in the graph view (persisted static layout is the intentional replacement)
- Multi-user or multi-device sync (this is a single-user, single-device local app for now)
- Fuzzy/near-duplicate name matching beyond exact normalized-string dedup
- Live location tracking or reverse geocoding (Place entities use search-and-select, not the user's current location)

## 5. Target Users / Personas
| Persona | Description | Primary need |
|---|---|---|
| Multi-project builder | Someone running several concurrent projects, collaborators, and hackathon teams (e.g. Siddhant himself) | A single place to see how people, projects, and ideas connect without re-deriving it from memory |
| Personal knowledge keeper | Someone who wants a lightweight, private way to map their own network of relationships and interests | A low-friction way to log entities and relationships as they come up, without heavy structure |

## 6. User Stories
- As a multi-project builder, I want to add a new person or project in a few taps, so that capturing a new relationship doesn't interrupt what I'm doing.
- As a user, I want the app to warn me when I'm about to create a duplicate entity, so that my graph stays accurate over time.
- As a user, I want to connect two entities and see the relationship worded correctly from both sides, so that browsing feels natural instead of robotic.
- As a user, I want to open any entity and see everything connected to it in one place, so that I don't have to reconstruct context manually.
- As a user, I want to see my whole network as a visual graph and explore it by tapping and dragging, so that I can spot patterns a list view wouldn't show me.
- As a user, I want to filter the graph down to one entity type, so that a large graph stays readable.
- As a user, I want to type a quick sentence about what happened and have the app suggest who/what was involved, so that logging a connection is faster than filling out a form from scratch.
- As a user, I want to give a Place entity a real address and see it on a map, so that places in my graph are more than just a name.

## 7. Requirements

### 7.1 Functional Requirements
1. The system must let a user create an entity with a name, type (Person/Project/Object/Concept/Place), optional notes, and optional image.
2. The system must normalize entity names and warn on likely duplicates before creating a new entity.
3. The system must let a user create a typed connection between two entities, with both a forward and reverse relationship phrase stored.
4. The system must display, on any entity's detail view, all outgoing and incoming connections grouped by relationship type, using the correct directional phrasing.
5. The system must cascade-delete all connections referencing an entity when that entity is deleted, without crashing.
6. The system must render all entities and connections as an interactive graph, supporting tap-to-inspect and drag-to-reposition.
7. The system must persist graph node positions so the layout is stable across app launches.
8. The system must let a user filter the graph view by entity type.
9. The system must let a user manually trigger a re-layout of the graph.
10. The system must extract candidate entity names from free-text sentences on-device and present them as confirmable suggestions, without auto-creating connections without user confirmation.
11. The system must let a user attach a real-world address to a Place entity and store its coordinates.
12. The system must display a Place entity's location on an embedded map, and aggregate all Place entities with coordinates on a dedicated map tab.

### 7.2 Non-Functional Requirements
- The app must remain responsive (no visible main-thread stalls) with at least 50 entities and 100 connections.
- Graph layout computation must run off the main thread.
- Stored images must be compressed/resized before persistence to avoid unbounded local storage growth.
- The app is local-only; no network dependency required for core functionality.

## 8. Success Metrics
| Metric | Target | Timeframe |
|---|---|---|
| Duplicate entity rate (same real-world entity as 2+ nodes) | Near zero in normal use | Ongoing, post-Phase 1 |
| Crash-free entity deletion | 100% of delete actions, including entities with connections | Post-Phase 1 |
| Graph view usable at typical scale | Renders and remains interactive at 50 entities / 100 connections without visible jank | Post-Phase 3 |
| End-to-end demo completion | Full create → connect → explore → delete flow completes without a dead-end or crash | Post-Phase 4 |

## 9. Constraints & Assumptions
- Constraint: SwiftUI/SwiftData only, targeting a personal iOS build (not App Store distribution scope at this stage).
- Constraint: single device, no backend — all data lives in the local SwiftData store.
- Assumption: typical personal usage stays in the tens-to-low-hundreds of entities/connections range, not enterprise scale.
- Assumption: the user is the only person entering data (no concurrent multi-user editing to reconcile).

## 10. Dependencies
- SwiftData (Apple, local persistence)
- SwiftUI `Canvas` (Apple, graph rendering)
- NaturalLanguage framework (`NLTagger`, on-device name extraction — Phase 5)
- MapKit / CoreLocation (`MKLocalSearch`, `Map` view — Phase 5)
- No third-party services or external APIs required; MapKit's local search runs through Apple's own infrastructure at no cost to this project.

## 11. Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Graph view becomes unreadable at higher entity counts | Medium | High | Type filtering (Phase 3) and persisted (not live-recomputed) layout keep rendering bounded and predictable |
| Users type inconsistent relationship types, fragmenting the taxonomy | Medium | Medium | Preset relationship-type list with paired reverse phrasing steers users away from ad hoc free text |
| SwiftData relationship/delete-rule misconfiguration causes data loss or crashes | Low (once addressed in Phase 1) | High | Explicit `deleteRule: .cascade` configured and tested before any other feature is built on top of the model |
| Manual graph interaction (drag) conflicts with persisted layout, causing jitter | Low | Medium | Drag updates written back to the model only on gesture end, not continuously |
| Sentence-assisted extraction (Phase 5) mis-tags text or is mistaken for full sentence understanding | Medium | Low | Scope stays limited to name extraction only; user always confirms via the existing structured connection flow rather than the app auto-creating anything |

## 12. Open Questions
- [ ] Should entity types be extensible by the user (custom types beyond Person/Project/Object/Concept/Place), or fixed for now?
- [ ] Is there a future need for exporting the graph (e.g. to an image or a portable format)?
- [ ] What's the realistic upper bound on entity count for this user's actual use case — worth confirming before deciding if Phase 3's in-memory filtering approach needs revisiting?
