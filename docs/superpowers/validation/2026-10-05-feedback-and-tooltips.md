# Transient messages and long-press tooltips

The user reported poor contrast and outdated styling for bottom notifications (including app reset) and long-press tooltips, and asked to use the installed glass library where available.

## Implementation

- All production Snackbar call sites use `AppSnackBar`, including reset success/failure, notification service messages, calendar entry feedback, plan/group selection, export, contact feedback and debug feedback.
- The adapter uses `AppGlassSurface` / the installed `liquid_glass_widgets` 1.7.2 `GlassContainer`. A 96% semantic surface fill keeps onSurface labels readable above arbitrary content, with a shared neutral outline. Labels use 14 sp, weight 500 and line height 1.4, and can wrap without truncation.
- Native `ScaffoldMessenger` queue, durations, route handoff and dismissal remain. Action messages use the existing `SnackBarAction` callback and persistence, with the action below the label for narrow screens.
- The library's `GlassToast` fixes labels to two lines with ellipsis and does not expose text styling. Its glass material is reused through the app surface rather than adopting that restriction.
- No standalone library tooltip exists. `AppFeedbackStyle` supplies a global Flutter tooltip theme matching the feedback surface and typography in both modes, preserving placement, long-press handling and accessibility.

## Verification

- Fresh full Flutter suite on 5 October: **156 tests passed**, `/tmp/feedback-suite-resume.log`.
- Fresh analyzer: **No issues found**, `/tmp/feedback-analyze-resume.log`.
- Feedback tests check at least 4.5:1 label/action contrast over white, black, blue and red backdrops in both themes. Widget tests use the actual reset text at 320 dp width and 1.3 text scale; they check native library surface use, untruncated labels, queueing, action persistence and callback activation.
- The dev APK was built and installed before the pause on 4 October. Today's device reports package `io.scelus.dienstplan.dev`, version 0.17.4 / code 4001; no app code changed during this resumed verification.
- S22 Ultra native screenshots inspected on 5 October: `/tmp/dienstplan-feedback-audit/tooltip-light.png`, `tooltip-dark.png`, `snackbar-light-confirm.png`, `snackbar-dark-confirm.png`. The tooltip sample is Today. The notification sample is the empty-title validation message, reached without creating a calendar entry or resetting app data.
- Early notification capture attempts left the entry sheet open: its existing PopScope first clears focused content, so one Back does not always dismiss it. The successful capture sends a second Back after clearing focus, making the main-scaffold message visible before its timer expires. No product behavior was changed for this audit.
- Theme preference restored to **System**. Existing own plan `Einsatz- und Streifendienst`, `Dienstgruppe 3`, no partner plan and other-group display preference retained. No reset, contact message, commit or push performed.
- `git diff --check` passed before documentation completion; repeated after the documentation edit.

## Remaining behavior outside this styling change

This audit found that validation notifications invoked inside the personal-entry bottom sheet appeared on the underlying main scaffold, so the sheet covered them until dismissed. That placement issue is addressed in the subsequent `2026-10-05-personal-entry-inline-errors.md` validation. The reset action is verified through its code path and tests; it was not triggered on the user's phone.
