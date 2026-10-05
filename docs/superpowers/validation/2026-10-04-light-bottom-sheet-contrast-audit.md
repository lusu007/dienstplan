# Light bottom-sheet contrast audit

Audit resumed on 2026-10-04. Native evidence was captured on 2026-10-03 and supplemented on 2026-10-04 on the S22 Ultra with the installed development build, explicit Light theme and font scale 1.0. This report records findings and a proposed correction scope; no product styles were changed for this audit.

Follow-up: the user approved implementation after this audit. The correction and its verification are recorded in `2026-10-04-light-bottom-sheet-contrast-implementation.md`.

## Coverage

| Flow | Evidence | Finding |
| --- | --- | --- |
| Own duty plan and duty group | Native `contrast-plan.png`, `contrast-group.png` | Unselected cards blend into the sheet; selected outlines remain identifiable. |
| Partner duty plan and duty group | Native `contrast-partner-plan.png`, `contrast-partner-group.png`; shared picker source | Same weak neutral surfaces as the own-plan equivalents; selected outlines and check indicators remain identifiable. |
| Own accent color | Native `contrast-color.png` | Color swatches identify choices, but neutral surrounding card boundaries are weak. |
| Partner and holiday accent colors | Native `contrast-partner-color.png`; shared color picker/helper source | Partner confirms the same color-grid recipe. Holiday color was disabled without a selected state, so it was not opened. |
| Design/theme | Native `contrast-theme.png`; native library shell source | Separate shell, but the same nearly opaque Light material and weak handle/neutral selection surfaces. |
| Federal state | Native `contrast-state.png` | Shared unselected choice cards have little separation from the sheet. |
| Reset confirmation | Native `contrast-reset.png` | Warning/destructive content has distinct color; neutral secondary controls inherit the weak surface separation. No reset executed. |
| Calendar export | Native `contrast-export.png` | Neutral form surfaces lack hierarchy; accent segmented controls are more identifiable. |
| Calendar day details | Native `contrast-day.png` | General text is readable, but the white “Heute” label on pale blue has insufficient contrast. |
| Month/year | Native `contrast-month.png`, `contrast-year.png`; shared tile source | Unselected white tiles and white outlines blend into the sheet in both views. |
| Personal entry | Native `contrast-entry.png` plus source for inline controls | Unfocused input boundaries are barely visible. Focused primary outlines are stronger. No entry saved. |

Inline date/time expansions are included through their shared control source; they are not separate sheet routes. Source coverage of shared variants is distinguished from native screenshots above.

## Pixel measurements

Samples are from flat regions in native screenshots under `/tmp/dienstplan-ui-2026-10-03`, excluding antialiased text edges. Ratios use sRGB relative luminance. These are measured examples, not guarantees for every backdrop or accent color.

| Comparison | Sample RGB values | Approximate ratio |
| --- | --- | --- |
| Unselected group card / sheet | 244,246,250 / 241,243,249 | 1.03:1 |
| Group card border / sheet | 249,250,253 / 241,243,249 | 1.06:1 |
| Handle / sheet | 187,189,195 / 241,243,249 | 1.69:1 |
| Primary group text / card | 24,28,32 / 244,246,250 | 15.83:1 |
| Entry field fill / sheet | 245,246,251 / 240,242,248 | 1.04:1 |
| Entry field border / sheet | 249,250,253 / 240,242,248 | 1.07:1 |
| “Heute” text / badge fill | 255,255,255 / 182,200,216 | 1.72:1 |

The weak card/fill ratios describe visual hierarchy, not a blanket accessibility requirement for decorative surfaces. Text and functional boundaries must be assessed separately. Disabled actions are intentionally muted and were not classified as active-control failures.

## Root causes

1. `GlassDialogSurface` combines Light surface tint alpha .38 with content shielding alpha .90 (effective .938). This gives readable text but leaves a nearly white inner canvas.
2. `GlassCard` adds white fill alpha .28 and white border alpha .45 on top of that canvas. The entry editor repeats that recipe for unfocused fields. Month/year tiles use white alpha .20/.35. All add brightness rather than useful tonal separation.
3. `AppSheetHandle` uses `onSurface` alpha .25 in Light. Theme mode duplicates this recipe in its native library sheet. `SoftGradientDivider` also uses white in Light.
4. `_TodayPill` uses `onPrimary` in Light, although its primary background is translucent at alpha .30. White text appropriate for an opaque accent is inappropriate for the resulting pale fill.
5. The modal scrim already separates the page from the sheet. Increasing it alone would not improve card or input separation inside the sheet.

## Proposed correction scope

- Establish a shared Light modal surface hierarchy: pale sheet, subtly darker neutral inner surfaces, readable neutral boundaries for interactive controls. Preserve translucency and avoid blanket thick borders around all content.
- Give unfocused fields and selectable options identifiable boundaries; validate functional boundaries and selected/unselected distinction on the device instead of selecting arbitrary alpha values.
- Darken the Light handle and use a neutral dark divider where separation is needed. Keep the native theme shell aligned with the shared shell.
- Use readable dark text for the Light “Heute” badge and verify its contrast against the composited fill.
- Keep Dark colors, sheet geometry, typography and selection behavior unchanged for this contrast correction.

## Device state and verification limits

The native audit temporarily enabled holidays to open the federal-state picker without choosing a state. On 2026-10-04 the toggle was restored and verified as disabled (`contrast-holiday-restored-verified.png`). The calendar was verified in its original compact layout, now showing 4 October because the day changed. Plan/group/color selections, entries and export/reset actions were not changed.

On resumption, Windows recognized the phone at USB bus 2-6. The first WSL attach failed with “Device in error state”; a subsequent attach succeeded and ADB access was verified before the additional native inspection and cleanup. `git diff --check` passes. No test/build rerun is needed for this documentation-only audit.
