# EnglishAuction

An ascending-price auction with immediate refunds for outbid bidders.

## Properties

- Bids must strictly exceed the current highest bid.
- Outbid bidders are refunded at the moment they lose the lead (CEI ordering).
- The seller can withdraw the winning bid only after the auction ends.

