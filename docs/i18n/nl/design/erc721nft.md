# ERC721NFT

Minimale ERC721-implementatie met minten door de eigenaar, toestemming per token en toestemming voor operators.

## Eigenschappen

- Eigendom wordt per token-ID bijgehouden, saldi per account.
- `transferFrom` vereist dat de aanroeper eigenaar, toegestaan account of toegestane operator is.
- Overdracht wist automatisch de toestemming voor het afzonderlijke token.

## Vertrouwensaannamen

De minter beheert de voorraad. Een overgenomen minteraccount kan onbeperkt minten.
