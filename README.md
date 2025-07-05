# 📅 Dienstplan - Police Duty Schedule App

[![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)](https://github.com/lusu007/dienstplan/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.32.4-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-AGPL--3.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-orange.svg)](https://github.com/lusu007/dienstplan)

A modern, cross-platform mobile application designed specifically for police officers to manage and view their duty schedules. Built with Flutter for optimal performance and user experience.

---

## 🚀 Features

### 📱 Core Functionality
- **📅 Calendar View**: Intuitive calendar interface showing duty schedules
- **👥 Duty Group Selection**: Choose your preferred duty group for personalized views
- **🔄 Offline Access**: Full offline functionality - no internet required
- **⚡ Fast Performance**: Optimized with database indexes for quick loading
- **🌍 Localization**: Multi-language support with German as primary language

### 🛠 Advanced Features
- **📊 Multiple Schedule Support**: Load and manage different duty schedule configurations
- **🎯 Preferred Duty Group**: Set your preferred duty group for quick access
- **📋 Duty Details**: Tap any date to view detailed duty information
- **🔧 Flexible Configuration**: JSON-based schedule configuration system
- **📱 Modern UI**: Clean, intuitive interface optimized for mobile use

### 🔒 Privacy & Security
- **🔐 Local Storage**: All data stored locally on your device
- **🚫 No Cloud Sync**: Your schedule data never leaves your device
- **📊 No Analytics**: No tracking or data collection

---

## 📦 Installation

### From App Store
- **Direct APK**: Available in [GitHub Releases](https://github.com/lusu007/dienstplan/releases)

### From Source
```bash
# Clone the repository
git clone https://github.com/lusu007/dienstplan.git
cd dienstplan

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for production
flutter build apk --release
```

For detailed development setup and workflow, see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 🏗 Architecture

### Schedule Format
Duty schedules are defined using JSON configuration files in `assets/schedules/`. The format supports comprehensive schedule management:

```json
{
  "version": "1.1",
  "meta": {
    "name": "Example Duty Schedule",
    "created_by": "Schedule Creator",
    "description": "Example rotation schedule for demonstration",
    "start_week_day": "Monday",
    "start_date": "2024-01-01",
    "days": ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
  },
  "duty_types": {
    "F": {
      "label": "Frühdienst"
    },
    "S": {
      "label": "Spätdienst"
    },
    "N": {
      "label": "Nachtdienst"
    },
    "ZD": {
      "label": "Zusatzdienst",
      "all_day": true
    },
    "-": {
      "label": "Frei",
      "all_day": true
    }
  },
  "duty_type_order": ["F", "S", "N", "ZD", "-"],
  "rhythms": {
    "example_rhythm": {
      "length_weeks": 4,
      "pattern": [
        ["-", "F", "F", "F", "F", "-", "-"],
        ["S", "S", "S", "S", "-", "-", "-"],
        ["N", "N", "N", "-", "-", "-", "-"],
        ["-", "-", "-", "ZD", "ZD", "-", "-"]
      ]
    }
  },
  "dienstgruppen": [
    {
      "id": "DG1",
      "name": "Dienstgruppe 1",
      "rhythm": "example_rhythm",
      "offset_weeks": 0
    }
  ]
}
```

### Configuration Elements

#### **Metadata (`meta`)**
- **`name`**: Display name for the schedule
- **`created_by`**: Author of the schedule
- **`description`**: Detailed description of the schedule
- **`start_week_day`**: First day of the week (e.g., "Monday")
- **`start_date`**: Reference date for schedule calculations
- **`days`**: Array of day abbreviations

#### **Duty Types (`duty_types`)**
- **`id`**: Short identifier (e.g., "F", "S", "N")
- **`label`**: Human-readable name
- **`all_day`**: Optional flag for all-day duties

#### **Duty Type Order (`duty_type_order`)**
- Defines the display order of duty types in the UI
- Controls sorting and grouping of duties

#### **Rhythms (`rhythms`)**
- **`length_weeks`**: Duration of the rotation cycle
- **`pattern`**: Array of weekly patterns
- **`pattern[week][day]`**: Duty type for each day of each week

#### **Duty Groups (`dienstgruppen`)**
- **`id`**: Unique identifier for the group
- **`name`**: Display name
- **`rhythm`**: Reference to rhythm configuration
- **`offset_weeks`**: Week offset from the start date

### Advanced Features
- **Multiple Rhythms**: Support for different rotation patterns
- **Flexible Duty Types**: Custom duty types with labels and flags
- **Week Offsets**: Different groups can start at different weeks
- **All-Day Duties**: Special handling for full-day assignments
- **Version Control**: Schema versioning for compatibility

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for detailed information on:

- 🚀 Development setup and workflow
- 📝 Code standards and best practices
- 🧪 Testing guidelines
- 📋 Pull request process
- 🐛 Issue reporting
- 🏗 Project structure and architecture

### Quick Start
1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature`
3. **Make your changes** following our coding standards
4. **Test thoroughly** with `flutter test`
5. **Submit a pull request** with a clear description

For questions and discussions, please use [GitHub Discussions](https://github.com/lusu007/dienstplan/discussions).

---

## 📄 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

### License Summary
✅ **You may**:
- View, study, and modify the source code
- Compile and run the application for personal use
- Distribute modified versions with source code

❌ **You may not**:
- Use in closed-source projects without publishing source
- Remove or alter license notices
- Distribute compiled versions commercially without permission

### Commercial Use
- **Source code**: Open source under AGPL-3.0
- **Compiled app**: Available commercially in app stores
- **Personal builds**: Allowed for personal use

---

## 📞 Support

### Getting Help
- **GitHub Issues**: [Report bugs or request features](https://github.com/lusu007/dienstplan/issues)
- **Documentation**: Check the code comments and this README
- **Community**: Join discussions in GitHub Discussions

---

**Built with ❤️ for police officers in Germany**