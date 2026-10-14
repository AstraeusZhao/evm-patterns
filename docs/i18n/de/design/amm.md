# AMM

## Umfang

Zu [`src/AMM/AMM.sol`](../../src/AMM/AMM.sol). Der Vertrag demonstriert virtuelle Reserven nach der Formel des konstanten Produkts. Er verwahrt und überträgt keine Vermögenswerte.

## Verhalten

- `addLiquidity` erhöht die beiden öffentlichen Reservewerte.
- `swapAForB` und `swapBForA` berechnen die Ausgabe als `amountIn * reserveOut / (reserveIn + amountIn)` und aktualisieren die virtuellen Reserven.
- `priceA` liefert das Reserveverhältnis mit einer Genauigkeit von `1e18`.

## Annahmen und Grenzen

- Die Reserven sind vom Aufrufer angegebene Buchungswerte, keine Tokenbestände. Jeder kann sie ohne Einzahlung erhöhen.
- Ein Tausch zieht keine Eingabetoken ein und zahlt keine Ausgabetoken aus. Ereignisse und Rückgabewerte belegen daher keine abgewickelten Geschäfte.
- Es fehlen LP-Anteile, Gebühren, Mindestausgabe, Fristen und Orakelschutz. `priceA` ist ein momentanes Verhältnis und kein geeignetes Preisorakel.
- Ungleichgewicht oder kleine Eingaben können eine Ausgabe von null ergeben. Geprüfte Solidity-Arithmetik bricht bei Überlauf ab.

Dies ist eine Rechendemonstration, keine Börse und kein AMM für die Verwahrung echter Mittel.

## Testnachweise

Im Quellstand `c4ebe5c` betrug die gemessene Zeilenabdeckung 0 %. Der Regressionstest sendet ETH an das nicht zahlbare `addLiquidity` und bestätigt nur das Scheitern vor Eintritt in den Funktionskörper. Reserven und Tauschformeln werden damit nicht geprüft. Siehe [Abdeckungsbericht](../reports/AUDIT_COVERAGE.md).
