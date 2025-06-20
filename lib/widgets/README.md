# Widgets Directory Structure

This directory contains all reusable UI components organized by functionality.

## Directory Organization

### `/calendar/`
Calendar-related widgets and components:
- `calendar_builders.dart` - Calendar builders helper
- `calendar_config.dart` - Calendar configuration constants
- `calendar_day_builder.dart` - Individual calendar day widget
- `calendar_header.dart` - Calendar header component
- `services_section.dart` - Services display section

### `/dialogs/`
Dialog and modal components:
- `app_about_dialog.dart` - About dialog component
- `app_dialog.dart` - Base dialog component
- `app_license_page.dart` - License page component
- `dialog_close_button.dart` - Dialog close button
- `dialog_selection_card.dart` - Selection card for dialogs

### `/forms/`
Form and input components:
- `action_button.dart` - Primary and secondary action buttons
- `language_selector_button.dart` - Language selection button
- `selection_card.dart` - Selection card component
- `step_indicator.dart` - Multi-step process indicator

### `/layout/`
Layout and structural components:
- `schedule_list.dart` - Schedule list component
- `section_header.dart` - Section header component

### `/settings/`
Settings screen components:
- `settings_card.dart` - Settings card component
- `settings_section.dart` - Settings section wrapper

## Usage Guidelines

1. **Place new widgets** in the appropriate subdirectory based on their functionality
2. **Use descriptive names** that clearly indicate the widget's purpose
3. **Follow the existing patterns** for component structure and styling
4. **Update imports** when moving or reorganizing widgets
5. **Keep components focused** on a single responsibility

## Import Examples

```dart
// Calendar widgets
import 'package:dienstplan/widgets/calendar/calendar_header.dart';

// Dialog widgets
import 'package:dienstplan/widgets/dialogs/app_dialog.dart';

// Form widgets
import 'package:dienstplan/widgets/forms/action_button.dart';

// Layout widgets
import 'package:dienstplan/widgets/layout/section_header.dart';

// Settings widgets
import 'package:dienstplan/widgets/settings/settings_card.dart';
``` 