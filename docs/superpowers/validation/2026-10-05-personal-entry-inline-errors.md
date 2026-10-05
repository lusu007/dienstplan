# Visible errors inside the personal-entry editor

The user confirmed that the error notification is covered by the bottom sheet. The main ScaffoldMessenger paints below that modal route, so styling the notification alone cannot make it visible.

## Implementation

- Missing-title validation now appears under the title field, using the field's error decoration and shared 14-sp feedback typography. The message disappears once the title contains non-whitespace text.
- Other save/delete failures remain inside the editor as a `GlassCard` above Save. This reuses the installed library through the existing card adapter, with a semantic error icon/outline and readable onSurface copy. No second overlay or main-scaffold error toast is created.
- Error messages are live regions for accessibility. After layout, the editor reveals the relevant field/card if the user scrolled to Save. The draft and modal stay open after a failure.
- Successful save/delete feedback remains on the calendar after the editor closes. Normal form layout, time toggle behavior and existing persistence validation are unchanged.
- The library's `GlassFormField` fixes its error label to 12 sp and a non-adaptive Cupertino red. The existing Flutter text field's error slot is used to preserve the app's field appearance and shared typography instead.

## Verification

- Six regression tests failed on the original implementation because feedback was outside the active editor subtree. `/tmp/entry-feedback-red.log`.
- Tests use the real save/delete use cases, replacing only persistence with an unavailable repository. They verify field correction, save/delete failures, retained title/notes and no hidden main-scaffold notification in both themes.
- All error messages also pass hit-testing checks while the sheet remains open on a 600×700 test viewport; this covers revealing feedback after scrolling to Save.
- Full Flutter suite: **162 passed**, `/tmp/entry-feedback-suite.log`.
- Final analyzer: **No issues found**, `/tmp/entry-feedback-analyze-final.log`. Dart formatting and `git diff --check` passed.
- ARM64 dev debug build succeeded, `/tmp/entry-feedback-build.log`, and `pm install -r` returned **Success**. Installed package version 0.17.4 / code 4002; data retained.
- S22 Ultra native inspection: `/tmp/dienstplan-feedback-audit/inline-error-dark.png` and `inline-error-light.png` show the title error in the open sheet. `inline-corrected-light.png` / XML confirm that typing `Pruefung` removes the error while the editor remains open and the keyboard is displayed.
- The temporary unsaved draft was dismissed by dragging down the sheet. No valid entry was saved, and no real storage/delete failure was induced on the user's phone; those paths are verified by widget tests.
- Restored theme preference **System** and returned to the calendar on 5 October. Own plan `Einsatz- und Streifendienst`, `Dienstgruppe 3`, no partner plan and existing display preferences retained. No reset, external message, commit or push performed.
