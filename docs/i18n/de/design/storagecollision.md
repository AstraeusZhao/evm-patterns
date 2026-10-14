# StorageCollision

Demonstration des Antimusters kollidierender Speicherplätze bei Proxys.

## Eigenschaften

- Der Proxy speichert `implementation` in Slot 0.
- `ImplValueSlot0` speichert dort ebenfalls `value`. Ein delegierter Aufruf von `setValue` überschreibt die Implementierungsadresse.
- `ImplValueSlot1` verwendet Slot 1 und lässt Slot 0 unverändert. Dies zeigt die Lösung durch reservierte oder EIP-1967-artige Slots.

## Vertrauensannahmen

Der Vertrag demonstriert eine bekannte Falle und ist kein produktionsgeeigneter Proxy.
