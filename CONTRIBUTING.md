# 🤝 Contributing to Dienstplan

Thank you for your interest in contributing! This guide will help you get started quickly.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Git

### Setup
```bash
# Fork and clone
git clone https://github.com/lusu007/dienstplan.git
cd dienstplan

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🔄 Development Workflow

### 1. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes
- Follow the coding standards below
- Test your changes with `flutter test`
- Ensure code passes `flutter analyze`

### 3. Submit a Pull Request
```bash
git add .
git commit -m "feat: add new feature description"
git push origin feature/your-feature-name
```

Then create a PR on GitHub with a clear description of your changes.

#### Conventional Commits
We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages:

**Format:**
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only changes
- `style:` - Changes that do not affect the meaning of the code
- `refactor:` - Code change that neither fixes a bug nor adds a feature
- `perf:` - Code change that improves performance
- `test:` - Adding missing tests or correcting existing tests
- `chore:` - Changes to the build process or auxiliary tools

**Examples:**
```bash
feat: add user authentication system
fix(ui): resolve button alignment issue
docs(readme): update installation instructions
refactor(service): simplify data processing logic
perf(api): optimize database queries
test(auth): add unit tests for login functionality
chore(deps): update dependencies to latest versions
```

**Breaking Changes:**
Use `!` after the type/scope to indicate breaking changes:
```bash
feat!: change API response format
fix(api)!: remove deprecated endpoint
```

---

## 📝 Code Standards

### Naming Conventions
- **Classes**: `PascalCase` (e.g., `DutySchedule`)
- **Variables/Functions**: `camelCase` (e.g., `dutyGroup`)
- **Files**: `snake_case` (e.g., `duty_schedule.dart`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_DUTY_HOURS`)

### Best Practices
- Keep functions small and focused
- Use meaningful variable names
- Add comments for complex logic
- Follow existing code style
- Write tests for new functionality

### Project Structure
```
lib/
├── constants/     # App constants
├── dialogs/       # Reusable dialogs
├── l10n/         # Localization
├── models/       # Data models
├── providers/    # State management
├── screens/      # App screens
├── services/     # Business logic
├── utils/        # Utilities
├── widgets/      # UI components
└── main.dart     # Entry point
```

---

## 🧪 Testing

### Running Tests
```bash
# All tests
flutter test

# Specific file
flutter test test/services/service_test.dart
```

### Writing Tests
```dart
test('should return expected result', () {
  // Arrange
  final service = Service();
  final input = 'test';
  
  // Act
  final result = service.process(input);
  
  // Assert
  expect(result, isNotNull);
  expect(result.value, equals('expected'));
});
```

---

## 🔧 Development Tools

### Code Signing
- **Development**: No signing required for local development
- **Production**: Automated signing via CI/CD with secure keystore
- **Testing**: Use `flutter build apk --release` (unsigned) for testing

### Useful Commands
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Clean build
flutter clean && flutter pub get

# Build for release (unsigned)
flutter build apk --release
flutter build appbundle --release
```

---

## 🌍 Localization

### Adding Translations
1. Update English localization file
2. Update German localization file
3. Run localization generation command
4. Test with different locales

---

## 📞 Getting Help

- **Questions**: Use GitHub Discussions
- **Issues**: Check existing issues before creating new ones
- **Code Reviews**: Be respectful and constructive

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the project's license.

---

**Thank you for contributing! 🚀** 