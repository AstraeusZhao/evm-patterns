# ReentrancyGuard

Eine Zustandssperre verhindert Wiedereintritt während externer Übertragungen.

## Eigenschaften

- `_lock` beginnt bei 1. `nonReentrant` setzt den Wert vor dem geschützten Funktionskörper auf 2 und danach zurück.
- Zusammen mit CEI verhindert dies den in Tests gezeigten klassischen Angriff durch erneute Abhebung.

## Vertrauensannahmen

Nur Funktionen mit diesem Modifikator sind geschützt. Jeder externe Einstieg mit externen Aufrufen muss den Schutz ausdrücklich verwenden.
