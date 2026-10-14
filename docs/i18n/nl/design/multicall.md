# Multicall

Bundelt meerdere zelfaanroepen in één transactie.

## Eigenschappen

- `delegatecall` behoudt `msg.sender` en de opslagcontext.
- Bij één mislukte aanroep wordt de hele bundel atomair teruggedraaid.

## Vertrouwensaannamen

De aangeroepen code moet worden vertrouwd, omdat `delegatecall` de opslag van het huidige contract gebruikt.
