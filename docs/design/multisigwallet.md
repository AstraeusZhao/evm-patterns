# MultiSigWallet

A multi-signature wallet that requires a threshold of owner confirmations
before a transaction can be executed.

## Functional surface

- `submitTransaction(to, value, data)` — an owner proposes a call and is
  auto-confirmed as the first confirmator.
- `confirmTransaction(txId)` / `revokeConfirmation(txId)` — owners build or
  withdraw confirmations while the transaction is pending.
- `executeTransaction(txId)` — runs the call once the confirmation threshold
  is met; only one execution per transaction is allowed.
- `addOwner` / `removeOwner` / `replaceOwner` / `changeRequired` — owner
  management; removing owners clamps the threshold down so the wallet can
  never become ungovernable.

## Security properties

- **Authorization** — every mutating action is gated by `onlyOwner`.
- **CEI ordering** — `executed` is flagged *before* the external call, so a
  re-entrant attempt sees the transaction already done.
- **Reentrancy lock** — a `nonReentrant` guard backs the execution path as a
  second line of defense.
- **Threshold invariant** — `required` is always clamped to
  `min(required, owners.length)` after removals.

## Trust assumptions

- The threshold and the owner set are only as trustworthy as the owners
  themselves; a compromised majority can drain the wallet.
- There is no daily limit or whitelist on call targets; production wallets
  usually add spend limits and target allowlists.
