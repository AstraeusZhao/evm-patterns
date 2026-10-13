# AMM

## Scope

This note covers [`src/AMM/AMM.sol`](../../src/AMM/AMM.sol). The contract is a
virtual-reserve arithmetic demonstration of the constant-product formula. It
does not hold or transfer either asset.

## Behavior

- `addLiquidity` increments two public reserve values.
- `swapAForB` and `swapBForA` calculate output as `amountIn * reserveOut /
  (reserveIn + amountIn)` and update the virtual reserves.
- `priceA` returns the current reserve ratio scaled by `1e18`.

## Assumptions and Limitations

- Reserve values are caller-supplied accounting numbers, not token balances.
  Any caller can increase them without depositing assets.
- Swaps do not collect input tokens or deliver output tokens. Events and return
  values therefore do not represent settled trades.
- There are no LP shares, fees, minimum-output checks, deadlines, or oracle
  protections. `priceA` is a spot ratio and is not safe as a price oracle.
- Zero output is allowed when reserves are imbalanced or small relative to the
  input. Arithmetic overflow still reverts under Solidity's checked arithmetic.

This contract only demonstrates reserve arithmetic. It is not an exchange,
market maker, or production AMM and must not be used to custody assets.

## Test Evidence

At source baseline `c4ebe5c`, the coverage report measured 0% for this source
file. The regression suite's low-level call sends ETH to the non-payable
`addLiquidity` entry point and checks that the call fails before its body runs;
it does not test the reserve or swap formulas. See the
[coverage report](../reports/AUDIT_COVERAGE.md).
