# Setup duty-group handoff and filter clear action

The duty group selected in setup was persisted correctly, but already loaded settings UI retained its previous group. Setup completion only called `setThemePreference` on that old UI state before refreshing the calendar/config providers. Partner UI could likewise retain an earlier selection.

After saving setup choices, completion now invalidates and awaits both settings and partner UI providers before finishing the handoff. This loads the saved plan, own group and partner group immediately, including when those providers were already observed during setup.

The shared authority-filter clear action used the quiet/transparent native button while enabled; its disabled fallback always rendered a glass surface. It therefore changed from text to a visible surface when disabled. The clear action now consistently uses the secondary glass role and shared action typography. Disabled opacity is applied once instead of also setting a 30% label alpha. The shared disabled transparent-button fallback now respects its transparent style without adding a glass layer. The authority-filter component is shared by setup and the settings plan pickers, so both receive the correction.

Regression evidence:

- Both setup completion tests failed with persisted `Group 4` but UI `Old group` before the correction. They now pass for skipping partner setup and for choosing a partner plan/group. They exercise real setup navigation, real settings persistence use cases with an in-memory repository, and real settings/partner UI hydration. Schedule generation, platform setup flags and unrelated calendar/config rendering are replaced at their boundaries.
- Both theme variants of the clear action now preserve a visible tint/outline and activate only with a selected filter.
- A disabled quiet action no longer acquires a glass material.
- Full Flutter suite: **149 tests pass**. Final analyzer check is recorded in `/tmp/setup-analyze.log`; full test output in `/tmp/setup-suite.log`.
- ARM64 development debug APK built successfully, using build number 2001 (ABI split installed version code 4001).

Native verification on 2026-10-04 after reconnecting the Samsung S22 Ultra through usbipd/WSL:

- Transferred the ARM64 APK and installed with `pm install -r`: **Success**. Installed version is 0.17.4, code 4001. App data was preserved.
- Inspected the shared authority-filter component through the settings plan picker in dark and light mode. The clear action keeps the same button body and size both disabled and enabled, with disabled opacity. Selecting Allgemein filters the list; clearing restores all plans. No plan row was tapped.
- Dark screenshots: `/tmp/dienstplan-ui-2026-10-03/setup-clear-disabled-light.png` and `setup-clear-enabled-light.png` (the filenames were chosen before discovering the current device theme was System/dark).
- Light screenshots: `/tmp/dienstplan-ui-2026-10-03/setup-clear-disabled-actual-light.png` and `setup-clear-enabled-actual-light.png`.
- Restored the observed original theme preference **System**, cleared the temporary authority filter, and returned to the compact calendar on 4 October. No setup completion was performed on the device; the group handoff is covered by the regression tests above.
- Before any filter interaction, the own schedule settings displayed **Keine Dienstgruppe ausgewählt**, while the initial calendar still showed cached own/partner service rows. After theme refresh and a cold launch the calendar showed no services. No duty-group selection was changed during this verification. This existing device selection state is not evidence of a completed native setup handoff test.
- Button flex behavior remains unchanged by this build.
