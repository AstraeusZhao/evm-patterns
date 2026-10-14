# PullPayment

Betalen via actieve opname: ontvangen ETH wordt als tegoed geboekt; ontvangers kiezen zelf hun opnamemoment.

## Eigenschappen

- `receive` boekt tegoed voor de afzender zonder uitgaande overdracht af te dwingen.
- Opnamen volgen CEI: het tegoed daalt vóór de externe aanroep.
- Een herintredingsslot beschermt de opname.

## Vertrouwensaannamen

Tegoed ontstaat alleen door ontvangen ETH. Een pad voor ongedekte uitgifte ontbreekt.
