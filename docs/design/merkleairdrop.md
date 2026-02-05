# MerkleAirdrop

A token airdrop where claims are verified with Merkle proofs instead of
per-account signatures.

## Properties

- Leaves bind `(account, amount)`; claimants supply a sibling-hash proof.
- `claimed` mapping prevents double claims.
