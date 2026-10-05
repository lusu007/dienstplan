# Compact filter clearing and anchored button flex

The user found the clear-filter action oversized in setup and requested the same compact appearance in own/partner plan bottom sheets. They also approved restoring gentle drag deformation to glass buttons.

## Implementation

- The shared `PoliceAuthorityFilterChips` action uses 14 sp text, 10/6 dp horizontal/vertical padding and `AppGlassButton(compact: true)`. Its visible minimum height is 36 dp; a centered, opaque 48 dp gesture target preserves comfortable touch access. Both enabled and disabled states retain the secondary glass material. The filter heading can wrap instead of overflowing beside the action.
- Text actions and month picker triggers put their semantic outline inside the native `GlassButton` content. Icon actions put their full-size outline inside `GlassIconButton.icon`, matching the native circle/rounded-rectangle shape. Native glass, outline and label/icon therefore share the same deformation.
- Both adapters use anchored stretch .4, intensity/squash .1, translation damping 0, bounciness 0 and press scale 1. The library still changes the pressed lighting. The text adapter deliberately uses .4 because the library treats .5 as the default and would substitute the global zero-stretch theme. Icon controls use a scoped interaction theme. Unadapted controls, chips and bottom-sheet motion are unchanged.
- Reduced motion and disabled controls suppress deformation. Compact padding taps and native content taps activate once; cancelled drags do not activate.

## Verification

- Initial gesture tests failed because deformation was disabled; the clear action tests failed at 48 dp visible height. A follow-up test with the real `AppGlassTheme` caught the default .5/theme override before installation.
- Full Flutter suite: **152 passed**, `/tmp/compact-flex-suite.log`.
- Analyzer: **No issues found**, `/tmp/compact-flex-analyze.log`.
- ARM64 dev debug APK built successfully, `/tmp/compact-flex-build.log`, and installed with `pm install -r`: **Success**. Data preserved, version 0.17.4/code 4001.
- Native S22 Ultra inspection covered setup and own/partner plan sheets in Light and Dark. Setup screenshots: `/tmp/dienstplan-ui-2026-10-03/compact-setup-{dark,light}-{disabled,enabled,held}.png`. Sheet screenshots: `compact-{own,partner}-picker-{dark,light}*.png` in the same directory.
- Held native text-action screenshots retain a shared glass/outline shape. The glyph bounding box grows by 2 physical pixels horizontally in the sampled 150/65 px drag, in both themes; there is no independent following glass layer.
- Held Today icon screenshots: `compact-icon-light-held.png` and `compact-icon-dark-held.png`. Its outline and glass remain aligned and return to rest after pointer up. Tests additionally measure outline/glass rectangles during dragging, bounded deformation and recovery after cancellation.
- Restored theme preference **System**, cleared temporary authority filters and returned to the compact calendar on 4 October. Setup was only opened through step 2 and was not completed. Logs before this work already showed active own plan `2-Schichtplan 5-Tage`, empty own group and no partner plan; these selections were left intact.
- `git diff --check` passed. No commit or push performed.
