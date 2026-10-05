# Glass button drag stays within the outline

Cause: app buttons/chips explicitly set stretch zero, but library `GlassIconButton` has no stretch parameter and its underlying `GlassButton` inherits default .5. With anchorStretch false, dragging moves the material while the app-painted external outline stays still.

Set the app `GlassInteractionSettings.stretch` to zero; icon buttons inherit this policy. Press lighting remains active. No surface colors or dimensions change.

Regression gesture tests in both themes reproduced approximately 11.89 logical pixels of movement before the change. They hold the button, move the pointer and advance 30 animation frames, then verify unchanged icon position and size. All 143 tests pass; analyzer reports no issues. ARM64 dev debug APK built and installed successfully.

Native S22 Ultra check held the Light back button and moved the pointer by (135,75) physical pixels, then released outside the control. The material stays inside its contour and the arrow remains at its original position; pressed illumination is visible. Local temporary captures: `/tmp/dienstplan-ui-2026-10-03/drag-before.png`, `drag-held.png`, `drag-restored.png`. Theme preference Light and app data preserved.
