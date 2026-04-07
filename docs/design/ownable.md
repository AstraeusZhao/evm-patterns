# Ownable

Single-owner access control used as the base pattern for contracts that need a
privileged administrative account.

## Properties

- The deploying account becomes `owner`.
- `transferOwnership` and `renounceOwnership` are owner-only.
- Renouncing sends ownership to `address(0)`, permanently removing admin paths.

