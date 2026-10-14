# Pausable

Vom Eigentümer gesteuerter Pausenschalter für zustandsändernde Aktionen bei Zwischenfällen.

## Eigenschaften

- Nur der Eigentümer darf `pause` und `unpause` aufrufen; wiederholte Aktionen werden geprüft.
- `whenNotPaused` und `whenPaused` beschränken Funktionen nachgelagerter Verträge.

## Vertrauensannahmen

Eine Pause stoppt Aktionen und ist kein Wiederherstellungsverfahren. Andere Mechanismen müssen sicherstellen, dass Mittel während einer Pause wieder zugänglich werden können.

## Änderungshinweis 2026

Nur der Eigentümer kann die Pause aufheben; die Zugriffskontrolle wurde verbessert.
