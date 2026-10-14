# StorageCollision

Demonstratie van het antipatroon van botsende proxyopslag.

## Eigenschappen

- De proxy bewaart `implementation` in slot 0.
- `ImplValueSlot0` bewaart daar ook `value`. Een gedelegeerde `setValue` overschrijft daardoor het implementatieadres.
- `ImplValueSlot1` gebruikt slot 1 en laat slot 0 intact. Dit toont de oplossing met gereserveerde of EIP-1967-achtige slots.

## Vertrouwensaannamen

Dit contract toont een bekende valkuil en is geen proxy voor productiegebruik.
