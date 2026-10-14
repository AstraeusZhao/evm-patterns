# Ownable

Toegangsbeheer met één eigenaar als basis voor contracten met bevoorrecht beheer.

## Eigenschappen

- Het implementerende account wordt `owner`.
- Alleen de eigenaar mag `transferOwnership` en `renounceOwnership` aanroepen.
- Afstand doen zet de eigenaar op `address(0)` en verwijdert het beheer permanent.

## Vertrouwensaannamen

De eigenaar wordt vertrouwd met de beheermogelijkheden van afgeleide contracten. Verlies van de sleutel betekent verlies van beheer; herstel ontbreekt.

## Wijzigingsnotitie 2026

De oorspronkelijke notities noemen overdracht in twee stappen en controle door meerdere personen. Voor de werkelijke interface en werking is de huidige broncode bepalend.
