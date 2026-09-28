# Content Style


## Purpose

Define writing standards for UI text: labels, helper text, calls to action, loading text, error states, and empty states.

## Voice And Tone

- Use clear, neutral, professional language.
- Prefer short, direct sentences.
- Describe facts and outcomes, not emotions.
- Keep text user-centered and action-oriented.

## General Rules

- Use `AppLocalizations` for user-facing copy. The app currently supports German (`de`); maintain strings in `lib/core/l10n/app_de.arb` and generate localization code.
- Keep developer documentation in English; do not introduce English UI text into the German flow.
- Use sentence case for labels and messages.
- Use consistent naming for same concepts across screens.
- Avoid internal technical terms in user-facing text unless necessary.

## Labels And Field Text

Use:

- Specific labels (`Dienstgruppe`) instead of vague labels (`Option`).
- Stable terminology across setup, settings, and calendar.

Avoid:

- Abbreviations unless universally known.
- Different labels for identical actions.

## Action Text (Buttons, Menu Items)

Use verbs:

- `Einstellungen speichern`
- `Erneut laden`
- `Dienstplan auswählen`
- `Kalender exportieren`

Avoid:

- Generic action text like `Weiter` when context is unclear.
- Multiple buttons with near-identical text but different behavior.

## Loading Text

Use:

- Short descriptions of the operation (`Dienstpläne werden geladen …`).
- Optional context when operation is not obvious.

Avoid:

- Empty loading indicators with no context in long operations.

## Error Messages

Describe the failed operation and a useful next step.

- Example: `Dienstpläne konnten nicht geladen werden. Prüfe deine Internetverbindung und versuche es erneut.`
- Keep technical reason codes and stack traces in logs, not user-facing messages.

Guidelines:

- State what failed.
- Add useful context when possible.
- Offer a recovery action (`Erneut versuchen`).
- Keep wording neutral and precise.

Avoid:

- Vague text (`Etwas ist schiefgelaufen`).
- Blaming language.

## Empty States

Use:

- Explain what is missing and why.
- Suggest next step (`Wähle einen Dienstplan aus, um fortzufahren`).

Avoid:

- Empty containers with no explanatory text.

## Confirmation And Destructive Flows

Use:

- Clear impact statement for destructive actions.
- Explicit action labels (`Alle Daten löschen`), not ambiguous (`Bestätigen`).
- Optional secondary line for irreversibility when relevant.

## Accessibility And Readability

- Keep messages concise for small screens.
- Avoid text-only distinction where icon or state affordance is needed.
- Ensure message contrast remains readable on glass surfaces.

## Reuse Guidance

- Keep recurring strings in localization resources.
- Reuse existing translation keys where semantics are identical.
- Add new keys only when meaning differs.
