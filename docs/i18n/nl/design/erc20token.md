# ERC20Token

Minimale ERC20-implementatie waarbij alleen de eigenaar mag minten.

## Eigenschappen

- Overboekingen controleren het saldo van de afzender vóór een statuswijziging.
- `transferFrom` verbruikt de toestemming, behalve bij onbeperkte toestemming met `type(uint256).max`.
- De totale voorraad stijgt alleen door minten door de eigenaar en daalt door verbranden.

## Vertrouwensaannamen

De eigenaar beheert de uitgifte. Een kwaadwillend of overgenomen eigenaarsaccount kan onbeperkt tokens minten.
