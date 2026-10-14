# PriceOracle

Einfaches Preisorakel mit Veröffentlichung durch einen Administrator und Schutz vor veralteten Daten.

## Eigenschaften

- Nur der Administrator darf Preise veröffentlichen.
- `getPrice` bricht bei Daten ab, die älter als 24 Stunden sind.
- Ein Preis von null wird abgelehnt.

## Vertrauensannahmen

Der Administrator ist ein zentraler Vertrauenspunkt. Produktive Orakel verteilen häufig die Aktualisierungsrechte und prüfen Preisabweichungen.
