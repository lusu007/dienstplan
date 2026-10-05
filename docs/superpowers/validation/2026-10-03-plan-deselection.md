# Direct duty-plan deselection

User requested removing the extra no-plan row and deselecting the current plan by tapping it again. This supersedes the October 2 confirmation-only plan contract.

The common plan picker now calls its selection callback exactly once with null on a selected-row tap, and with the configuration on an unselected-row tap. It dismisses in either case. Removed the redundant no-plan-row API and both own/partner callers. Existing clear handlers remove the associated own/partner group; group picker behavior is unchanged.

Regression test first failed against the confirmation-only code, then passed for deselection, dismissal and reselection with exactly one callback each. Full suite: 141 passed. Analyzer: no issues. APK build and final device check recorded after completion below.

ARM64 dev debug APK built and installed successfully. Native own-plan picker filtered to the selected authority shows only the actual plans, with no no-plan row. Dismissed without altering saved selection; launcher reopened. Shared picker implements the same behavior for partner plans.
