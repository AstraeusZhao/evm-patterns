# DutchAuction

A descending-price auction: the ask price falls linearly from `startPrice`
to `endPrice` over the bidding window.

## Properties

- The first bidder accepting the current price wins immediately.
- Excess payment over the accepted price is refunded.
- The seller withdraws after a successful bid.

## Trust assumptions

- The seller is trusted to deliver the item once the bid is accepted.
