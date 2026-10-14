# DutchAuction

Eine Auktion mit fallendem Preis: Während des Gebotsfensters sinkt der Preis linear von `startPrice` auf `endPrice`.

## Eigenschaften

- Das erste Gebot zum aktuellen Preis gewinnt sofort.
- Überzahlungen werden erstattet.
- Nach erfolgreichem Gebot kann der Verkäufer den Erlös abheben.

## Vertrauensannahmen

Der Verkäufer muss den Gegenstand nach Annahme des Gebots liefern.
