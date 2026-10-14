# TimelockController

Governance-tijdslot dat bevoorrechte aanroepen in een wachtrij zet en minimaal vertraagt, zodat gebruikers vóór een wijziging kunnen reageren.

## Interfaces

- `schedule(...)`: een indiener plant een aanroep, gereed na `minDelay` seconden.
- `execute(...)`: een uitvoerder voert een gereedstaande operatie binnen het geldigheidsvenster uit.
- `cancel(...)`: een indiener annuleert een operatie voordat deze gereed is.
- `grantRole` / `revokeRole` / `updateDelay`: de beheerder beheert rollen en minimale vertraging tot maximaal 30 dagen.

## Toestandsmachine

Een operatie-ID kent vier toestanden:

- `Unset`: nooit gepland of verwijderd na uitvoering of annulering.
- `Waiting`: `timestamp` ligt in de toekomst.
- `Ready`: huidige tijd binnen `[timestamp, timestamp + GRACE_PERIOD]`.
- `Expired`: huidige tijd na `timestamp + GRACE_PERIOD`.

De oorspronkelijke notities beschrijven voorgangers via `Unset`. Voor het bijhouden en controleren van voltooide afhankelijkheden is de huidige broncode bepalend.

## Beveiliging

- Rolscheiding: indieners voeren niet uit, uitvoerders plannen niet.
- Operaties verlopen na een venster van 14 dagen en blijven niet onbeperkt gereed.
- Plannen en uitvoeren controleren de volgorde van afhankelijkheden.

## Vertrouwensaannamen

De beheerder kan rollen verlenen en vertragingen verkorten. In productie hoort deze zelf onder een tijdslot of multisig te vallen. Uitvoerders worden vertrouwd om de bedoelde operaties uit te voeren.
