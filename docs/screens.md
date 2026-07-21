# Interlink — Screen-by-Screen Design Document

> **Status:** Draft | **Last updated:** July 20, 2026
> Companion to design.md — that file covers principles, flows, and the style guide at a high level. This file goes screen-by-screen in enough detail to build from directly.

## Screen Index
| # | Screen | Phase | Entry points |
|---|---|---|---|
| 1 | Home / Entity List | Phase 1 | App launch, tab bar |
| 2 | Entity Creation | Phase 1 | Home "+", Connection target search |
| 3 | Type Filter Sheet | Phase 1 | Home filter icon, Graph filter icon |
| 4 | Entity Detail | Phase 2 | Home row tap, Graph node tap, Connection row tap |
| 5 | Edit Entity | Phase 2 | Entity Detail "Edit" |
| 6 | Add Connection | Phase 2 | Entity Detail "+ Add Connection" |
| 7 | Graph View | Phase 3 | Tab bar |
| 8 | Re-layout Confirmation | Phase 4 | Graph View "Re-layout" button |
| 9 | Smart Add | Phase 5 | Home nav bar icon, Entity Detail nav bar icon |
| 10 | Map Tab | Phase 5 | Tab bar |

---

## 1. Home / Entity List

**Purpose:** Landing screen and the always-reliable way to find any entity, independent of the graph.

**Layout (top to bottom):**
- Nav bar: title "Interlink", trailing "+" button (opens Entity Creation)
- Search bar, pinned below nav bar: placeholder "Search entities"
- Horizontal scrollable filter chip row directly under search bar: "All", "Person", "Project", "Object", "Concept", "Place" — selected chip filled with its type color, others outlined
- Scrollable list below, grouped alphabetically by first letter (section headers: A, B, C...) OR flat sorted by `createdAt` descending if the user hasn't searched/filtered — flat/recency view is the default, alphabetical grouping only kicks in once 20+ entities exist (avoids over-structuring a small graph)
- Each row: circular thumbnail (photo or type-colored initial avatar) — name — type badge (small colored dot + label) — chevron
- Floating action button (bottom-right, if not using nav bar "+") is redundant with nav bar "+" — use nav bar only, keep bottom area clear for tab bar

**Components:**
- `SearchBar` (native `.searchable` modifier)
- `FilterChipRow` (horizontal `ScrollView`, tappable chips, multi-select allowed)
- `EntityRow` (thumbnail, name, type badge, chevron)
- `EmptyStateView` (used here and reused across other screens)

**States:**
- **Empty (no entities at all):** centered illustration/icon (simple network-node glyph), text "Nothing here yet", subtext "Add your first person, project, or idea", primary button "+ New Entity"
- **Empty (search/filter yields nothing):** smaller inline message "No matches for '[query]'" with a "Clear filters" text button, no illustration
- **Loading:** on first launch only, brief skeleton rows (3-4 gray placeholder rows) while SwiftData's initial fetch resolves — typically sub-100ms, so this state is rarely visible
- **Populated:** scrollable list as described above

**Interactions:**
- Tap row → push to Entity Detail
- Tap "+" → present Entity Creation as a sheet
- Tap filter chip → toggle, list re-filters immediately (no "apply" step)
- Pull to refresh: not needed (local store, always current) — omit
- Swipe-to-delete on row: reveals red "Delete" action, triggers a confirmation alert ("Delete [name]? This removes all its connections too.") before executing

**Navigation:**
- → Entity Detail (row tap)
- → Entity Creation (sheet, "+")
- → Type Filter Sheet (only if chip row is replaced by a "Filter" icon on smaller screens — see Screen 3 note)

---

## 2. Entity Creation

**Purpose:** Add a new entity while catching duplicates before they're created.

**Layout:**
- Presented as a sheet (medium/large detent), nav bar: "Cancel" leading, "New Entity" title, "Save" trailing (disabled until name is non-empty)
- Photo picker circle at top-center: tappable, shows placeholder camera icon if empty, tap opens action sheet ("Take Photo" / "Choose from Library" / "Remove Photo" if one is set)
- Name field directly below photo, large text field, autofocus on sheet appearance
- **Live match list:** appears directly under the name field as the user types (debounced ~200ms), max 3 results shown, each row shows the existing entity's thumbnail + name + type badge, tappable
- Below the match list (or immediately if no matches): Type picker — horizontal row of 5 selectable chips (Person/Project/Object/Concept/Place), one must be selected before Save enables
- Notes field: multi-line text editor, placeholder "Add notes (optional)"
- **Place-only addition:** when "Place" is the selected type, an address search field appears directly above Notes, placeholder "Search for an address" — backed by `MKLocalSearch`, showing up to 5 results in an inline dropdown as the user types. Selecting a result fills the field with the chosen address and silently stores its coordinates; Notes remains available underneath for freeform detail beyond the address itself.

**Components:**
- `PhotoPickerCircle`
- `NameFieldWithMatches` (text field + inline match list)
- `TypeChipPicker` (single-select)
- `NotesEditor`

**States:**
- **Empty:** blank form, Save disabled
- **Typing (no matches):** match list area collapsed/hidden
- **Typing (matches found):** match list expands with a short fade-in, up to 3 rows + "Use a different name" implicit by continuing to type
- **Match selected:** sheet dismisses, navigates directly to that existing entity's Detail view instead of creating anything — this is the critical dedup save point
- **Validation error:** if Save is somehow tapped with an empty name (shouldn't be reachable since Save is disabled), no-op
- **Saving:** brief inline spinner on the Save button (SwiftData writes are fast enough this is mostly a formality, but avoids a double-tap double-create)

**Interactions:**
- Tap a match row → dismiss sheet, push to that entity's Detail view (no new entity created)
- Tap "Save" → create new `Entity`, dismiss sheet, push to its Detail view
- Tap "Cancel" → dismiss without saving, discard any entered data (no draft persistence needed for this scope)

**Navigation:**
- ← Home (Cancel) or Connection Flow's target search (Cancel, returns to that flow)
- → Entity Detail (Save, or match selected)

---

## 3. Type Filter Sheet

**Purpose:** Secondary filter control, used identically from Home and Graph View. Only needed if screen width doesn't comfortably fit the chip row inline (e.g. smaller devices) — otherwise the inline chip row from Screen 1 suffices and this sheet is not needed. Documented here for completeness since Graph View's filter (Screen 7) may want a more deliberate, multi-select sheet rather than inline chips given it also needs a "re-layout after filter" consideration.

**Layout:**
- Small sheet (small detent), title "Filter by type"
- List of 5 rows (Person/Project/Object/Concept/Place), each with a checkbox-style trailing checkmark when selected, type-colored leading dot
- Bottom: "Select All" / "Clear" text buttons side by side
- "Apply" button, primary, bottom-pinned

**States:**
- Default: all types selected (no filtering)
- Partial selection: some checked, some not
- None selected: "Apply" disabled with helper text "Select at least one type"

**Interactions:**
- Tap row → toggle checkmark
- Tap "Select All" → check all 5
- Tap "Clear" → uncheck all (Apply disabled until at least one re-selected)
- Tap "Apply" → dismiss, calling screen re-filters

**Navigation:**
- ← Home or Graph View (Apply or swipe-to-dismiss, treated as Apply with current state)

---

## 4. Entity Detail

**Purpose:** Full profile and connection context for one entity — the most information-dense screen in the app.

**Layout (top to bottom):**
- Nav bar: back chevron, trailing "•••" menu (Edit / Delete)
- Header block: large photo/avatar centered, name (large title, bold), type badge below name
- **Place-only addition:** small embedded `Map` (fixed height, ~160pt) directly below the header block, showing a pin at the entity's stored coordinates — only rendered if the entity is type Place *and* has coordinates; otherwise this section is omitted entirely, not shown empty
- Notes section (only rendered if notes is non-empty): plain text block, left-aligned
- Divider
- "Connections" section header with a trailing "+ Add" button (opens Add Connection)
- Connections grouped by relationship-type label (outgoing groups use `relationshipType` as the group header, e.g. "Works on"; incoming groups use `reverseRelationshipType`, e.g. "Worked on by")
- Each group: header text (relationship phrase), then a row per connected entity (thumbnail, name, type badge, chevron)
- Groups ordered: outgoing groups first, then incoming groups, each internally sorted by `createdAt` descending

**Components:**
- `EntityHeaderBlock`
- `ConnectionGroupSection` (repeated per relationship-type group)
- `EntityRow` (reused from Home)
- `EmptyStateView` (reused)

**States:**
- **No connections yet:** "Connections" section shows a centered message "No connections yet" with a "+ Add Connection" button in place of grouped lists
- **Some connections:** grouped list as described
- **Loading:** not typically visible (local fetch), but if navigating from a fresh app state, a brief skeleton on the header block
- **Post-delete of a connection:** the relevant row disappears with a brief fade; if a group becomes empty, the group header disappears too

**Interactions:**
- Tap connection row → push to that entity's Detail view (stacking navigation — back returns here)
- Tap "+ Add" → present Add Connection as a sheet, pre-filled with this entity as source
- Tap "•••" → menu with "Edit" (push to Edit Entity) and "Delete" (destructive, triggers confirmation alert: "Delete [name]? This removes N connection(s) too." with N computed from outgoing+incoming count)
- Long-press a connection row → optional quick action "Remove this connection" (removes the `Connection` without deleting either entity) — confirm via alert

**Navigation:**
- ← Home, Graph View, or another Entity Detail (back stack)
- → Edit Entity (Edit)
- → Add Connection (sheet)
- → another Entity Detail (connection row tap)
- ← Home (after Delete, since this entity no longer exists)

---

## 5. Edit Entity

**Purpose:** Modify an existing entity's name, type, notes, or photo.

**Layout:**
Identical structure to Entity Creation (Screen 2), pre-populated with current values. Nav bar: "Cancel" leading, "Edit [name]" title, "Save" trailing.

**Difference from Entity Creation:**
- Name field still runs live dedup search, but excludes the entity itself from match results (so it doesn't "match itself")
- If the user changes the name to match a *different* existing entity, show a distinct warning here (not a silent redirect like creation) since this is an edit, not a creation: "This matches an existing entity, [name]. Renaming won't merge them — consider adding a connection instead if you meant to link them." This is a deliberate deviation from Screen 2's behavior, since silently redirecting an edit away from the entity being edited would be confusing.

**States:** Same as Entity Creation, plus the rename-collision warning above.

**Interactions:**
- Tap "Save" → update `Entity` fields, pop back to Detail view showing updated info
- Tap "Cancel" → discard changes, pop back to Detail view unchanged

**Navigation:**
- ← Entity Detail (Cancel or Save)

---

## 6. Add Connection

**Purpose:** Create a typed, bidirectional link from a fixed source entity to a target entity.

**Layout:**
- Sheet (medium detent), nav bar: "Cancel" leading, "Add Connection" title, "Save" trailing (disabled until relationship type + target are both set)
- Source row (read-only, non-interactive): thumbnail + name of the entity this was opened from, labeled "From"
- Relationship type picker: tappable row showing currently selected type (default: unselected, placeholder "Choose relationship"), tapping opens an inline expanding list of presets ("Works on", "Works with", "Owns", "Part of", "Inspired by", "Knows") plus a "Custom..." option at the bottom
- If a preset is selected: a small non-editable caption appears below showing the auto-filled reverse phrasing, e.g. "Reverse: worked on by"
- If "Custom..." is selected: two text fields appear — "Forward phrase" and "Reverse phrase," both required
- Target field: same `NameFieldWithMatches` component as Entity Creation, labeled "To" — search existing entities or create new inline

**Components:**
- `ReadOnlyEntityRow` (source)
- `RelationshipTypePicker` (preset list + custom fields)
- `NameFieldWithMatches` (reused from Screen 2)

**States:**
- **Empty:** no relationship type chosen, target empty, Save disabled
- **Preset chosen:** reverse phrase caption shown, target field now the only remaining requirement
- **Custom chosen:** both phrase fields required before Save enables
- **Target matches existing entity:** selecting it fills the "To" field with that entity, ready to save
- **Target is new:** typing a name with no match and continuing acts as "create new," consistent with Screen 2 — no separate creation screen is pushed; the new entity is created inline on Save
- **Validation error — self-connection:** if the searched/selected target is the same as the source entity, show inline error under the target field: "An entity can't connect to itself," Save stays disabled
- **Validation error — duplicate connection:** if the exact (source, target, relationshipType) combination already exists, show inline warning: "This connection already exists" with a "Save anyway" secondary option (allows intentional duplicates, e.g. two distinct time periods of the same relationship, without silently blocking)

**Interactions:**
- Tap relationship row → expand preset list inline (accordion style, not a separate sheet, to keep this a single flowing form)
- Select preset → collapse list, show reverse caption
- Select "Custom..." → collapse list, show two phrase fields
- Type/select target → as described above
- Tap "Save" → create `Connection` (and new `Entity` if target was newly typed), dismiss sheet, return to source entity's Detail view with the new connection visible

**Navigation:**
- ← Entity Detail (Cancel or Save, always returns to the source entity's Detail view)

---

## 7. Graph View

**Purpose:** Visual, spatial exploration of the whole network — the headline feature.

**Layout:**
- Nav bar: title "Graph", trailing filter icon (opens Type Filter Sheet, Screen 3) and a "Re-layout" icon (circular arrows)
- Full-bleed `Canvas` below nav bar, occupying all remaining space down to the tab bar
- Nodes: circles colored by `EntityType`, sized consistently (~44pt diameter to meet tap-target minimum), entity name as a small label below or inside each node (below, if labels inside would force nodes too large)
- Edges: thin lines connecting nodes, no arrowheads (relationships are bidirectional by design, arrowheads would overstate directionality that the reverse-phrase system already handles)
- Active filter indicator: if fewer than all 5 types are selected, a small chip strip appears just under the nav bar showing which types are active, tappable to jump back to the filter sheet

**Components:**
- `GraphCanvasView` (renders nodes/edges from persisted positions + hit-region map)
- `ActiveFilterChipStrip`
- Reuses `EmptyStateView`

**States:**
- **Empty (no entities):** centered message "Your graph is empty" with a "+ New Entity" button (opens Entity Creation)
- **Empty (filter yields nothing):** centered message "No entities match this filter" with "Clear filter" button
- **Loading (initial layout computing, large graph only):** brief centered spinner with label "Arranging your graph..." — typically sub-second at expected scale, but included since layout runs off-main-thread and the canvas shouldn't show stale/zeroed positions mid-computation
- **Populated:** full interactive canvas as described
- **Dragging a node:** that node scales to ~1.05x, connected edges follow in real time, other nodes stay static (no live physics re-flow during drag — that's the deliberate scope cut from the original concept)

**Interactions:**
- Tap a node → push to that entity's Detail view
- Drag a node → reposition in real time, write updated position to the model on release only (not continuously, to avoid excessive SwiftData writes)
- Tap filter icon → present Type Filter Sheet
- Tap re-layout icon → present Re-layout Confirmation (Screen 8) before executing, since it overwrites all visible positions at once
- Pinch to zoom / two-finger pan: standard canvas zoom/pan, does not affect stored node positions (purely a viewport transform)

**Navigation:**
- → Entity Detail (node tap)
- → Type Filter Sheet (filter icon)
- → Re-layout Confirmation (re-layout icon)

---

## 8. Re-layout Confirmation

**Purpose:** Guard against accidentally discarding manually-arranged positions, since re-layout is a destructive, all-at-once action.

**Layout:**
- Native alert (not a sheet — this is a single binary decision, an alert is the right weight)
- Title: "Re-arrange the graph?"
- Message: "This resets the position of every visible node. Nodes hidden by your current filter won't be affected."
- Actions: "Cancel" (default/cancel style), "Re-layout" (destructive style, since it discards manual arrangement)

**States:** Single state — appears, then dismisses on either action. No loading state needed here (the layout computation itself shows its own brief indicator back on Graph View, not on this alert).

**Interactions:**
- Tap "Cancel" → dismiss, no change
- Tap "Re-layout" → dismiss, trigger Layout Engine recompute scoped to currently visible (filtered) entities, Graph View animates nodes to new positions

**Navigation:**
- ← Graph View (either action)

---

## 9. Smart Add

**Purpose:** Faster, sentence-based entry point into connection creation — extraction assists, the user still decides.

**Layout:**
- Sheet (medium detent), nav bar: "Cancel" leading, "Smart Add" title, no trailing action (there's no single "Save" here — saving happens after handing off into Add Connection)
- Large multi-line text field, placeholder "What happened? e.g. \"Grabbed coffee with Priya and discussed Perkfolio\"", autofocus on appearance
- Below the text field, a "Find entities" button (primary, enabled once text is non-empty) — extraction runs on tap, not live per-keystroke, to avoid flickering suggestions while the user is still typing
- Results area (appears after tapping "Find entities"): a wrapped row of chips, one per extracted name, each showing the name and a small tag ("existing match" with thumbnail, or "new" with a plus icon)
- Below the chips, helper text: "Tap a name to connect it"

**Components:**
- `SentenceInputField`
- `ExtractedNameChip` (existing-match or new variant)
- `EmptyStateView` (reused, for the no-names-found case)

**States:**
- **Empty:** blank text field, "Find entities" disabled
- **Extracting:** brief inline spinner on the "Find entities" button while `NLTagger` runs (near-instant on-device, but shown for input longer than a sentence or two)
- **No names found:** message "Didn't catch any names in that — try Add Connection instead" with a button linking to Screen 6
- **Names found:** chip row populated, mix of existing-match and new-entity chips
- **Chip tapped:** sheet dismisses, pushes into Add Connection (Screen 6) with the tapped entity pre-filled as target (existing match) or created inline (new)

**Interactions:**
- Tap "Find entities" → run extraction, populate chip row
- Tap a chip → dismiss Smart Add, open Add Connection with that entity as target
- Edit text after extraction has run → chip row clears, "Find entities" re-enables (avoids showing stale suggestions against edited text)
- Tap "Cancel" → dismiss without side effects

**Navigation:**
- ← Home or Entity Detail (Cancel)
- → Add Connection (chip tap), which itself returns to whichever entity's Detail view was the source

---

## 10. Map Tab

**Purpose:** Spatial browsing of every Place entity, complementary to the relational graph view.

**Layout:**
- Nav bar: title "Map"
- Full-bleed `Map` view below nav bar, initial region framed to fit all pinned entities (or a sensible default region if none have coordinates yet)
- Pins: one per Place entity with stored coordinates, using the Place type's color for consistency with the rest of the app
- Tapping a pin shows a small native callout with the entity's name and a chevron/"View" affordance

**Components:**
- `MapPinView` (reused Place type color)
- `EmptyStateView` (reused)

**States:**
- **Empty (no Place entities with coordinates):** centered message "No places on the map yet" with a "+ New Place" button (opens Entity Creation pre-set to type Place)
- **Populated:** map with pins, standard pinch/pan interaction

**Interactions:**
- Tap a pin → show callout
- Tap the callout → push to that entity's Detail view
- Standard map pinch-to-zoom / pan (native `Map` behavior, no custom handling needed)

**Navigation:**
- → Entity Detail (callout tap)
- → Entity Creation, pre-set to type Place (empty state button)

---

## Cross-Screen Notes

**Shared components used across multiple screens:**
- `EntityRow` — Home, Entity Detail (connection lists), Entity Creation (match list), Add Connection (target search)
- `NameFieldWithMatches` — Entity Creation, Edit Entity, Add Connection (target field)
- `EmptyStateView` — Home, Entity Detail, Graph View
- `TypeChipPicker` / type-colored badge — Home (filter), Entity Creation, Entity Detail, Add Connection (via target), Graph View (node coloring)

**Consistent transition pattern:**
- Sheets (medium/large detent) are used for anything that's a self-contained task the user should be able to dismiss without losing their place: Entity Creation, Add Connection, Type Filter Sheet.
- Push navigation (standard back stack) is used for anything that's "drilling into" the graph itself: Entity Detail, Edit Entity.
- This distinction is intentional — sheets signal "quick task," pushes signal "you're now looking at a different node in your graph."
