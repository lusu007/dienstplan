# Typography and bottom-sheet implementation

Date: 2026-10-02. User approved implementation of the typography and bottom-sheet audit findings and explicitly permitted typography plus necessary text-driven layout changes in both Light and Dark. Dark colors and glass decoration remain protected.

## Implemented scope

- Shared `AppTypography` roles for menu/choice titles (17/700), descriptions (14), page titles (22/700), sheet titles (24/700), and standard action labels (16/700). Navigation/toggle cards and loading skeletons share the same roles. Compound choice titles inherit the primary role while explicit authority captions retain their smaller styling. The export switch now follows the same hierarchy.
- Standard setup primary action size reduced from its local 18-sp override to the shared 16-sp role. Compact segmented export actions retain their separate 14-sp role.
- Long page headers wrap and grow in both modes. Holiday rows use 15/12 compact, 18/14 large and 11-sp chip text, with minimum heights rather than fixed heights and up to two lines of primary/supporting text.
- Shared Light shell radius 32, horizontal/bottom margin 8 plus safe area, neutral 44×4 handle with 16-dp top gap, consistent trailing space. Theme native shell matches Light handle and effective background-fill recipe while preserving its reactive route, drag dismissal and original Dark shell. Month/year picker shares Light external geometry/handle; specialized date controls remain.
- Short group/color pickers size to content in Light with a safe cap and a single scrolling surface; filtered plan lists keep their roomy 80% layout. Color-grid cells grow with font scaling in both modes while default Dark cell geometry remains unchanged. The existing editor keyboard handling is retained; Light export removes redundant inner bottom system padding because the shell owns it.
- Selected plan/group rows dismiss without invoking change callbacks; this avoids downstream duty-group resets. Clearing remains available through explicit localized options in both own and partner pickers. Actual new plan selection still applies existing group-reset rules. No data or selection changes were performed as part of validation.

## Validation ledger

Initial regression suite failed for compound title hierarchy, long headers, small/fixed holiday text, retap behavior and Light handle/inset rules before implementation. Targeted tests then passed. A stronger retap regression failed because the callback still reset the downstream group; implementation was changed to make selected rows no-op confirmations, and tests verify zero mutation callbacks and a working explicit clear choice.

All 136 tests pass (`suite-typography-implementation.log`); `flutter analyze --no-pub` has no findings. ARM64 dev debug APK built successfully. A fresh-context read-only review found the downstream group-reset risk and missing partner clear choices; both were corrected and re-reviewed as resolved. No further actionable findings.

Ruling: keep different sheet heights for different content rather than forcing a single height. Unify short-choice sizing and shared shell rules; preserve room for filters, forms and day details.

Ruling: apply geometry changes only to Light, but allow both themes to grow for large text where necessary. Preserve default Dark shell decoration, radius, margins, opacity and colors; added clearing rows are deliberate behavior changes, not a palette redesign.

## Final native validation

Final ARM64 dev debug APK installed successfully on SM-S908B (R3CT609DD1V). Checked own plan, group and color sheets in Light and Dark, with additional Light group/color checks at Android font scale 1.3: all labels fit without overflow. Checked the live Dark-to-Light theme change on the existing open route; the Light sheet has a continuous light surface and neutral handle.

The normal-size Dark theme-sheet region (0,1810)–(1440,3032) is pixel-identical to both saved Dark baselines (`ImageChops.difference(...).getbbox()` returned `None`). Restored Android font scale 1.0, system night mode yes, app theme System, and reopened the launcher. Duty-plan/group/color selections were preserved.

Final follow-through also aligns dialog actions and setup headings with the shared text roles; dialog action size and weight have regression coverage in both themes. Screenshots and test/analyzer/build logs are in `/tmp/dienstplan-ui-2026-10-02` (temporary local validation artifacts).
