# 📅 Duty Schedule Calendar

A cross-platform mobile app for managing and viewing duty schedules — designed specifically for police officers. Available for **Android** and **iOS**.

---

## 🚀 Overview

**Duty Schedule Calendar** makes it simple for officers to access and manage their duty plans at any time. It features:

- 📚 Support for multiple predefined duty schedules
- 👤 User selection of their specific duty schedule
- 🗓 Intuitive calendar-based display of duty times
- 📱 Clean and user-friendly interface
- 🌐 Full offline access to schedules

---

## ⚖️ License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)** – see the [LICENSE](LICENSE) file for details.

### Summary

✔️ You may:
- View, study, and modify the code for personal use  
- Compile and run the application yourself  

❌ You may *not*:
- Redistribute modified versions without publishing their source code  
- Integrate this code in closed-source projects  
- Remove or alter license notices  

### Commercial Use

While the source is open, the **compiled version** is distributed commercially in app stores:
- ✅ You may purchase or build the app for personal use  
- ❌ You may *not* distribute your own compiled builds  

---

## ⚙️ Technical Overview

### 📁 Schedule Configuration Format

Duty schedules are defined via JSON in `assets/schedules/`. Example structure:

```json
{
  "name": "ESD Polizei Bremen",
  "startDate": "2024-01-01",
  "rhythms": [
    {
      "name": "Week 1",
      "pattern": [
        { "dutyType": "ZD", "days": [1, 2, 3, 4, 5] },
        { "dutyType": "Frei", "days": [6, 7] }
      ]
    }
  ],
  "dutyGroups": [
    { "id": 1, "name": "Dienstgruppe 1", "offsetWeeks": 1 }
  ],
  "dutyTypes": [
    { "id": "ZD", "name": "Zusatzdienst", "startTime": "08:00", "endTime": "16:00", "isAllDay": false }
  ]
}
```

### 🔍 Components Explained

- **Configuration**
  - `name`, `startDate`: Metadata for the schedule
  - `rhythms`: Defines weekly patterns
  - `dutyGroups`: Includes ID, name, and offset
  - `dutyTypes`: Defines all known duty types

- **Rhythm Pattern**
  - Weekly definitions of duties
  - `days`: 1 = Monday, 7 = Sunday

- **Schedule Generation Flow**
  1. Load JSON config  
  2. Calculate current week with offset  
  3. Apply rhythm  
  4. Store result in local SQLite DB  

#### 🔄 Extended Example

```json
{
  "rhythms": [
    {
      "name": "Week 1",
      "pattern": [
        { "dutyType": "ZD", "days": [1, 2, 3, 4, 5] },
        { "dutyType": "Frei", "days": [6, 7] }
      ]
    },
    {
      "name": "Week 2",
      "pattern": [
        { "dutyType": "Nacht", "days": [1, 2] },
        { "dutyType": "Frei", "days": [3, 4] },
        { "dutyType": "Früh", "days": [5, 6, 7] }
      ]
    }
  ]
}
```

---

## 🛠 Installation

### Prerequisites
- Install [Flutter](https://flutter.dev/docs/get-started/install)

### Steps

```bash
# Clone the repo
git clone https://github.com/yourusername/dienstplan.git
cd dienstplan

# Get dependencies
flutter pub get

# Launch the app
flutter run
```

---

## 📱 How to Use

1. Open the app  
2. Select your duty schedule in the settings  
3. View your duties in the calendar  
4. Tap a date to see details  
5. Receive automatic notifications about changes  

---

## 🧱 Architecture & Tech Stack

- **Flutter** – Cross-platform UI  
- **Riverpod** – State management  
- **SQLite** – Local database  
- **TableCalendar** – Calendar UI  
- **Flutter Local Notifications** – Native alerts  

### 📁 Directory Structure

```
lib/
├── models/         # Data structures
├── providers/      # State management logic
├── screens/        # App screens
├── services/       # Business logic & persistence
├── widgets/        # Reusable UI components
└── main.dart       # Entry point
```

---

## 📦 Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🤝 Contributing

1. Fork the repo  
2. Create a feature branch  
   `git checkout -b feature/my-feature`  
3. Commit your changes  
   `git commit -m 'Add new feature'`  
4. Push and create a Pull Request  

> Please follow the code style and update/add tests where applicable.

---

## 📜 Code of Conduct

We expect contributors to follow our [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a respectful and inclusive community.