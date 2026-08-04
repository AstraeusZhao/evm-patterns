# StorageCollision

A demonstration of the proxy storage-collision anti-pattern.

## Properties

- The proxy stores `implementation` at slot 0.
- `ImplValueSlot0` also uses slot 0 for `value`, so a delegatecall to
