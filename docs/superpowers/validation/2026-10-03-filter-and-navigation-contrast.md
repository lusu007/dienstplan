# Filter selection and Light navigation surfaces

User requested stronger selected-filter distinction in both themes and neutral normal Light surfaces for the month selector and back button.

## Causes and changes

The previous Light filter tint used alpha .22 selected versus .28 unselected; Dark used a subdued .35 selected fill. Library inset selection overlay remains transparent to avoid the double contour fixed on October 2. Filter-specific full-surface tint now uses .85; Dark mixes 26% of onSurface into the primary color to lift the selected chip from its background. Unselected tint is .06 Light / .08 Dark. Foreground is resolved against the composited selected fill with a 4.5:1 target.

Authority filters display a checkmark. A native 1.3-font check exposed an overflow when adding that checkmark to the constrained ‘Eigener Dienst’ segment; the checkmark is therefore opt-in for authority filters while entry segments keep their existing label space.

Ordinary Light secondary actions, navigation icons and picker trigger surfaces use neutral surface tint and a .14 onSurface outline. Explicit tints, primary/destructive actions and selected controls remain semantic. Dark ordinary controls retain their previous colors and alphas.

## Checks

Regression tests first failed for insufficient selected/unselected contrast in both themes and accent-tinted normal Light navigation. All 141 tests pass after implementation; analysis reports no issues; final ARM64 dev debug APK builds successfully.

On the first installed contrast build, representative solid pixel samples on the S22 Ultra yielded:

| Mode | Selected fill | Unselected fill | Text | Text contrast | State contrast |
| --- | --- | --- | --- | --- | --- |
| Light | 74,120,156 | 229,234,242 | 251,252,253 | 4.586:1 | 3.899:1 |
| Dark | 52,110,143 | 14,31,42 | 251,252,253 | 5.419:1 | 3.023:1 |

Screenshots in `/tmp/dienstplan-ui-2026-10-03` capture both filter states, the neutral Light back button and calendar header. These are local temporary evidence. No saved plan, group, color or calendar entry was changed. Final installation and enlarged-entry validation follow below.

Final APK installed successfully. ‘Eigener Dienst’ selected at font scale 1.3 now fits without overflow (native screenshot `entry-large-duty-light-final.png`). Entry dismissed without saving. Android font scale restored to 1.0 and night mode yes; app System theme and empty authority filter preserved. Launcher reopened on October 3 calendar.
