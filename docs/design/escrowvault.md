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

