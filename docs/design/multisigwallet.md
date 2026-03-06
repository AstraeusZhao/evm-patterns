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
