# PullPaymentVault

`PullPaymentVault` is the first executable pattern in this repository. It is a
small credit vault designed to show a safe withdrawal boundary without adding
an external dependency.

## Behavior

- Anyone can deposit ETH and receives an internal credit balance.
- A user can withdraw only their own recorded credit.
- The owner can pause and unpause deposits and withdrawals.
- Ownership can be transferred, but the owner has no administrative withdrawal
