# MerkleAirdrop

A token airdrop where claims are verified with Merkle proofs instead of
per-account signatures.

## Properties

- Leaves bind `(account, amount)`; claimants supply a sibling-hash proof.
- `claimed` mapping prevents double claims.
- The owner can sweep leftover tokens after distribution.

## Trust assumptions

- The merkle root is set once at deployment; a leaked root lets anyone claim
  the full allocation.
