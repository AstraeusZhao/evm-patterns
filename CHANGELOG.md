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
- `MultiSigWallet` can no longer remove the last owner (which would lock
  funds forever); `replaceOwner` adds the replacement before removing the
  old owner so the wallet never passes through a zero-owner state. Covered
  by two new governance tests.
- `TimelockController.execute` rejects a zero-address target before
  scheduling state is deleted.
- `StakingVault` reward accounting fixed: changing `rewardRatePerSecond`
  first settles accrued rewards for every staker at the old rate, so
  historical accrual is never recomputed at a new rate. Covered by a new
  rate-change test. `WhitelistSale` gained an owner `withdrawProceeds`
  path so collected ETH is not locked.
- Emits moved before external calls (CEI ordering) across `PullPayment`,
  `PullPaymentVault`, `EscrowVault`, `MultiSigWallet`, `MerkleAirdrop`, and
  `TimelockController`; `nonReentrant` is the first modifier on guarded
  functions. Removed unused errors and the empty `receive()` on `UUPSProxy`.

### Added

- Adversarial tests for reentrant bidding, malleable signatures, last-owner
  removal, rate-change accounting, and sale proceeds withdrawal: 117 tests
  across 23 suites.
- `foundry.toml` lint profile documents intentional exclusions (auction
  timestamps, governance transfers, multicall batching, anti-pattern demos)
  with per-rule rationale.

### Changed

- `ReentrancyGuard` ships with a malicious re-entry attack demonstration.
- Contracts prefer custom errors, events, and gas-aware data structures over
  silent fallbacks.

## License

Licensed under the GNU Affero General Public License v3.0. See
[LICENSE](LICENSE).
