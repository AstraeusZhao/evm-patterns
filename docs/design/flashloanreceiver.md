# FlashLoanReceiver

## Scope

This note covers [`src/FlashLoanReceiver/FlashLoanReceiver.sol`](../../src/FlashLoanReceiver/FlashLoanReceiver.sol),
an educational receiver for a single configured ERC-3156-style lender.

## Behavior

- The deployer becomes the owner, and the constructor records one lender
  address after checking that it has code.
- Only the owner can call `borrow`. The receiver records the expected token,
  amount, and maximum fee before calling that lender.
- `onFlashLoan` accepts callbacks only from the configured lender and checks
  the active loan, initiator, token, amount, fee ceiling, and repayment balance.
- The callback approves `amount + fee` and returns the ERC-3156 borrower
  callback hash. After the lender returns successfully, `borrow` clears the
  active-loan state and resets the token allowance.
- The owner can recover tokens outside an active loan.

## Security Properties

- A random caller cannot invoke the callback as the configured lender.
- Callback parameters must match the loan started by `borrow`.
- The receiver checks it holds enough tokens for principal plus fee before
  granting the lender an allowance.
- `active` prevents a second `borrow` or token rescue while a loan is in flight.

## Trust Assumptions and Limitations

- The configured lender is trusted. The constructor checks only that the
  address contains code; it does not prove ERC-3156 compliance or lender
  behavior.
- The receiver has no strategy hook. Callback `data` is ignored, so borrowed
  funds are not used for an operation before repayment.
- The lender and token must agree on allowance-based repayment. Fee-on-transfer,
  rebasing, malicious, or otherwise non-standard tokens can break the assumed
  balance and repayment behavior.
- The owner controls when loans are requested and can recover idle tokens.
  There is no lender rotation or governance mechanism.
- This is a teaching example, not an audited flash-loan integration. Do not
  use it to handle production funds.

## Test Evidence

There is no dedicated test suite for this contract. At source baseline
`c4ebe5c`, `test/AuditRegression.t.sol` checks that an untrusted caller cannot
invoke the callback; the coverage report measured 17.65% line coverage. The
remaining callback and lender interactions are not established by that test.
See the [coverage report](../reports/AUDIT_COVERAGE.md).
