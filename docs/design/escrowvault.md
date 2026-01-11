# EscrowVault

A three-party ETH escrow: a depositor funds the vault, an agent releases funds
to the beneficiary or refunds the depositor, and either counterparty can
freeze the funds by raising a dispute.

## Roles

- **Depositor** — funds the escrow; may raise a dispute.
- **Beneficiary** — receives funds on release; may raise a dispute.
- **Agent** — trusted third party that releases, refunds, and resolves
  disputes.

## State machine

```
Active ──release()──▶ Released
Active ──refund()───▶ Refunded
Active ──raiseDispute()──▶ Disputed ──resolveDispute(bool)──▶ Released | Refunded
```

Every state-changing call is guarded by `inState`, so the vault can only move
along the transitions above.

## Security properties

- **Role separation** — only the named participant can take each action.
- **CEI ordering** — the state is moved before the ETH transfer.
- **Reentrancy lock** — payout paths are `nonReentrant`.
- **No forced-funding trap** — `receive()` reverts; the balance is only what
  the depositor explicitly deposited, so `release`/`refund` move the exact
  escrowed amount.

## Trust assumptions
