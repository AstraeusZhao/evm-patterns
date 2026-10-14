# ERC721NFT

Minimale ERC721-Implementierung mit Prägung durch den Eigentümer sowie Freigaben für einzelne Token und Operatoren.

## Eigenschaften

- Eigentum wird je Token-ID und der Bestand je Konto gespeichert.
- `transferFrom` verlangt den Eigentümer, ein freigegebenes Konto oder einen zugelassenen Operator als Aufrufer.
- Eine Übertragung löscht die Freigabe für den einzelnen Token.

## Vertrauensannahmen

Der Präger kontrolliert die Menge. Ein kompromittiertes Prägerkonto kann beliebig prägen.
