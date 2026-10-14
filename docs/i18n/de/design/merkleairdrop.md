# MerkleAirdrop

Tokenverteilung mit Merkle-Beweisen anstelle einzelner Signaturen je Konto.

## Eigenschaften

- Ein Blatt bindet `(account, amount)`; der Empfänger liefert einen Beweis aus Geschwisterhashes.
- Die Zuordnung `claimed` verhindert mehrfache Ansprüche.
- Nach der Verteilung kann der Eigentümer verbliebene Token abheben.

## Vertrauensannahmen

Die Merkle-Wurzel wird einmal bei der Bereitstellung festgelegt. Nur ein gültiger Beweis zu dieser Wurzel berechtigt zur Auszahlung.
