# Bottom-sheet consistency audit

Date: 2026-10-02. Follow-up to the typography audit. All 14 user-facing sheet flows were reviewed in current source, including shared shells, height policies, routes, inset handling, selection callbacks, empty states and scroll composition. The reported own-plan/own-group comparison was freshly reproduced on the S22 Ultra at normal font scale. Other visual comparisons use today's existing native captures as described in the typography audit. This is an audit and proposed design contract, not a claim that all the findings have been fixed.

Original audit constraint (subsequently amended by the user): preserve Dark appearance outside the approved button changes. Proposed visual corrections below apply to Light first. The Light modal barriers were already unified to 35% in the preceding task.

## Inventory

| User flow | Shell | Current height policy | Layout / behavior |
| --- | --- | --- | --- |
| Own duty plan | Generic / GlassBottomSheet | Explicit 80% screen | Sticky filter controls + independently scrolling cards; selection closes. |
| Partner duty plan | Same configuration picker | Explicit 80% screen | Same filtering/cards; adds explicit no-plan option. Selection closes. |
| Own duty group | Generic / GlassBottomSheet | Explicit 50% screen | ListView with simple selection cards; selection closes. |
| Partner duty group | Same group picker | Explicit 50% screen | Same simple card list, partner state integration. Selection closes. |
| Own accent color | Generic / GlassBottomSheet | Explicit 60% screen | Three-column color grid; selection closes. |
| Partner accent color | Same color picker | Explicit 60% screen | Same grid; selection closes. |
| Holiday accent color | Same color picker | Explicit 60% screen | Same grid; selection closes. |
| Theme / Design | Native library GlassSheet in reactive dialog route | Content-sized | Three shared selection cards; selecting keeps route open for live theme comparison. |
| Federal state | Generic / GlassBottomSheet | Content-sized, capped at 92% screen | Shared selection column inside scrolling shell; selection closes with result. |
| Reset | Generic / GlassBottomSheet | Content-sized, capped at 92% | Destructive confirmation, explanatory text, primary reset + cancel. |
| Calendar export | Generic / GlassBottomSheet | Default 80% screen | Scrollable form + persistent action area, explicit bottom system inset. |
| Calendar day detail | GlassBottomSheet | Explicit 72% screen | Custom day/date/action header + day-swipe listener + scrolling duty list. |
| Calendar month/year selection | Custom GlassDialogSurface | Grid/content-sized | Separate animated shell, month/year header and grid; custom handle. |
| New/edit personal entry | GlassBottomSheet | Content-sized, capped at 92% | Custom heading, scrolling editor, input/keyboard padding; nested date/time pickers expand inline. |

Date/time pickers inside entry and export forms are inline expansions, not additional sheet routes. GenericBottomsheet, SelectionBottomsheet and the configuration/group/color picker widgets are wrappers shared by the flows above, not separate user-facing sheets.

The current call-site heights are in `sections/schedule_section.dart`: 0.8 for own/partner configuration, 0.5 for own/partner group, 0.6 for colors. Holiday color mirrors 0.6. Generic default is 0.8; day detail sets 0.72. Empty configuration lists and missing plan prerequisites use compact content-sized messages.

## Direct comparison: own duty plan versus own duty group

Fresh captures: `sheets-audit-own-plan.png`, `sheets-audit-own-group.png`, with the same device/font scale and unchanged selection state.

What already matches: outer shared shell, 8-dp horizontal/bottom margin, 28-dp corner radius, blur 4, Light content shielding, 35% barrier, 44×4-dp handle, left-aligned 24-sp/700 sheet title and shared selection-state rendering. Their different opening position is caused by deliberately different 80%/50% heights.

What differs legitimately: the duty plan includes a fixed filter section and multi-line authority/name/description cards, so it needs more scrolling room than a five-item group list.

What is inconsistent: compound duty-plan card titles bypass the explicit 17-sp/700 style that string duty-group titles receive. The name in a plan card is weakly emphasized relative to its description. The filter block also has its own spacing rhythm: its list starts with 12-dp top padding, while the plain group list starts at 20 dp. Repeating the same selection control style does not give these two screens the same title/content hierarchy.

## Findings

### 1. Three independently maintained shell compositions

Generic settings/day/editor sheets use `GlassBottomSheet`. Theme selection uses native `GlassSheet`. Month/year selection uses a separate custom `GlassDialogSurface`. Thus the design can drift despite a shared glass material.

Concrete differences:

- Generic shell: margins 8, radius 28, handle 44×4, 10-dp top gap, white handle at alpha .55 in Light.
- Theme shell: margins 8, radius 32, native handle 36×4, 8-dp top/bottom handle gap, black at .20 in Light; native bottom footer 24; explicit bottom SafeArea; own 350-ms slide route and drag-dismiss wrapper.
- Month/year shell: margins 12, radius 32, handle 44×4, 10-dp top gap plus 14-dp bottom gap, white at .55 in Light; separate slide/fade content animation.

The main title style of the generic and theme sheets is already the same. The visible inconsistency is primarily shell geometry, handle, spacing and inset composition, not a different font family.

Recommendation: define one Light shell geometry/handle/inset contract and apply it to all three implementations. Keep the native theme sheet reactive and preserve its current Dark rendering; do not reintroduce frozen shell settings or nested glass surfaces.

### 2. Light drag handles have inconsistent contrast

Most shared/custom handles are white at .55 over a nearly white Light surface and can visually disappear. Theme uses a dark handle and remains clearly visible. Fresh own-plan/group captures demonstrate the pale handle; current source confirms the mismatch.

Recommendation: use the same readable semantic dark/neutral handle in Light. Preserve the existing Dark handle. The theme handle's accessibility label/tap action is also richer than the decorative shared handles; give shared handles equivalent semantics when they represent the same dismiss gesture.

### 3. Fixed percentages versus content-based sizing lack a shared policy

Short group/color lists use fixed percentages; theme/state/reset use content sizing. Export/day have separate fixed heights. A five-item group list happens to fit a 50% sheet on the current phone, but a different group count or larger fonts can create extra blank space or require more scrolling. A long federal-state list opens nearly full height despite belonging to the same single-choice family.

Recommendation: retain different sizes for different content, but apply a rule: simple selection/grid takes its useful content height up to a safe cap; long filterable lists use a consistent roomy maximum; editor/export keep suitable room for input and actions. Do not force every sheet to the same height. Measure at normal and increased text scale before selecting final caps.

### 4. Insets and bottom action areas are handled differently

Generic shell adds 8-dp bottom margin and 12-dp trailing space without itself applying bottom SafeArea. Native theme has SafeArea and a 24-dp footer. Export adds the device bottom inset plus 16 dp in its action area. Entry editor handles keyboard insets inside its content. Month picker adds its own external padding.

Recommendation: normalize the shell's relationship to the gesture/navigation area, then let form/editor content handle keyboard space. Avoid simply adding SafeArea globally without accounting for export's existing inset: that would double-pad its action area. Review gesture navigation and three-button navigation as separate checks.

### 5. Selection behavior includes unexpected deselection

Single-choice plan/group/color/state sheets close after choosing. Theme remains open deliberately to permit live theme changes; that exception is reasonable when documented.

Both configuration and group pickers pass `null` if the user taps the currently selected item. In the own-plan flow, clearing the active plan also clears the preferred group. That is more surprising than a styling difference: touching a selected radio-like row can remove the choice. Partner plan already has an explicit no-plan option.

Recommendation: tapping an already-selected single-choice item should confirm/retain it. Clearing should have an explicit named option where supported. This is a behavioral recommendation requiring its own change and regression coverage, not something silently altered during this visual audit.

### 6. Header/content/list spacing depends on feature implementation

Shared title padding is 16/16/16/8. Group/state selection content starts at 16/20/16/16. Filterable configurations have a stationary filter area and a list starting at 16/12/16/16. Color grids have their own grid recipe. Theme's library header/footer, month custom header and entry custom action header have independent vertical rhythms.

Recommendation: define a common header and content spacing rhythm, with explicit variants for stationary filter controls, a plain list, a grid and an editor. The content types can differ while still looking related. Reuse the same title/secondary-text roles from the typography audit.

## Recommended Light contract

Shared outer margin, rounded geometry, readable handle, title alignment, title typography, normal content inset, bottom-inset handling, modal barrier and opening/dismissal behavior. Variants only where content needs them: compact choice, long filtered choice, color grid, day details, editor and destructive confirmation. Titles/secondary text and selection indicators should express the same hierarchy across all choice variants.

Retain the existing 24-sp/700 title role and 17-sp/700 primary-choice role. Add the missing primary-name style in compound duty-plan cards. Keep 14-sp descriptions. A filter heading should visually sit below the sheet title and above the option descriptions. Empty/prerequisite messages should use the same compact message variant.

Suggested order: shared Light handle/shell tokens and compound-choice typography; simple content sizing and consistent insets; explicit selection/deselection behavior separately. Dark stays unchanged throughout the visual changes.

## Verification boundaries

No product code or settings choices were changed for this follow-up audit. Native comparison used the already installed build; it opened and dismissed choice sheets without selecting plan/group/color values. Android night mode was temporarily set to Light for comparison and is restored to the original `yes` afterward. Existing System preference and data are preserved. No tests/build were rerun because this task added audit documentation only.

Reference sources: `glass_bottom_sheet.dart`, `glass_dialog_surface.dart`, `generic_bottomsheet.dart`, `theme_mode_bottomsheet.dart`, `calendar_date_selector.dart`, `schedules_bottom_sheet.dart`, `personal_calendar_entry_sheet.dart`; all settings sheet files and their call sites in `schedule_section.dart` / `school_holidays_section.dart`.


Implementation update: the user subsequently authorized typography and text-driven layout corrections in both modes. Changes are now implemented; see `2026-10-02-typography-and-sheet-implementation.md` for the final scope and verification. Dark palette/glass decoration remains unchanged. The actual shared action adapter default is 16 sp; the initial typography audit's 14-sp value described the underlying Material label role without accounting for that override. Current role policy uses 16-sp standard actions and 14-sp compact segmented export actions.
