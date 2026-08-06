# StorageCollision

A demonstration of the proxy storage-collision anti-pattern.

## Properties

- The proxy stores `implementation` at slot 0.
- `ImplValueSlot0` also uses slot 0 for `value`, so a delegatecall to
  `setValue` overwrites the proxy's implementation address.
- `ImplValueSlot1` stores at slot 1 and leaves slot 0 untouched, showing the
  fix: reserved/fixed slots or EIP-1967 style slots.

## Trust assumptions
