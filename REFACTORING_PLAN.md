# Calendar Folder Structure Refactoring Plan

## 🎯 Ziel: Bessere Organisation und Wartbarkeit ✅ **ABGESCHLOSSEN**

### 📁 **Neue Struktur (IMPLEMENTIERT):**

```
lib/presentation/widgets/screens/calendar/
├── 📂 core/                          # Hauptkomponenten ✅
│   ├── calendar_view.dart            # Hauptscreen
│   ├── calendar_view_controller.dart # Controller
│   └── calendar_app_bar.dart         # App Bar
│
├── 📂 components/                     # Wiederverwendbare UI-Komponenten ✅
│   ├── 📂 header/
│   │   ├── calendar_header.dart      # Kalender-Header
│   │   └── calendar_date_selector_header.dart
│   │
│   ├── 📂 grid/
│   │   ├── calendar_grid.dart        # Kalender-Grid
│   │   ├── calendar_day_card.dart    # Tag-Karte
│   │   └── calendar_day_builder.dart # Tag-Builder
│   │
│   ├── 📂 sheet/
│   │   ├── calendar_sheet.dart       # Sheet-Container
│   │   ├── day_page_view.dart        # Tag-Seitenansicht
│   │   └── services_section.dart     # Services-Bereich
│   │
│   ├── 📂 list/
│   │   ├── schedule_list.dart        # Schedule-Liste
│   │   ├── filter_status.dart        # Filter-Status
│   │   ├── duty_schedule_list.dart   # Duty-Liste
│   │   ├── duty_item_card.dart       # Duty-Item-Karte
│   │   └── duty_schedule_header.dart # Duty-Header
│   │
│   └── 📂 date_selector/
│       ├── calendar_date_selector.dart    # Datums-Auswahl
│       ├── animated_calendar_day.dart     # Animierter Tag
│       └── duty_group_selector_widget.dart
│
├── 📂 builders/                       # UI Builder Pattern ✅
│   ├── calendar_view_ui_builder.dart
│   ├── calendar_builders_helper.dart
│   ├── duty_item_ui_builder.dart
│   └── duty_item_list.dart
│
├── 📂 hooks/                          # Business-Logik Hooks ✅
│   └── calendar_navigation_hook.dart
│
├── 📂 utils/                          # Hilfsfunktionen ✅
│   ├── calendar_navigation_helper.dart
│   ├── schedule_filter_helper.dart
│   ├── schedule_sort_helper.dart
│   ├── schedule_list_animation_mixin.dart
│   └── calendar_view_animations.dart
│
└── 📂 models/                         # Datenmodelle (neu) ✅
    └── (bereit für zukünftige Modelle)
```

## ✅ **Migration abgeschlossen:**

### **Phase 1: Neue Ordner erstellen** ✅
- [x] `core/` Ordner erstellt
- [x] `components/header/` Ordner erstellt
- [x] `components/grid/` Ordner erstellt
- [x] `components/sheet/` Ordner erstellt
- [x] `components/list/` Ordner erstellt
- [x] `models/` Ordner erstellt

### **Phase 2: Dateien verschieben** ✅
- [x] Hauptkomponenten nach `core/`
- [x] Header-Komponenten nach `components/header/`
- [x] Grid-Komponenten nach `components/grid/`
- [x] Sheet-Komponenten nach `components/sheet/`
- [x] List-Komponenten nach `components/list/`
- [x] Date-Selector nach `components/date_selector/`
- [x] Builders konsolidiert
- [x] Leere Ordner entfernt

### **Phase 3: Imports aktualisiert** ✅
- [x] Alle Import-Pfade angepasst
- [x] Relative Imports verwendet
- [x] Linter-Fehler behoben

### **Phase 4: Code aufgeräumt** ✅
- [x] Unnötige Dateien entfernt
- [x] Duplikate konsolidiert
- [x] Dokumentation aktualisiert

## ✅ **Vorteile der neuen Struktur:**

### **1. Klare Verantwortlichkeiten:**
- `core/` - Hauptkomponenten und Controller
- `components/` - Wiederverwendbare UI-Komponenten
- `builders/` - UI Builder Pattern
- `hooks/` - Business-Logik
- `utils/` - Hilfsfunktionen
- `models/` - Datenmodelle

### **2. Bessere Gruppierung:**
- Verwandte Komponenten sind zusammen
- Logische Hierarchie
- Einfache Navigation

### **3. Skalierbarkeit:**
- Neue Komponenten finden ihren Platz
- Erweiterte Funktionalität integrierbar
- Modulare Architektur

### **4. Wartbarkeit:**
- Klare Trennung von Concerns
- Einfache Tests möglich
- Bessere Code-Reviews

## 🎉 **Refactoring erfolgreich abgeschlossen!**

Die neue Struktur ist jetzt implementiert und alle Imports sind aktualisiert. Die Codebase ist jetzt besser organisiert, wartbarer und skalierbarer. 