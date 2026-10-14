# FactoryClone

Fabriek die minimale EIP-1167-proxyklonen met CREATE2 implementeert.

## Eigenschappen

- De runtimebytecode gebruikt de standaard minimale proxy van 45 bytes.
- Iedere salt geeft een deterministisch kloonadres.
- Alle klonen delen dezelfde onveranderlijke implementatie.

## Vertrouwensaannamen

Klonen delen code maar hebben ieder eigen opslag. De implementatie mag de status van afzonderlijke klonen niet ten onrechte in gedeelde opslag plaatsen.
