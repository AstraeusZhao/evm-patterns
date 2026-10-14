# Pausable

Pauzeschakelaar onder beheer van de eigenaar om statuswijzigingen tijdens incidenten te stoppen.

## Eigenschappen

- Alleen de eigenaar mag `pause` en `unpause` aanroepen; herhaalde handelingen worden gecontroleerd.
- `whenNotPaused` en `whenPaused` beperken functies in afgeleide contracten.

## Vertrouwensaannamen

Pauzeren stopt handelingen en is geen herstelmechanisme. Andere mechanismen moeten zorgen dat middelen tijdens een pauze weer toegankelijk kunnen worden.

## Wijzigingsnotitie 2026

Alleen de eigenaar kan hervatten; de toegangscontrole is verbeterd.
