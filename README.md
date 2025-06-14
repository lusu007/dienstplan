# Duty Schedule Calendar

A mobile application for managing and displaying duty schedules for police officers, available for both Android and iOS platforms.


## Description

This application enables police officers to easily and clearly view their duty schedules. The application offers the following main features:

- Management of various duty schedules in a database
- Selection of personal duty schedule by the user
- Clear calendar view of duty times
- User-friendly interface for easy navigation
- Offline access to duty schedules
- Push notifications for schedule updates

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0) - see the [LICENSE](LICENSE) file for details.

### Important License Information

- The complete source code is available under the AGPL-3.0 license
- You are free to:
  - View and study the source code
  - Modify the code for your own use
  - Compile and run the application for yourself
- You are NOT allowed to:
  - Redistribute modified versions without also making the source code available
  - Use the code in a closed-source project
  - Remove or modify the license notices

### Commercial Use

While the source code is open source, the compiled application is available for purchase in the app stores. This means:
- You can buy the app from the official stores
- You can compile and use the app yourself from source
- You cannot distribute your own compiled versions

## Duty Groups (Dienstgruppen)

The duty schedule system is organized into 5 duty groups (Dienstgruppen 1-5). Each group follows the same duty schedule pattern, but with a one-week offset from each other. This rotation system ensures continuous coverage while maintaining a fair and predictable work schedule for all officers.

Key features of the duty group system:
- 5 distinct duty groups (Dienstgruppen 1-5)
- Identical duty schedule pattern across all groups
- One-week offset between consecutive groups
- Clear visualization of group assignments in the calendar
- Easy switching between different duty group views

## Technical Details

### Schedule Configuration Format

The duty schedules are defined in JSON format and stored in the `assets/schedules/` directory. Each configuration file follows this structure:

```json
{
  "name": "ESD Polizei Bremen",
  "startDate": "2024-01-01",
  "rhythms": [
    {
      "name": "Week 1",
      "pattern": [
        {
          "dutyType": "ZD",
          "days": [1, 2, 3, 4, 5]
        },
        {
          "dutyType": "Frei",
          "days": [6, 7]
        }
      ]
    }
  ],
  "dutyGroups": [
    {
      "id": 1,
      "name": "Dienstgruppe 1",
      "offsetWeeks": 1
    }
  ],
  "dutyTypes": [
    {
      "id": "ZD",
      "name": "Zusatzdienst",
      "startTime": "08:00",
      "endTime": "16:00",
      "isAllDay": false
    }
  ]
}
```

#### Key Components

1. **Configuration**
   - `name`: Display name of the schedule
   - `startDate`: Reference date for schedule calculation
   - `rhythms`: Array of weekly patterns
   - `dutyGroups`: Array of duty groups with their offsets
   - `dutyTypes`: Available duty types and their properties

2. **Rhythm Pattern**
   - Each rhythm represents one week
   - Contains an array of duty assignments
   - Each assignment specifies:
     - `dutyType`: Type of duty
     - `days`: Array of days (1-7, where 1 is Monday)

3. **Duty Groups**
   - Each group has a unique ID and name
   - `offsetWeeks`: Number of weeks offset from the start date
   - Groups rotate through the rhythm pattern with their offset

4. **Duty Types**
   - Defines all possible duty types
   - Each type specifies:
     - `id`: Unique identifier
     - `name`: Display name
     - `startTime`: Start time (HH:mm)
     - `endTime`: End time (HH:mm)
     - `isAllDay`: Flag for all-day duties

#### Schedule Generation

The application generates schedules by:
1. Loading the configuration file
2. Calculating the week index based on the date and group offset
3. Applying the rhythm pattern for that week
4. Creating schedule entries for each day
5. Storing the generated schedules in the local database

#### Example Schedule

```json
{
  "name": "ESD Polizei Bremen",
  "startDate": "2024-01-01",
  "rhythms": [
    {
      "name": "Week 1",
      "pattern": [
        {
          "dutyType": "ZD",
          "days": [1, 2, 3, 4, 5]
        },
        {
          "dutyType": "Frei",
          "days": [6, 7]
        }
      ]
    },
    {
      "name": "Week 2",
      "pattern": [
        {
          "dutyType": "Nacht",
          "days": [1, 2]
        },
        {
          "dutyType": "Frei",
          "days": [3, 4]
        },
        {
          "dutyType": "Früh",
          "days": [5, 6, 7]
        }
      ]
    }
  ]
}
```

## Installation

1. Ensure you have Flutter installed on your system. If not, follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install).

2. Clone the repository:
```bash
git clone https://github.com/yourusername/dienstplan.git
cd dienstplan
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Usage

1. Launch the app
2. Select your duty group (Dienstgruppe) from the settings
3. The calendar will display your duty schedule
4. Use the calendar navigation to view different months
5. Tap on a day to see detailed duty information

## Development

The project follows clean architecture principles and uses the following key technologies:

- Flutter for cross-platform development
- Riverpod for state management
- SQLite for local data storage
- TableCalendar for calendar visualization
- Flutter Local Notifications for push notifications

### Project Structure

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # Business logic
├── widgets/        # Reusable widgets
└── main.dart       # Application entry point
```

### Building for Production

To build the app for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure to update tests as appropriate and follow the existing code style.

### Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) to keep our community approachable and respectable.
