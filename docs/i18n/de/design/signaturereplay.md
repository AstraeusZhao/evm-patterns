# SignatureReplay

Verhindert die Wiederverwendung von EIP-712-Signaturen für Ansprüche durch eine Nonce je Konto.

## Eigenschaften

- Der Hash verwendet Domänentrennung und typisierte Daten.
- `ecrecover` ermittelt den Unterzeichner, der dem konfigurierten Unterzeichner entsprechen muss.
- Jeder erfolgreiche Anspruch erhöht die Kontononce und macht alte Signaturen ungültig.
- Eine Fristprüfung begrenzt die Gültigkeit.

## Vertrauensannahmen

Der Signaturschlüssel muss ausserhalb der Blockchain sicher verwahrt werden. Bei einem Verlust können Angreifer Ansprüche für Konten autorisieren.
