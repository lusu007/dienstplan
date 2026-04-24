# Content Style

## Purpose
Define writing standards for UI text: labels, helper text, calls to action, loading text, error states, and empty states.

## Voice And Tone
- Use clear, neutral, professional language.
- Prefer short, direct sentences.
- Describe facts and outcomes, not emotions.
- Keep text user-centered and action-oriented.

## General Rules
- Use English consistently in UI copy.
- Use sentence case for labels and messages.
- Use consistent naming for same concepts across screens.
- Avoid internal technical terms in user-facing text unless necessary.

## Labels And Field Text
Use:
- Specific labels (`Preferred duty group`) instead of vague labels (`Option`).
- Stable terminology across setup, settings, and calendar.

Avoid:
- Abbreviations unless universally known.
- Different labels for identical actions.

## Action Text (Buttons, Menu Items)
Use verbs:
- `Save settings`
- `Retry loading`
- `Select language`
- `Export calendar`

Avoid:
- Generic action text like `Continue` when context is unclear.
- Multiple buttons with near-identical text but different behavior.

## Loading Text
Use:
- Short present-progress phrasing (`Loading schedules...`).
- Optional context when operation is not obvious.

Avoid:
- Empty loading indicators with no context in long operations.

## Error Messages
Use this structure:
- `<action> <result> (context)`
- Example: `Failed to load schedules (reason=network_unavailable)`

Guidelines:
- State what failed.
- Add useful context when possible.
- Offer a recovery action (`Try again`).
- Keep wording neutral and precise.

Avoid:
- Vague text (`Something went wrong`).
- Blaming language.

## Empty States
Use:
- Explain what is missing and why.
- Suggest next step (`Select a schedule to continue`).

Avoid:
- Empty containers with no explanatory text.

## Confirmation And Destructive Flows
Use:
- Clear impact statement for destructive actions.
- Explicit action labels (`Delete all data`), not ambiguous (`Confirm`).
- Optional secondary line for irreversibility when relevant.

## Accessibility And Readability
- Keep messages concise for small screens.
- Avoid text-only distinction where icon or state affordance is needed.
- Ensure message contrast remains readable on glass surfaces.

## Reuse Guidance
- Keep recurring strings in localization resources.
- Reuse existing translation keys where semantics are identical.
- Add new keys only when meaning differs.
