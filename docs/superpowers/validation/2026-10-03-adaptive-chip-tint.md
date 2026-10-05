# Adaptive library tint for chips

User rejected the opaque selected-chip appearance and approved trying the native adaptive tint. Replaced 85% full tint and Dark artificial color lightening with `GlassBodyMode.adaptive`, original primary hue and the active-card alphas (.18 Light / .22 Dark). Inner selected overlay remains transparent. A single external stadium outline (1.5 dp) and authority checkmark convey selection. Dark outline uses onSurface at .65, Light primary at .85; normal onSurface labels retain the established palette.

Regression tests failed before the change, then passed for adaptive low-opacity material, visible outer selection outline, no inset color overlay and label readability. All 141 tests pass; analyzer reports no issues. ARM64 dev debug APK built and installed successfully.

Native Light and Dark authority chips checked against the selected plan cards in the same sheet. Captures: `/tmp/dienstplan-ui-2026-10-03/adaptive-chips-light.png` and `adaptive-chips-dark.png` (temporary local evidence). Dark is genuinely selected through the in-app design control; Android night mode alone does not override the user's explicit Light preference. That original Light preference was confirmed in `adaptive-original-theme.png` and restored after inspection. Filters cleared/dismissed; no saved plan/group/entry changes.

This supersedes the earlier nearly opaque contrast approach. Selection does not require 3:1 between entire fill areas; contour/checkmark identify the state while glass stays translucent.
