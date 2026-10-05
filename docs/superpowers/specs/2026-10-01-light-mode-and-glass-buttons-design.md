# Light Mode verbessern und Glasbuttons vereinheitlichen

Stand: 2026-10-01. Grundlage: gemeinsamer Design-Dialog, Quellcode und Light-Mode-Audit auf dem S22 Ultra über ADB. Dieses Dokument beschreibt den vorgeschlagenen Umfang; es ist keine Umsetzung.

## Ziel und Grenzen

Der Alltagsschwerpunkt bleibt das Prüfen eigener Dienste, Partnerdienste und weiterer Dienstgruppen. Das bestehende Glasdesign wird lesbarer und konsistenter.

- Beide Kalenderansichten bleiben: kompakte Striche mit Tagesdetails und große Monatsansicht mit Dienstkürzeln.
- Die untere Eingabeleiste mit Eingabe und Plus bleibt erhalten.
- Die bereits abgestimmte Anordnung und gleiche Höhe von Monatswahl und Heute bleiben erhalten.
- Partnerdienste werden weiterhin über die Einstellungen konfiguriert.
- **Dark Mode bleibt außerhalb der neuen Buttons unverändert:** keine Änderung seiner Farben, Oberflächen, Auswahlmarkierungen, Layouts oder Kalendernavigation. Verbesserungen an diesen Bereichen greifen ausschließlich im Light Mode.
- Für Buttons dürfen beide Themes die Bibliothekskomponenten erhalten. Im Dark Mode orientieren sich Farben und Glaswirkung am bisherigen Look.
- `liquid_glass_widgets: 1.7.2` bleibt installiert; kein Bibliothekswechsel oder Upgrade für diese Arbeit.
- Standard-Glasqualität, bestehende Sheet-Animationen und die verzögerte Aktivierung teurer Effekte bleiben erhalten.
- Keine Änderung von gespeicherten Diensten, Terminen, Privatsphäre-Einstellungen oder Exportformaten. Kein Zurücksetzen und kein Absenden von Feedback während der Prüfung.

## 1. Lesbarkeit im Light Mode

Dienstkürzel müssen auf der tatsächlich sichtbaren Badge-Farbe lesbar sein. Besonders problematisch sind Türkis, Orange, Grün, Gelb und neutrale Badges außerhalb des Monats. Die Auswahl der Schriftfarbe berücksichtigt Transparenz und den Hintergrund; für kleine Texte ist das Prüfziel mindestens 4,5:1. Das ist ein Abnahmekriterium, keine Behauptung einer vollständigen Accessibility-Zertifizierung.

Monats-/Jahresauswahl, Farbwahl und Theme-Auswahl erhalten lesbare Beschriftungen und einen klaren Auswahlmarker. Auswahl darf nicht allein durch eine geringe Helligkeitsänderung erkennbar sein. Die Dark-Mode-Varianten dieser Komponenten bleiben unverändert.

## 2. Dialoge und Sheets im Light Mode

Formulare und Auswahllisten erhalten einen ausreichend deckenden Inhaltshintergrund, damit Kalenderzahlen und Einstellungen dahinter nicht mit dem Inhalt konkurrieren. Außenkontur und Glascharakter bleiben erhalten. Die Korrektur liegt in der gemeinsamen Dialogoberfläche, nicht in separaten Blur-Rezepten pro Seite.

Die Theme-Auswahl erhält dieselbe Light-Mode-Lesbarkeit. Ihre bisherige Dark-Mode-Oberfläche bleibt bestehen, auch wenn das Theme bei geöffnetem Sheet gewechselt wird. Kein Austausch der laufenden Route beim Theme-Wechsel.

## 3. Gemeinsame Bibliotheksbuttons

Bestehende App-Adapter werden erweitert; keine direkten, unterschiedlich konfigurierten Bibliotheksbuttons in jeder Seite.

| Rolle | Bibliotheksbasis | Verwendung |
| --- | --- | --- |
| Primär | `GlassButton.custom`, `prominent` | Speichern, Weiter, Absenden |
| Sekundär | `GlassButton.custom`, `filled` | Alternative Aktionen, Anhang hinzufügen |
| Zurückhaltend | `GlassButton.custom`, `transparent` | Abbrechen, Entfernen eines Anhangs, Zurück |
| Destruktiv | gemeinsame Buttonbasis mit semantischer Fehlerfarbe | Löschen und Zurücksetzen |
| Icon | `GlassIconButton` | Heute, Einstellungen, Plus, Pfeile und Filter-Icons |

Die App ergänzt zentral Theme-Farben, stabile Kontur, Größen, Tooltips und Zustände. Deaktivierte und ladende Buttons können keine Aktion auslösen; ein Ladeindikator bleibt gut sichtbar und erhält keine doppelte Abdunklung. Sichtbare Iconflächen dürfen kompakt bleiben, ihre erreichbare Touchfläche beträgt mindestens 48 × 48 logische Pixel. Monat und Heute behalten dieselbe adaptive sichtbare Höhe.

Die Zurücksetzen-Bestätigung erhält einen sichtbaren Abbrechen-Button. Der Ablauf des Zurücksetzens bleibt unverändert.

## 4. Kleine UX-Korrekturen nur im Light Mode

- Aktive Einstellungszeilen, die bisher wie reine Informationen aussehen, erhalten einen passenden Öffnungsindikator. Bestehende Farbvorschauen, Theme-Icons und Schalter werden nicht verdrängt.
- Bei aktivierten Ferien ohne gewähltes Bundesland erklärt „Zuerst Bundesland auswählen“ die deaktivierten Aktionen.
- Ein ganztägiger Termin zeigt keine scheinbare Uhrzeit wie 16:00–17:00. Der Light Mode blendet nur die nicht nutzbare Zeitanzeige aus; Zeitwerte und Umschaltverhalten bleiben erhalten.
- Debug-Informationen erhalten Abstand zwischen Bezeichnung und Wert sowie ein Layout, das auf schmalen Displays und bei größerer Schrift lesbar bleibt.

## 5. Separat zu besprechen, nicht Teil dieser Umsetzung

Zwei Audit-Funde betreffen gemeinsame Inhalte bzw. Verhalten und damit auch den Dark Mode. Sie werden wegen der letzten Vorgabe zurückgestellt, statt Theme-abhängige Datenlogik oder doppelte Rechtstexte einzuführen:

1. **Monatswechsel:** Aktuell kann oben November stehen, während die Tagesdetails noch den 1. Oktober zeigen. Vorschlag: bei echter Monatsnavigation den bisherigen Tag in den neuen Monat übernehmen, am Monatsende begrenzen (31. Januar → 28./29. Februar); Heute bleibt ein eigener Sprung. Alternative: den ausgewählten Tag ausdrücklich als unabhängigen Kontext anzeigen. Kein stilles Ändern von `setFocusedDay`, das auch interne Aufrufer nutzen.
2. **Bezeichnungen:** Die Hinweise in „Was ist neu?“ und im Datenschutz nennen „Kontakt“, der Menüpunkt heißt „Feedback“. Später ausschließlich diese Menüreferenzen angleichen, ohne rechtliche Aussagen zu ändern.

## Abnahme

Alle Seiten werden im Light Mode auf dem echten Gerät geprüft, einschließlich Setup, About/Rechtstexte, Lizenzen, Feedback, Debug und aller relevanten Sheets. Beide Kalenderansichten, Schriftfaktoren 1,0 und 1,3, Tastatur und lange Auswahltexte gehören dazu. Im Dark Mode erfolgt ein Vorher-/Nachhervergleich: Änderungen sind ausschließlich innerhalb der neuen Buttons zulässig. Widgettests sichern Zustand und Interaktion; native Shader-/Glaswirkung wird am Gerät beurteilt.
