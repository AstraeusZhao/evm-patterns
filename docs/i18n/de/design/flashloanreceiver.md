# FlashLoanReceiver

## Umfang

Zu [`src/FlashLoanReceiver/FlashLoanReceiver.sol`](../../src/FlashLoanReceiver/FlashLoanReceiver.sol). Ein Lehrbeispiel für einen Empfänger mit genau einem festgelegten Kreditgeber nach Art von ERC-3156.

## Verhalten

- Der Bereitsteller wird Eigentümer. Der Konstruktor prüft, ob die Kreditgeberadresse Code enthält, und speichert sie.
- Nur der Eigentümer kann `borrow` aufrufen. Vor dem Kreditgeberaufruf werden erwarteter Token, Betrag und maximale Gebühr gespeichert.
- `onFlashLoan` akzeptiert nur den festgelegten Kreditgeber und prüft aktiven Kredit, Initiator, Token, Betrag, Gebührenobergrenze und Rückzahlungsbestand.
- Der Rückruf gibt `amount + fee` frei und liefert den ERC-3156-Rückrufhash. Nach erfolgreicher Rückkehr des Kreditgebers löscht `borrow` den Kreditzustand und setzt die Tokenfreigabe zurück.
- Der Eigentümer kann Token zurückholen, solange kein Kredit aktiv ist.

## Sicherheitseigenschaften

- Beliebige Aufrufer können den Kreditgeber beim Rückruf nicht imitieren.
- Die Rückrufparameter müssen dem von `borrow` gestarteten Kredit entsprechen.
- Vor der Freigabe muss der Bestand für Kapital und Gebühr ausreichen.
- `active` blockiert erneutes `borrow` und die Tokenrückholung während eines Kredits.

## Annahmen und Grenzen

- Dem festgelegten Kreditgeber wird vertraut. Vorhandener Code beweist weder ERC-3156-Konformität noch korrektes Verhalten.
- Es gibt keinen Strategiehook. `data` wird ignoriert; die geliehenen Mittel werden vor der Rückzahlung nicht eingesetzt.
- Kreditgeber und Token müssen Rückzahlung über Freigaben unterstützen. Gebühren bei Transfers, Rebase-Verhalten und böswillige oder andere abweichende Token können die Bestandsannahmen verletzen.
- Der Eigentümer steuert die Kreditaufnahme und kann ungenutzte Token zurückholen. Ein Kreditgeberwechsel oder Governance fehlt.
- Dies ist ein Lehrbeispiel, keine unabhängig geprüfte Integration für produktive Mittel.

## Testnachweise

Es gibt keine eigene Testsuite. Im Quellstand `c4ebe5c` prüft `test/AuditRegression.t.sol` die Ablehnung eines nicht vertrauenswürdigen Rückrufaufrufers; die gemessene Zeilenabdeckung beträgt 17,65 %. Andere Rückrufe und Interaktionen mit dem Kreditgeber sind damit nicht nachgewiesen. Siehe [Abdeckungsbericht](../reports/AUDIT_COVERAGE.md).
