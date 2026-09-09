# UUPSProxy

An EIP-1967 proxy whose implementation lives in a dedicated storage slot,
with owner-only upgrades.

## Properties

- All calls are delegated to the implementation stored in the EIP-1967 slot.
- Upgrading preserves the proxy's storage namespace (state survives).
- The implementation address must contain code, preventing bricking.

## Trust assumptions

- A single owner controls upgrades; production systems usually move this to
  a timelock or multisig.
