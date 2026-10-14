# UUPSProxy

Proxy met een implementatieadres in een apart EIP-1967-opslagslot en upgrades uitsluitend door de eigenaar.

## Eigenschappen

- Aanroepen worden gedelegeerd naar de implementatie in het EIP-1967-slot.
- Upgrades behouden de proxyopslag en daarmee de status.
- Het implementatieadres moet code bevatten om de proxy bruikbaar te houden.

## Vertrouwensaannamen

Eén eigenaar beheert upgrades. Productiesystemen gebruiken hiervoor vaak een tijdslot of multisig.
