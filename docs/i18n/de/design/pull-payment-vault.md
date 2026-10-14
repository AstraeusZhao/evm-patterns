# PullPaymentVault

`PullPaymentVault` ist eines der frühen ausführbaren Muster im Repository. Ein kleiner Buchungstresor demonstriert Grenzen sicherer Abhebungen ohne externe Abhängigkeiten.

## Verhalten

- Jeder kann ETH einzahlen und erhält internes Guthaben.
- Nutzer können nur ihr eigenes erfasstes Guthaben abheben.
- Der Eigentümer kann Einzahlungen und Abhebungen pausieren und fortsetzen.
- Eigentum ist übertragbar; der Eigentümer hat keinen administrativen Abhebungspfad.

## Sicherheitseigenschaften

- Vor einer Verringerung wird das Guthaben geprüft.
- CEI: Das Guthaben sinkt vor dem Empfängeraufruf.
- Eine Wiedereintrittssperre verhindert erneutes `withdraw` während einer ETH-Übertragung.
- Benutzerdefinierte Fehler kennzeichnen Fehlerpfade statt Zeichenketten.
- Die Pause stoppt Aktionen, stellt aber keine Wiederherstellung dar. Nutzer müssen zum Abheben auf die Freigabe des Eigentümers warten.

## Annahmen und Grenzen

- Dem Eigentümer wird die Verwaltung von Pausen und Eigentumswechseln anvertraut.
- Lehnt der Empfänger ETH ab, scheitert die Übertragung und die Abhebung wird zurückgesetzt; das Guthaben bleibt erhalten.
- Upgrades, Gebühren, Tokenunterstützung und eine Notfallentnahme fehlen.
- Das Beispiel dient Lernen und Prüfung, besitzt kein unabhängiges Sicherheitsaudit und ist nicht zur Verwahrung produktiver Mittel gedacht.

## Testabdeckung

Foundry-Tests behandeln normale Einzahlungen und Abhebungen, Pausen durch den Eigentümer, Einzahlungen während der Pause und den Schutz gegen zu hohe Abhebungen.
