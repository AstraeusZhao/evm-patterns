# PriceOracle

Eenvoudig prijsorakel met publicatie door een beheerder en bescherming tegen verouderde prijzen.

## Eigenschappen

- Alleen de beheerder mag prijzen publiceren.
- `getPrice` breekt af bij gegevens ouder dan 24 uur.
- Een nulprijs wordt geweigerd.

## Vertrouwensaannamen

De beheerder is een centraal vertrouwenspunt. Productieorakels verdelen vaak de rechten om bij te werken en controleren prijsafwijkingen.
