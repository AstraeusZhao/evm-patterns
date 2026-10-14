# MultiSigWallet

Wallet mit mehreren Eigentümern, die Transaktionen erst nach Erreichen einer Bestätigungsschwelle ausführt.

## Schnittstellen

- `submitTransaction(to, value, data)`: Ein Eigentümer schlägt einen Aufruf vor; die erste Bestätigung wird automatisch erfasst.
- `confirmTransaction(txId)` / `revokeConfirmation(txId)`: Bestätigungen vor der Ausführung hinzufügen oder widerrufen.
- `executeTransaction(txId)`: Nach Erreichen der Schwelle ausführen; jede Transaktion ist nur einmal ausführbar.
- `addOwner` / `removeOwner` / `replaceOwner` / `changeRequired`: Eigentümer und Schwelle verwalten. Beim Entfernen wird die Schwelle angepasst, damit die Wallet handlungsfähig bleibt.

## Sicherheitseigenschaften

- `onlyOwner` beschränkt Zustandsänderungen.
- CEI: `executed` wird vor dem externen Aufruf gesetzt, sodass ein erneuter Eintritt die Transaktion als ausgeführt erkennt.
- `nonReentrant` bildet eine weitere Schutzschicht für die Ausführung.
- Nach dem Entfernen eines Eigentümers gilt `required <= owners.length`.

## Vertrauensannahmen

Die Eigentümer bestimmen Menge und Schwelle. Eine kompromittierte Mehrheit kann die Mittel entnehmen. Es gibt weder Tageslimit noch Positivliste für Aufrufziele; produktive Wallets ergänzen häufig solche Grenzen.

## Änderungshinweis 2025-11

Die ursprünglichen Notizen erwähnen eine Logikprüfung. Das stellt keine unabhängige Sicherheitszertifizierung dar.
