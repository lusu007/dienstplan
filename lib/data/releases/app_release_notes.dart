import 'package:dienstplan/domain/models/release_notes.dart';

// German release copy. Keep entries immutable after publication; add new releases.
// Maintenance stays in history; only features and important fixes trigger a summary.
const appReleaseNotes = <AppReleaseNotes>[
  AppReleaseNotes(
    version: "0.20.0",
    changes: [
      ReleaseChange(
        id: "history",
        title: "Alle Änderungen im Blick",
        description: "Bei übersprungenen Updates siehst du die wichtigsten Neuerungen zusammen. Die vollständige Versionshistorie findest du unter „Was ist neu?“.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "month-flicker",
        title: "Ruhige Monatsanzeige",
        description: "Die Monatsanzeige flackert beim Schließen der Tagesübersicht nicht mehr.",
        importance: ReleaseImportance.fix,
      ),
      ReleaseChange(
        id: "ios15",
        title: "iOS 15 erforderlich",
        description:
            "Auf iPhone und iPad setzt die App jetzt mindestens iOS 15 voraus.",
        importance: ReleaseImportance.maintenance,
      ),
      ReleaseChange(
        id: "libraries",
        title: "Aktualisierte App-Komponenten",
        description: "Die technische Grundlage und die verwendeten Bibliotheken wurden aktualisiert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.19.2",
    changes: [
      ReleaseChange(
        id: "settings-migration",
        title: "Einstellungen bleiben erhalten",
        description: "Beim Update älterer Datenbanken bleiben deine Einstellungen erhalten.",
        importance: ReleaseImportance.fix,
      ),
      ReleaseChange(
        id: "startup-config",
        title: "Zuverlässiger Start",
        description: "Die Initialisierung des Dienstplans und die Feiertagsauswahl wurden abgesichert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.19.1",
    changes: [
      ReleaseChange(
        id: "whats-new-close",
        title: "Update-Hinweise schließen flüssiger",
        description:
            "Die Darstellung beim Schließen des Dialogs wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
      ReleaseChange(
        id: "ios-photo",
        title: "iOS-Kompatibilität",
        description: "Erforderliche Hinweise für verknüpfte Fotofunktionen wurden ergänzt.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.19.0",
    changes: [
      ReleaseChange(
        id: "paging",
        title: "Flüssiger Tageswechsel",
        description:
            "Tageswechsel und Übergänge in den Einstellungen werden animiert.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "android-insets",
        title: "Mehr Platz am unteren Rand",
        description: "Inhalte berücksichtigen die Android-Systemnavigation.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.18.1",
    changes: [
      ReleaseChange(
        id: "sheet-motion",
        title: "Flüssigere Auswahlfenster",
        description:
            "Öffnen und Schließen der Auswahlfenster wurden verbessert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.18.0",
    changes: [
      ReleaseChange(
        id: "own-duties",
        title: "Eigene Dienste über Mitternacht",
        description: "Eigene Dienste haben ein Start- und Enddatum. Ungespeicherte Änderungen sind vor versehentlichem Verwerfen geschützt.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "settings-order",
        title: "Einstellungen leichter finden",
        description: "Dienstplan, Partner, Darstellung und Feiertage sind übersichtlicher geordnet.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "calendar-retry",
        title: "Laden erneut versuchen",
        description:
            "Klarere Ladeanzeigen und erneutes Laden nach Fehlern im Kalender.",
        importance: ReleaseImportance.fix,
      ),
      ReleaseChange(
        id: "feedback-draft",
        title: "Nachrichten bleiben erhalten",
        description: "Bei Kontaktfehlern bleibt deine Nachricht erhalten. Die Screenshot-Auswahl lässt sich abbrechen.",
        importance: ReleaseImportance.fix,
      ),
      ReleaseChange(
        id: "glass-light",
        title: "Klarere Darstellung",
        description: "Glass-Flächen und die Bedienbarkeit im hellen Design wurden verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.17.4",
    changes: [
      ReleaseChange(
        id: "visible-chips",
        title: "Dienste vollständig sichtbar",
        description: "Die Dienstmarkierungen bleiben im Kalender vollständig im sichtbaren Bereich.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.17.3",
    changes: [
      ReleaseChange(
        id: "ios-signing",
        title: "iOS-Wartung",
        description:
            "Die Erstellung signierter iOS-Versionen wurde korrigiert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.17.2",
    changes: [
      ReleaseChange(
        id: "release-build",
        title: "Wartungsupdate",
        description:
            "Die Erstellung der Installationsdateien wurde korrigiert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.17.1",
    changes: [
      ReleaseChange(
        id: "glass-contrast",
        title: "Besser lesbare Auswahlfenster",
        description: "Kontrast und Darstellung der Glass-Auswahlfenster wurden verbessert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.17.0",
    changes: [
      ReleaseChange(
        id: "future-entries",
        title: "Eigene Dienste in zukünftigen Jahren",
        description: "Gespeicherte eigene Dienste werden auch in späteren Jahren zuverlässig angezeigt.",
        importance: ReleaseImportance.fix,
      ),
      ReleaseChange(
        id: "calendar-cache",
        title: "Kalender zuverlässiger laden",
        description: "Zwischenspeicherung und Darstellung des Kalenders wurden verbessert.",
        importance: ReleaseImportance.fix,
      ),
      ReleaseChange(
        id: "glass-performance",
        title: "Flüssigere Auswahlfenster",
        description: "Die Darstellung von Auswahlfenstern und Filtermarkierungen wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.16.0",
    changes: [
      ReleaseChange(
        id: "custom-entries",
        title: "Eigene Termine anlegen",
        description: "Ergänze eigene Termine direkt aus der Tagesübersicht.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "compact-view",
        title: "Kompakte Kalenderansicht",
        description: "Wähle eine kompakte Ansicht und blende Dienstgruppen gezielt ein oder aus. Die Ansicht bleibt nach Neustarts erhalten.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "contact",
        title: "Kontakt direkt in der App",
        description: "Sende Feedback über die App und lies die Datenschutzhinweise direkt in den Einstellungen.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "glass-design",
        title: "Neue Darstellung",
        description:
            "Kalender, Einstellungen und Auswahlfenster wurden neu gestaltet.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "date-picker",
        title: "Datumsauswahl verbessert",
        description: "Monats- und Jahresauswahl bleiben synchron, und die Tagesauswahl bleibt beim Wischen erhalten.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.15.2",
    changes: [
      ReleaseChange(
        id: "startup",
        title: "Zuverlässiger App-Start",
        description: "Dienstplan und Einstellungen werden beim Start zuverlässig geladen.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.15.1",
    changes: [
      ReleaseChange(
        id: "open-export",
        title: "Exportierte Dateien öffnen",
        description: "Die Anbindung zum Öffnen gespeicherter Dateien wurde aktualisiert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.15.0",
    changes: [
      ReleaseChange(
        id: "export",
        title: "Dienstplan exportieren",
        description: "Exportiere deinen Dienstplan als Datei.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "schedule-load",
        title: "Dienstpläne schneller laden",
        description: "Generierung, Laden und der sichtbare Kalenderbereich beim Start wurden verbessert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.14.0",
    changes: [
      ReleaseChange(
        id: "esd",
        title: "Weitere ESD-Varianten",
        description: "Die ESD-Konfiguration unterstützt ZD-Wochen mit zwei und drei Diensten.",
        importance: ReleaseImportance.feature,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.13.0",
    changes: [
      ReleaseChange(
        id: "settings-sheets",
        title: "Einfachere Einstellungen",
        description:
            "Auswahlfenster erleichtern die Bedienung der Einstellungen.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "holiday-save",
        title: "Feiertagsauswahl speichern",
        description:
            "Die Auswahl des Bundeslands wird zuverlässig gespeichert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.8",
    changes: [
      ReleaseChange(
        id: "lehe",
        title: "Dienstplan Lehe/Geestemünde aktualisiert",
        description:
            "Feiertage werden in der Tagesliste kompakter dargestellt.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.7",
    changes: [
      ReleaseChange(
        id: "schedule-refresh",
        title: "Aktuelle Dienstplandaten",
        description: "Dienstpläne werden nach Versionsänderungen neu geladen. Die Diagnoseansicht wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.6",
    changes: [
      ReleaseChange(
        id: "cache-refresh",
        title: "Aktuelle Dienstplandaten",
        description: "Veraltete zwischengespeicherte Dienstpläne werden nach Änderungen erneuert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.5",
    changes: [
      ReleaseChange(
        id: "leherheide",
        title: "Dienstplan Leherheide korrigiert",
        description: "Der Wochenversatz wurde korrigiert. Einrichtung und Auswahlfenster wurden besser angepasst.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.4",
    changes: [
      ReleaseChange(
        id: "month-switch",
        title: "Monatswechsel verbessert",
        description: "Schnelle Monatswechsel und die Darstellung der Dienstliste wurden verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.3",
    changes: [
      ReleaseChange(
        id: "performance",
        title: "Weniger Wartezeiten",
        description: "Aufwendige Berechnungen und die verwendeten Bibliotheken wurden optimiert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.2",
    changes: [
      ReleaseChange(
        id: "holiday-color",
        title: "Feiertagsfarben korrigiert",
        description:
            "Farbauswahl, Ladezeiten und Monatswechsel wurden verbessert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.1",
    changes: [
      ReleaseChange(
        id: "setup-group",
        title: "Dienstgruppe zuverlässig auswählen",
        description: "Die Auswahl der Dienstgruppe bei der Einrichtung wurde korrigiert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.12.0",
    changes: [
      ReleaseChange(
        id: "holidays",
        title: "Ferien und Feiertage im Kalender",
        description: "Schulferien und Feiertage erscheinen im Kalender und in der Tagesübersicht.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "schedule-filter",
        title: "Dienstpläne schneller finden",
        description: "Filter erleichtern die Auswahl. Weitere OPB-Dienstpläne für Bremerhaven sind verfügbar.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "layout",
        title: "Übersichtlichere Darstellung",
        description: "Einstellungen, Farbauswahl und Abstände im Kalender wurden verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.11.0",
    changes: [
      ReleaseChange(
        id: "two-shift",
        title: "Weiterer Dienstplan",
        description: "Ein Zwei-Schicht-Fünf-Tage-Plan ist verfügbar.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "calendar-format",
        title: "Kalenderansicht verbessert",
        description: "Beschriftung und Berechnung der Kalenderansicht wurden verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.10.5",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.10.4",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.10.3",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.10.2",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.10.1",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.10.0",
    changes: [
      ReleaseChange(
        id: "calendar-layout",
        title: "Lesbarerer Kalender",
        description: "Das Kalenderlayout und die Übernahme von Dienstplandateien wurden verbessert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.9.3",
    changes: [
      ReleaseChange(
        id: "footer",
        title: "App-Informationen wieder sichtbar",
        description: "Die Fußzeile in den Einstellungen ist zurück. Alte Dienstplandateien werden beim Update bereinigt.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.9.2",
    changes: [
      ReleaseChange(
        id: "schedule-refresh",
        title: "Aktuelle Dienstpläne nach Updates",
        description: "Veraltete Dienstpläne werden erneuert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.9.1",
    changes: [
      ReleaseChange(
        id: "schedule-pattern",
        title: "Dienstmuster korrigiert",
        description:
            "Verkehrszug und Ostzug nutzen das korrigierte Dienstmuster.",
        importance: ReleaseImportance.fix,
      ),
      ReleaseChange(
        id: "android-insets",
        title: "Android-Darstellung verbessert",
        description: "Inhalte werden nicht mehr von der Systemnavigation verdeckt. Das Teilen wurde korrigiert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.9.0",
    changes: [
      ReleaseChange(
        id: "authorities",
        title: "Nach Polizeibehörde auswählen",
        description: "Dienstpläne sind nach Polizeibehörden gegliedert.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "store-links",
        title: "App-Links korrigiert",
        description: "Die Verweise auf die App-Stores wurden korrigiert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.8.1",
    changes: [
      ReleaseChange(
        id: "migration",
        title: "Update älterer Versionen korrigiert",
        description:
            "Der Wechsel von Version 0.7.2 auf 0.8 funktioniert wieder.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.8.0",
    changes: [
      ReleaseChange(
        id: "partner",
        title: "Partner-Dienstgruppe anzeigen",
        description: "Sieh neben deinem Dienstplan auch die Dienstgruppe deines Partners.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "dark-mode",
        title: "Dunkles Design und eigene Farben",
        description: "Nutze den dunklen Modus und eine Akzentfarbe für deinen Dienstplan.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "share",
        title: "App teilen",
        description: "Teile die App direkt aus den Einstellungen.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "startup",
        title: "Einrichtung und Laden verbessert",
        description: "Einrichtung, Dienstplanberechnung und die Anzeige früherer Tage wurden überarbeitet.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.7.2",
    changes: [
      ReleaseChange(
        id: "selected-day",
        title: "Ausgewählten Tag behalten",
        description: "Beim Wechsel der Kalenderansicht bleibt dein ausgewählter Tag erhalten.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.7.1",
    changes: [
      ReleaseChange(
        id: "portrait",
        title: "Darstellung im Hochformat",
        description: "Die App bleibt im Hochformat.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.7.0",
    changes: [
      ReleaseChange(
        id: "settings",
        title: "Verständlichere Einstellungen",
        description:
            "Einstellungen und Dienstbezeichnungen wurden überarbeitet.",
        importance: ReleaseImportance.feature,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.6.0",
    changes: [
      ReleaseChange(
        id: "legacy-data",
        title: "Ältere Daten übernehmen",
        description: "Vorhandene Daten älterer Versionen werden übernommen.",
        importance: ReleaseImportance.fix,
      ),
      ReleaseChange(
        id: "calendar-nav",
        title: "Kalendernavigation korrigiert",
        description: "Jahresanzeige, Heute-Schaltfläche, Tagesüberschrift und weit entfernte Termine wurden verbessert.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.5.1",
    changes: [
      ReleaseChange(
        id: "ipad",
        title: "iPad-Darstellung korrigiert",
        description: "Die Ausrichtung auf dem iPad wurde korrigiert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.5.0",
    changes: [
      ReleaseChange(
        id: "month-year",
        title: "Monat und Jahr direkt auswählen",
        description: "Wechsle mit der Monats- und Jahresauswahl schneller zu einem Datum.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "loading",
        title: "Klarere Ladeanzeigen",
        description: "Kalender und Einstellungen zeigen ihren Ladestatus. Einrichtung und Dialoge wurden überarbeitet.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "diagnostics",
        title: "Fehlerberichte steuern",
        description: "Du kannst die Übermittlung von Fehlerberichten in den Einstellungen ausschalten.",
        importance: ReleaseImportance.feature,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.41",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.40",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.39",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.38",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.37",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.36",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.35",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.34",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.33",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.32",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.31",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.30",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.29",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.28",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.27",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.26",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.25",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.24",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.23",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.22",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.21",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.20",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.19",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.18",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.17",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.16",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.15",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.14",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.13",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.12",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.11",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.10",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.9",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.8",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.7",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.6",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.5",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.4",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.3",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.2",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.1",
    changes: [
      ReleaseChange(
        id: "maintenance",
        title: "Wartungsupdate",
        description:
            "Die Erstellung und Veröffentlichung der App wurde verbessert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.4.0",
    changes: [
      ReleaseChange(
        id: "ios",
        title: "iOS-Version vorbereitet",
        description: "Die Veröffentlichung für iOS wurde eingerichtet.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.3.1",
    changes: [
      ReleaseChange(
        id: "build",
        title: "Wartungsupdate",
        description:
            "Die Erstellung der Installationsdateien wurde korrigiert.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.3.0",
    changes: [
      ReleaseChange(
        id: "day-swipe",
        title: "Zwischen Tagen wischen",
        description: "Wechsle durch horizontales Wischen zwischen Tagen.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "setup-resume",
        title: "Einrichtung fortsetzen",
        description:
            "Die Einrichtung lässt sich nach einem App-Neustart fortsetzen.",
        importance: ReleaseImportance.feature,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.2.0",
    changes: [
      ReleaseChange(
        id: "own-group",
        title: "Eigene Dienstgruppe im Kalender",
        description: "Wähle deine Dienstgruppe und sieh ihre Dienste direkt im Kalender.",
        importance: ReleaseImportance.feature,
      ),
      ReleaseChange(
        id: "setup",
        title: "Einrichtung und Einstellungen verbessert",
        description: "Auswahl, Speicherung und Laden des Dienstplans wurden überarbeitet.",
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.1.0",
    changes: [
      ReleaseChange(
        id: "loading",
        title: "Fortschritt bei der Generierung",
        description:
            "Eine Ladeanzeige begleitet die Berechnung der Dienstpläne.",
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: "0.0.2",
    changes: [
      ReleaseChange(
        id: "initial",
        title: "Dienstplan im Kalender",
        description: "Erste Version mit Dienstplänen, Tagesübersicht, Einrichtung und Einstellungen.",
        importance: ReleaseImportance.feature,
      ),
    ],
  ),
];
