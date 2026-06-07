# PullPayment

A "pull" payment pattern: incoming ETH is recorded as credit and recipients
withdraw on their own schedule.

## Properties

- `receive` credits the sender without forcing any transfer out.
- Withdrawals follow CEI: the credit is reduced before the external call.
- The reentrancy lock protects the withdrawal path.

## Trust assumptions
