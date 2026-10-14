# ReentrancyGuard

Een statusslot voorkomt herintreding tijdens externe overdrachten.

## Eigenschappen

- `_lock` begint op 1. `nonReentrant` zet dit vóór de beschermde functie-inhoud op 2 en herstelt de waarde daarna.
- Samen met CEI blokkeert dit de klassieke herhaalde opnameaanval uit de tests.

## Vertrouwensaannamen

Alleen functies met deze modifier zijn beschermd. Iedere externe ingang die externe aanroepen uitvoert, moet de bescherming expliciet toepassen.
