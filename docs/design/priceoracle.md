# PriceOracle

A simple admin-posted price feed with staleness protection.

## Properties

- Only the admin can post prices.
- `getPrice` reverts when the feed is older than 24 hours.
- Zero prices are rejected.

## Trust assumptions

- The admin is a single point of trust; production oracles distribute the
