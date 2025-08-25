# EscrowVault

A three-party ETH escrow: a depositor funds the vault, an agent releases funds
to the beneficiary or refunds the depositor, and either counterparty can
freeze the funds by raising a dispute.

## Roles

- **Depositor** 鈥?funds the escrow; may raise a dispute.
- **Beneficiary** 鈥?receives funds on release; may raise a dispute.
- **Agent** 鈥?trusted third party that releases, refunds, and resolves
  disputes.

## State machine

```
Active 鈹€鈹€release()鈹€鈹€鈻?Released
Active 鈹€鈹€refund()鈹€鈹€鈹€鈻?Refunded
Active 鈹€鈹€raiseDispute()鈹€鈹€鈻?Disputed 鈹€鈹€resolveDispute(bool)鈹€鈹€鈻?Released | Refunded
```

Every state-changing call is guarded by `inState`, so the vault can only move
along the transitions above.

## Security properties

- **Role separation** 鈥?only the named participant can take each action.
- **CEI ordering** 鈥?the state is moved before the ETH transfer.
- **Reentrancy lock** 鈥?payout paths are `nonReentrant`.
- **No forced-funding trap** 鈥?`receive()` reverts; the balance is only what
  the depositor explicitly deposited, so `release`/`refund` move the exact
  escrowed amount.

## Trust assumptions

- The agent is fully trusted: they can release or refund at any time while
  `Active`, and decide the outcome of a dispute. Production escrows often
  replace the single agent with a multi-sig or an arbitration market.


