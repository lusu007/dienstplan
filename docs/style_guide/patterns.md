# Patterns


## Purpose

Define repeatable page and interaction patterns so users get a consistent experience across modules.

## Screen Patterns


### Standard Screen Shell

Use:

- `GlassScreenScaffold` for screen frame and header.
- Shared spacing rhythm across sections.
- Shared glass cards for grouped content.

Avoid:

- Introducing custom top bars on one module without design rationale.
- Mixing old Material containers with glass surfaces in the same flow.

### Settings Navigation

- `SettingsScreen` is a five-category overview: own schedule, partner schedule, appearance, holidays, and app/privacy.
- Open `SettingsCategoryRoute` with the matching `SettingsCategory.name`. Build the relevant sections on the category page rather than loading every feature on the overview.
- Keep copyright, version, and open-source footer on the overview, bottom-aligned with `SliverFillRemaining` when space permits.
- Settings routes currently use zero-duration transitions to avoid full-page glass compositing cost. This rule does not apply to bottom sheets.
- Configure the partner schedule through the partner settings category. Configured partner duties remain visible in the calendar.
- Keep the today action beside the month/year picker; the bottom calendar bar contains quick entry and add actions.

## Modal Patterns


### Bottom Sheets

Use:

- `GlassBottomSheet` (directly or via a thin wrapper like `GenericBottomsheet`).
- Consistent handle, title treatment, and body spacing.
- Preserve the opening and closing slide motion and use `glassSurfaceBlurBottomSheet`.
- In `GlassBottomSheet`, defer the scroll-edge fade until the opening transition settles; keep blur present throughout the animation.
- The theme picker uses library `GlassSheet.show()` directly; see the exception in [Components](./components.md).

Avoid:

- Plain surface fallback states that visually diverge from the normal sheet state.

### Dialogs

Use:

- `GlassDialogSurface` as root visual wrapper.
- Shared title/body/action structure.

Avoid:

- Nested custom blur wrappers that duplicate dialog styling.

## List And Card Patterns

Use:

- `GlassCard` for standalone cards and selectable items; `GlassCardGroup` for related settings rows with one shared surface.
- Active states through existing card options (`isActive`, `enabled`).

Avoid:

- Local `Container + BoxDecoration` recipes for card-like rows.

## State Patterns


### Loading

Use:

- Keep loading inside the same visual container style as loaded state.
- Prefer skeletons or progress indicators that do not shift visual language.

### Error

Use:

- Clear, neutral, actionable messages.
- Error visuals aligned with same card/sheet shell as success state.

Avoid:

- Generic or ambiguous error text.

### Empty State

Use:

- Explain why no content is shown.
- Add next action where possible.

Avoid:

- Empty states with no context.

## Interaction Patterns

- Tap targets should be clearly visible on translucent backgrounds.
- Disabled states must remain readable, not only faded.
- Active and focus states should use consistent visual emphasis.

## Calendar Day States


Month grid cells are **not** wrapped in `GlassContainer` (no `BackdropFilter` per day — performance). They use **glass-adjacent** styling from [calendar_day_surface_tokens.dart](../../lib/core/constants/calendar_day_surface_tokens.dart): `ColorScheme.primary` tint and border alphas from [glass_tokens.dart](../../lib/core/constants/glass_tokens.dart), aligned with [foundations.md](./foundations.md).

- **Today**: lighter primary tint + soft border (same token family as glass surfaces).
- **Selected**: stronger active tint + `glassBorderAlphaActive` border; day number follows [`calendarDaySelectedDayNumberColor`](../../lib/core/constants/calendar_day_surface_tokens.dart) (`ColorScheme.primary` in light mode, `onSurface` in dark mode).
- **TableCalendar fallback** (`CalendarStyle` circles) uses the same fill/border recipe so underlays stay consistent with [AnimatedCalendarDay](../../lib/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart).

## Module Alignment Notes

- **Calendar**: prioritize harmonizing inner custom glass recipes with shared surfaces.
- **Settings**: keep all bottom sheet variants aligned via shared shell.
- **Setup/About**: keep decorative variants, but preserve token consistency.
- **Debug**: preserve existing shared glass surfaces when extending the screen.

## Performance Validation

- Measure cold first opening and repeated opening separately in a profile build on a physical device.
- Check both UI and raster frame times; do not assume opening lag is data loading.
- Compare equivalent interactions and retain animation and text visibility checks. Lower sheet blur and suppressed trigger ink reduce some rendering work, but do not guarantee a smooth first opening.


## Light Mode readability and button changes

Picker, filter and color selections use semantic dark foregrounds plus visible selection markers in Light Mode. Calendar badges choose the higher-contrast black/white foreground after alpha composition with the actual background; neutral outside-month badges use their rendered fill. The existing Dark Mode badge algorithm and accent input remain unchanged.

Modal content uses the 0.90 Light surface fill from `glassDialogContentAlphaLight`; Dark surfaces, quality and opening behavior stay unchanged. Theme selection follows the current theme without replacing the modal route.

Use `AppGlassButton` roles and `AppGlassIconButton` for actions. Minimum touch targets are 48 dp, while compact visible icons may remain 36/40 dp. In the compact Dark calendar header, adaptive vertical padding compensates for the larger targets so the date and duty list keep their previous positions, including larger text.

Active Light Mode navigation rows without a custom trailing show an opening indicator. Missing federal-state prerequisites explain disabled holiday controls. All-day entries hide the unused time row only in Light Mode. Data and navigation behavior remain shared across themes.

Light picker selection markers move above year labels when the row would overflow; labels keep their configured text size. Light picker triggers may scale down a long numerical year range inside the existing fixed-height pill, keeping the complete range visible. The normal month/Today pair retains equal adaptive heights.

On narrow Light feedback forms or larger text, an attached screenshot uses a separate remove-action row below its preview/status. Scrollable Light app dialogs constrain their body so the confirmation action remains visible. These responsive changes preserve the existing Dark layouts.
