# ERC721NFT

A minimal ERC721 with owner-only minting, single-token approvals and
operator approvals.

## Properties

- Ownership is tracked per token id; balances are counted per account.
- `transferFrom` requires the caller to be the owner, an approved account or an
  approved operator.
- Approvals are cleared automatically on transfer.

## Trust assumptions

- The minter controls supply; a compromised minter can mint arbitrary tokens.
