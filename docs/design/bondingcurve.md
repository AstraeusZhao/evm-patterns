# BondingCurve

A continuous token with `price = supply`, so the reserve held by the curve is
`reserve = supply^2 / 2`.

## Properties

- Buying mints tokens at the rising marginal price; early buyers pay less.
- Selling burns tokens and returns their reserve share (always below what was
  paid, since the price rises monotonically).
- The reserve invariant `supply^2 >= 2 * reserve` holds through integer
  rounding of the square root.

## Trust assumptions

- There is no owner; the curve is autonomous once deployed.
