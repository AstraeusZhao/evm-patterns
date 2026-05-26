# PullPaymentVault

`PullPaymentVault` is the first executable pattern in this repository. It is a
small credit vault designed to show a safe withdrawal boundary without adding
an external dependency.

## Behavior

- Anyone can deposit ETH and receives an internal credit balance.
- A user can withdraw only their own recorded credit.
- The owner can pause and unpause deposits and withdrawals.
- Ownership can be transferred, but the owner has no administrative withdrawal
  path.

## Security properties

- The credit balance is checked before it is reduced.
- The balance is reduced before the recipient call (Checks-Effects-Interactions).
- A reentrancy lock prevents a recipient contract from entering `withdraw`
  again during the ETH transfer.
- Custom errors make failure paths explicit and avoid string-based errors.
- Pausing is an operational stop switch, not a recovery mechanism. Users must
  wait for the owner to unpause before withdrawing.

## Trust assumptions and limitations

- The owner is trusted to manage the pause switch and ownership transfer.
- ETH transfers can fail if the recipient rejects them; the withdrawal reverts
  and the user's credit remains unchanged.
- There is no upgradeability, fee system, token support, or emergency sweep.
- This example is for learning and review. It has not received an independent
  security audit and must not custody production funds.

## Test coverage

The Foundry tests cover normal deposit and withdrawal, owner-only pausing,
paused deposits, and over-withdrawal protection.
