# ReentrancyGuard

A state-lock guard that blocks re-entrant calls during external transfers.

## Properties

- `_lock` starts at 1; `nonReentrant` flips it to 2 before the guarded body and
  restores it after.
- Combined with CEI ordering, it prevents the classic withdrawal reentrancy
  attack demonstrated in the tests.

