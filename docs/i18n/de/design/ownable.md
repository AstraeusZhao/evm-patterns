# Ownable

Zugriffskontrolle mit einem Eigentümer als Grundlage für Verträge mit privilegierter Verwaltung.

## Eigenschaften

- Das bereitstellende Konto wird `owner`.
- Nur der Eigentümer darf `transferOwnership` und `renounceOwnership` aufrufen.
- Der Verzicht setzt den Eigentümer auf `address(0)` und entfernt die Verwaltung dauerhaft.

## Vertrauensannahmen

Dem Eigentümer werden die Verwaltungsrechte nachgelagerter Verträge anvertraut. Ein verlorener Schlüssel bedeutet verlorene Verwaltungsrechte; es gibt keinen Wiederherstellungsweg.

## Änderungshinweis 2026

Die ursprünglichen Notizen erwähnen eine zweistufige Übertragung und eine Prüfung durch mehrere Personen. Für Schnittstelle und Verhalten ist der aktuelle Quellcode massgeblich.
