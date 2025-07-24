# Presentation Layer Optimization Plan

## 🎯 Ziel: Optimale Organisation und Skalierbarkeit

### 📁 **Aktuelle Struktur - Probleme:**

```
lib/presentation/
├── 📂 controllers/                    # ❌ Zu große Controller
│   ├── schedule_controller.dart       # 41KB - zu groß!
│   ├── settings_controller.dart       # ✅ OK
│   └── cached_controller.dart         # ✅ OK
│
├── 📂 screens/                        # ❌ Inkonsistente Organisation
│   ├── calendar_screen.dart           # Sollte in widgets/screens/
│   ├── setup_screen.dart              # Sollte in widgets/screens/
│   ├── settings_screen.dart           # Sollte in widgets/screens/
│   └── app_initializer_widget.dart    # Sollte in widgets/common/
│
└── 📂 widgets/                        # ❌ Doppelte Hierarchie
    ├── 📂 screens/                    # Doppelte screens/ Hierarchie
    │   ├── 📂 calendar/               # ✅ Gut strukturiert
    │   ├── 📂 settings/               # ❌ Zu wenig strukturiert
    │   └── 📂 setup/                  # ❌ Zu wenig strukturiert
    └── 📂 common/                     # ✅ Gut
```

### 📁 **Optimale Struktur - Vorschlag:**

```
lib/presentation/
├── 📂 core/                           # Hauptkomponenten
│   ├── app.dart                       # App-Hauptkomponente
│   └── app_initializer.dart           # App-Initialisierung
│
├── 📂 screens/                        # Screen-Hauptkomponenten
│   ├── calendar_screen.dart           # Calendar Screen
│   ├── settings_screen.dart           # Settings Screen
│   └── setup_screen.dart              # Setup Screen
│
├── 📂 controllers/                    # Business Logic Controller
│   ├── 📂 schedule/                   # Schedule-spezifische Controller
│   │   ├── schedule_controller.dart   # Haupt-Controller (aufgeteilt)
│   │   ├── schedule_navigation_controller.dart
│   │   └── schedule_filter_controller.dart
│   │
│   ├── 📂 settings/                   # Settings-spezifische Controller
│   │   ├── settings_controller.dart
│   │   └── settings_cache_controller.dart
│   │
│   └── 📂 common/                     # Gemeinsame Controller
│       └── cached_controller.dart
│
├── 📂 widgets/                        # Wiederverwendbare UI-Komponenten
│   ├── 📂 common/                     # App-weite Komponenten
│   │   ├── 📂 cards/
│   │   ├── 📂 buttons/
│   │   ├── 📂 dialogs/
│   │   └── step_indicator.dart
│   │
│   ├── 📂 calendar/                   # Calendar-spezifische Komponenten
│   │   ├── 📂 core/                   # Hauptkomponenten
│   │   ├── 📂 components/             # UI-Komponenten
│   │   ├── 📂 builders/               # UI Builder Pattern
│   │   ├── 📂 hooks/                  # Business Logic Hooks
│   │   ├── 📂 utils/                  # Hilfsfunktionen
│   │   └── 📂 models/                 # Datenmodelle
│   │
│   ├── 📂 settings/                   # Settings-spezifische Komponenten
│   │   ├── 📂 core/                   # Hauptkomponenten
│   │   ├── 📂 components/             # UI-Komponenten
│   │   ├── 📂 dialogs/                # Settings-Dialoge
│   │   └── 📂 utils/                  # Hilfsfunktionen
│   │
│   └── 📂 setup/                      # Setup-spezifische Komponenten
│       ├── 📂 core/                   # Hauptkomponenten
│       ├── 📂 components/             # UI-Komponenten
│       └── 📂 utils/                  # Hilfsfunktionen
│
└── 📂 models/                         # Presentation Models
    ├── 📂 calendar/
    ├── 📂 settings/
    └── 📂 setup/
```

## 🔄 **Migration-Plan:**

### **Phase 1: Controller aufteilen**
1. **ScheduleController aufteilen** (41KB → 3x ~15KB)
   - `schedule_controller.dart` - Hauptlogik
   - `schedule_navigation_controller.dart` - Navigation
   - `schedule_filter_controller.dart` - Filterung

### **Phase 2: Ordnerstruktur reorganisieren**
1. **Screens in widgets/ verschieben**
2. **Common Widgets konsolidieren**
3. **Screen-spezifische Widgets gruppieren**

### **Phase 3: Konsistente Struktur**
1. **Alle Screens** folgen der gleichen Struktur
2. **Controller** sind nach Domains gruppiert
3. **Widgets** sind logisch organisiert

## ✅ **Vorteile der optimalen Struktur:**

### **1. Skalierbarkeit:**
- Neue Features finden ihren Platz
- Modulare Architektur
- Einfache Erweiterung

### **2. Wartbarkeit:**
- Klare Verantwortlichkeiten
- Einfache Navigation
- Bessere Code-Reviews

### **3. Testbarkeit:**
- Isolierte Komponenten
- Einfache Mock-Objekte
- Klare Test-Struktur

### **4. Teamarbeit:**
- Weniger Merge-Konflikte
- Klare Ownership
- Einfache Onboarding

## 🚀 **Nächste Schritte:**

1. **ScheduleController aufteilen** (höchste Priorität)
2. **Screen-Widgets konsolidieren**
3. **Common Widgets erweitern**
4. **Konsistente Struktur implementieren** 