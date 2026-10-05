# Selected filter-chip contour

The selected `liquid.GlassChip` paints a rounded selection overlay around its padded content. Our 34-dp minimum chip height exceeds that content, leaving visible strips above and below the fill on the device.

Keep the library chip, its selected state and interaction, and make its inset selected overlay transparent. The existing selected glass tint now supplies the color over the full pill surface. No dimensions, typography or other controls change.

Regression tests reproduce an opaque inset selection fill in both themes before the change and verify its absence afterward. All 138 tests pass; Flutter analysis reports no issues. ARM64 dev debug APK builds successfully.

Final APK installed successfully on SM-S908B. Selected authority filter visually checked in Dark and Light: full-height tint with no inset bands. Device disconnected during the final restoration on 2026-10-02. On resuming 2026-10-03, cleared the temporary authority filter, selected app theme System and reopened the launcher. Android font scale was already 1.0 and night mode yes; plan and group selections were preserved. Screenshots: `/tmp/dienstplan-ui-2026-10-02/selected-filter-dark-fixed.png` and `selected-filter-light-fixed.png`.

The screenshot/log paths above were temporary: `/tmp/dienstplan-ui-2026-10-02` was unavailable after restarting the environment on 2026-10-03. The recorded results refer to the checks actually performed on 2026-10-02.
