# ERC20Token

Minimale ERC20-Implementierung, bei der nur der Eigentümer prägen darf.

## Eigenschaften

- Überweisungen prüfen den Senderbestand vor einer Zustandsänderung.
- `transferFrom` verbraucht die Freigabe; ausgenommen ist die unbegrenzte Freigabe `type(uint256).max`.
- Die Gesamtmenge steigt nur durch Prägen des Eigentümers und sinkt durch Verbrennen.

## Vertrauensannahmen

Der Eigentümer kontrolliert die Ausgabe. Ein böswilliges oder kompromittiertes Eigentümerkonto kann beliebig viele Token prägen.
