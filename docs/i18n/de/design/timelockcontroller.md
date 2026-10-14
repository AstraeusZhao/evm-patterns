# TimelockController

Governance-Zeitsperre für privilegierte Aufrufe mit Mindestverzögerung, damit Nutzer vor einer Änderung reagieren können.

## Schnittstellen

- `schedule(...)`: Ein Vorschlagender reiht einen Aufruf ein, der nach `minDelay` Sekunden bereit ist.
- `execute(...)`: Ein Ausführender führt eine bereite Operation innerhalb des Zeitfensters aus.
- `cancel(...)`: Ein Vorschlagender verwirft eine noch nicht bereite Operation.
- `grantRole` / `revokeRole` / `updateDelay`: Der Administrator verwaltet Rollen und Mindestverzögerung bis maximal 30 Tage.

## Zustandsautomat

Eine Operations-ID hat vier Zustände:

- `Unset`: nie geplant oder nach Ausführung beziehungsweise Abbruch gelöscht.
- `Waiting`: `timestamp` liegt in der Zukunft.
- `Ready`: aktuelle Zeit in `[timestamp, timestamp + GRACE_PERIOD]`.
- `Expired`: aktuelle Zeit nach `timestamp + GRACE_PERIOD`.

Die ursprünglichen Notizen beschreiben Vorgänger über `Unset`. Für die Erfassung abgeschlossener Abhängigkeiten und ihre Prüfung ist der aktuelle Quellcode massgeblich.

## Sicherheitseigenschaften

- Rollentrennung: Vorschlagende können nicht ausführen, Ausführende nicht planen.
- Operationen verfallen nach einer Frist von 14 Tagen und bleiben nicht unbegrenzt bereit.
- Planung und Ausführung prüfen die Reihenfolge von Abhängigkeiten.

## Vertrauensannahmen

Der Administrator kann Rollen vergeben und Verzögerungen verkürzen. Produktiv sollte er selbst einer Zeitsperre oder Multisignatur unterliegen. Den Ausführenden wird die Durchführung vorgesehener Operationen anvertraut.
