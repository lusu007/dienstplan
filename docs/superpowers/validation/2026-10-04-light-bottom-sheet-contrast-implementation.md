# Light bottom-sheet contrast correction

Implements the correction proposed in `2026-10-04-light-bottom-sheet-contrast-audit.md` and approved in the follow-up conversation.

## Scope

The pale modal canvas stays unchanged. `GlassDialogSurface` supplies an inherited modal scope, and the native theme sheet supplies the same scope explicitly. Within Light modals, neutral cards, unselected month/year tiles and secondary buttons use a 5% `onSurface` tint and 22% neutral outline. This separates their material from the nearly white sheet without adding opaque panels or heavier borders. Selection indicators and accent decoration remain unchanged.

Entry fields use the same neutral fill with a stronger 50% outline. Light handles use 50% `onSurface`, including the native theme sheet. Shared Light decorative dividers use a neutral line instead of white. The day-detail “Heute” badge uses `onSurface` text on its translucent primary fill. Neutral icon-toggle chips inside Light modals also follow the modal material recipe, including the day-detail header controls; outside-modal icon chips retain their previous recipe.

Dark branches retain their previous colors and opacities. Cards and controls outside modal scopes retain their previous Light material. Geometry, typography, dismissal and selection behavior are unchanged.

## Automated verification

- The unfocused entry-field contrast assertion failed against the previous white-border recipe (approximately 1.02:1) and passes with the new neutral outline, meeting 3:1 against the composited field fill.
- The day-detail badge regression test passes with the new foreground. Reinstating the previous Light `onPrimary` branch makes it fail at approximately 1.64:1, below the 4.5:1 text target.
- Full Flutter suite: **144 tests pass**.
- `flutter analyze`: **no issues found**.
- ARM64 dev debug build succeeds with build number 2001. The ABI split applies its offset, producing installed version code 4001, above the previous 2001. The initial default-number build was rejected by Android as a downgrade; no uninstall or data reset was performed.

Logs: `/tmp/light-modal-red.log`, `/tmp/light-today-red.log`, `/tmp/light-modal-suite-final.log`, `/tmp/light-modal-analyze-final.log`, `/tmp/light-modal-build.log`.

## Native verification

The new APK is installed on the S22 Ultra. Native Light captures confirm identifiable neutral surfaces in group/plan/color selection, export controls and the reactive native Design sheet. The native theme sheet was also inspected in Dark, then restored to explicit Light.

At matching coordinates in the group picker, the sheet remains RGB 241,243,249. The unselected card changes from 244,246,250 to 229,231,237 (surface ratio 1.03 to 1.11). The decorative border changes from 249,250,253 to 185,187,194 (ratio 1.06 to 1.73). The handle changes from 187,189,195 to 132,135,141 (ratio 1.69 to 3.25). Decorative borders are intentionally subtler than functional field edges.

Native month/year captures confirm stronger neutral tile separation. The entry-field border is RGB 126,129,135 against fill 230,232,238, measuring approximately **3.19:1**. The day-detail label is RGB 24,28,32 against badge fill 182,200,216, approximately **9.99:1** (previously 1.72:1 with white text). These screenshot measurements apply to the inspected backdrop/accent and do not guarantee every configuration.

Captures use the prefix `modal-contrast-fixed-` under `/tmp/dienstplan-ui-2026-10-03`. The final build is installed and the day-detail icon-toggle material was verified directly (`modal-final-header-controls.png`). Its normal and selected states were inspected; the other-groups toggle was returned to disabled afterward. No entry was saved, no export/reset action executed, and no plan/group/color selection changed. The compact calendar on 4 October was restored and verified (`modal-final-compact-verified.png`); explicit Light theme was restored after the native Dark inspection. `git diff --check` passes.
