# MerkleAirdrop

Tokenverdeling met Merkle-bewijzen in plaats van afzonderlijke handtekeningen per account.

## Eigenschappen

- Bladeren binden `(account, amount)`; de ontvanger levert een bewijs met hashes van zusterknopen.
- De mapping `claimed` voorkomt dubbele claims.
- Na verdeling kan de eigenaar resterende tokens opnemen.

## Vertrouwensaannamen

De Merkle-root wordt eenmalig bij implementatie ingesteld. Alleen een geldig bewijs voor die root geeft recht op uitbetaling.
