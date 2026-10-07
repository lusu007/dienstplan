# UI-/UX-Audit: Zielbild und Entscheidungen

Stand: 7. Oktober 2026. Auftrag: alle bestätigten Auditbefunde planen; noch keine Implementierung.

## Umfang und Reihenfolge

| Auditpunkt | Ziel | Priorität | Planaufgabe |
| --- | --- | --- | --- |
| 1 | Ladefehler, Laden und tatsächlich leere Tage unterscheiden; Wiederholen anbieten | Hoch | 1 |
| 2 | Onboarding und Kalenderkopf bei großer Schrift/Querformat benutzbar | Hoch | 2 |
| 3 | Nachtdienste mit eindeutiger Datums-/Zeitauswahl erfassen | Hoch | 3 |
| 4 | Titel aus der Schnelleingabe über Plus und Tastatur übernehmen | Hoch | 4 |
| 5 | Screenshot-Anhang im Feedback in beiden Themes ohne Überlauf | Mittel | 5 |
| 6 | Ungespeicherte Dienst- und Feedbackentwürfe beim Verlassen schützen | Hoch | 4, 6 |
| 7 | Kompakte Kalenderinformationen und Ansichtswechsel besser erkennbar/zugänglich | Niedrig, ausdrücklich zurückgestellt | 9 |
| 8 | Speichern und Zurücksetzen gegen wiederholte Ausführung absichern | Hoch | 4, 7 |
| Zusatz A | Screenshot-Auswahl abbrechen und zum erhaltenen Entwurf zurückkehren | Mittel | 6 |
| Zusatz B | Erklärung zur Bundesland-Auswahl auch im Dark Mode | Mittel | 8 |
| Zusatz C | Datenschutztext an die tatsächliche Feedbackübermittlung angleichen | Mittel | 8 |

Die ersten acht Planaufgaben bilden das Hauptpaket. Aufgabe 9 ist ein getrenntes, nachrangiges Paket und blockiert dessen Abschluss nicht. Aufgabe 10 verifiziert jeweils das umgesetzte Paket.

## Grenzen

- Flutter >=3.47.0 und Dart >=3.13.0; keine Abhängigkeitsupdates für diese Verbesserungen.
- Bestehende Glass-Komponenten und `docs/style_guide/` verwenden.
- In der Oberfläche konsequent „Dienst“, „Neuer Dienst“ und „Dienst bearbeiten“ verwenden; gespeicherte alte Einträge nicht löschen oder umklassifizieren.
- Helles/dunkles/System-Theme, große Schrift und Android-Zurück unterstützen. Schriftvergrößerung nicht ausschalten, um Überläufe zu verdecken.
- Vorhandene Provider-Lifecycle-Korrektur erhalten; Wiederholungen dürfen keine unbegrenzten Lade-/Invalidierungsschleifen verursachen.
- Bestehende Daten und Nutzereinstellungen erhalten. Kein Reset und kein Versand von Feedback bei der Geräteprüfung ohne ausdrücklichen Auftrag.
- Commits und PR-Titel im Conventional-Commit-Format, ohne Codex-Erwähnung.

## Datenzustände

Frisches Laden zeigt Fortschritt. Ein erfolgreicher, tatsächlich leerer Tag zeigt den Leerzustand. Ein Fehler zeigt eine verständliche Erklärung und eine Wiederholen-Aktion. Noch passende, zuvor geladene Dienste dürfen bei einem Aktualisierungsfehler sichtbar bleiben, mit Fehlerhinweis. Daten des vorherigen Dienstplans dürfen nicht als Dienste des neu ausgewählten Plans erscheinen. Partnerfehler müssen als solche erkennbar sein und dürfen eigene erfolgreich geladene Dienste nicht verbergen.

## Dienstzeiten: UX-Empfehlung nach Recherche

Beginn und Ende zeigen jeweils Datum und Uhrzeit. Der gewählte Kalendertag ist vorbelegt. Bei Eingabe von 22:00–06:00 schlägt das noch automatisch geführte Enddatum den Folgetag vor. Es zeigt das konkrete Datum und „Folgetag“; „morgen“ ist nur zulässig, wenn der Endtag tatsächlich morgen ist. Der Nutzer kann das Enddatum antippen und ändern. Eine manuelle Endtag-Auswahl beendet die automatische Anpassung; ein Datum wird danach nicht heimlich korrigiert. Eine erneute automatische Berechnung erfordert eine ausdrückliche Aktion.

Gleiche Uhrzeiten am selben Tag sind ungültig. Gleiche Uhrzeiten an ausdrücklich verschiedenen Tagen sind eine andere Eingabe und müssen anhand der gewählten Datumsgrenzen bewertet werden. Ganztägige bestehende Dienste behalten ihr bisheriges Verhalten. Die Anzeige in der Tagesliste nennt bei Nachtdiensten den Endtag. Ein Dienst bleibt zunächst dem Starttag zugeordnet; eine neue mehrtägige Belegungsdarstellung im Monatskalender gehört nicht zu diesem Paket.

**Empfehlung nach der Nutzerdiskussion:** Enddatum frei wählbar, auch über mehrere Tage. Das benötigt ein zusätzliches persistiertes Enddatum und eine rückwärtskompatible Migration. Normale Dienste erfordern weiterhin nur die gewohnte Uhrzeiteingabe. Es gibt keine zusätzliche willkürliche Begrenzung der Dauer; Ende muss nach Beginn liegen. Die UX-Abnahme prüft besonders, dass die freie Auswahl den häufigen Ablauf nicht verlangsamt.

Recherche vom 7. Oktober 2026:

- [Apple: Pickers](https://developer.apple.com/design/human-interface-guidelines/pickers): kompakte Picker bei wenig Platz, Auswahl im Kontext des bearbeiteten Felds.
- [NN/g: Date-Input Form Fields](https://www.nngroup.com/articles/date-input/): eindeutige Daten, passende Eingabemethoden, nachvollziehbare Datumsbereiche und Erhalt vorhandener Eingaben.
- [Material: DatePicker](https://github.com/material-components/material-components-android/blob/master/docs/components/DatePicker.md): Auswahl einzelner Daten/Datumsbereiche, Kalender- und Texteingabe.

Die Kombination von sichtbarem Enddatum und automatischem Folgetag ist unsere daraus abgeleitete Empfehlung, keine durch diese Quellen belegte Vergleichsstudie zu Dienstplan-Apps. Auf dem Handy anhand Tagesdienst, Nachtdienst und nachträglicher Datumsänderung prüfen.

## Entwürfe und laufende Aktionen

Plus und Tastaturaktion öffnen denselben Dienstentwurf inklusive eingegebenem Titel. Die Schnelleingabe wird erst nach erfolgreichem Speichern geleert. Unveränderte Formulare schließen direkt; veränderte Formulare fragen „Änderungen verwerfen?“ mit „Weiter bearbeiten“ und „Verwerfen“. Das gilt für Zurück, Schließen, Außenklick und Wegwischen. Ein erster Zurück-Schritt darf zunächst die Tastatur schließen.

Beim Speichern/Zurücksetzen gibt es genau eine laufende Operation. Die Oberfläche zeigt Fortschritt; weitere Ausführung und unbeabsichtigtes Schließen sind gesperrt. Bei Fehlern bleibt der relevante Dialog samt Eingaben offen. Erfolg führt genau einmal zur vorgesehenen Ansicht.

Die Screenshot-Auswahl erklärt den Ablauf, bietet „Aufnehmen“ und „Abbrechen“ und erhält Text und bisherigen Anhang bei Abbruch oder fehlgeschlagener Aufnahme. Der Wechsel zur Aufnahme ist kein Verwerfen des Entwurfs. Ein neuer Screenshot wird erst nach erfolgreicher Aufnahme übernommen.

## Layout und Inhalte

Prüfmatrix: Light/Dark × 320×640/740×360 × Textskalierung 1,0/1,5/2,0. Header, alle fünf Setup-Schritte, Feedback mit Anhang und betroffene Dialoge müssen ohne RenderFlex-Überlauf funktionieren; Beschriftungen und Aktionen bleiben erreichbar. Zusätzlich Tastatur und reale Geräte-Safe-Areas prüfen. Mindest-Touchflächen der wesentlichen Aktionen: 48 logische Pixel.

Bundesland-Hilfe ist unabhängig vom Theme sichtbar, wenn die Auswahl fehlt. Datenschutzbeschreibung benennt tatsächlich übermittelte Feedbackdaten, freiwillige Angaben und Screenshots sowie den tatsächlich verwendeten Empfänger/Dienst. Aussagen aus dem Code ableiten; keine unbelegten Zusicherungen hinzufügen.

## Nachrangiger Kalenderpunkt 7

Kompakte Darstellung soll mindestens Dienstkürzel statt ausschließlich Farbe anbieten. Screenreader erhalten Datum, eigene/Partner-Dienste und persönliche Titel sowie Auswahl-/Heute-Status. Ein sichtbarer, beschrifteter Umschalter ergänzt die vorhandene Geste; gespeicherte Ansichtspräferenz bleibt erhalten. Eigenständige Umsetzung nach dem Hauptpaket.
