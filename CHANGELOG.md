# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `EnglishAuction.bid` reordered to checks-effects-interactions: bidder
  state is committed before the refund transfer, closing a reentrancy
  vector that could corrupt auction state. Covered by a new malicious
  re-entering bidder test.
- `SignatureReplay.claim` hardened against ECDSA malleability: signatures
  must be 65 bytes, use recovery id 27/28, and keep `s` in the low half of
  the curve (`s <= LOW_S_MAX`); the constructor rejects a zero signer.
  Covered by a malleable-signature test.
