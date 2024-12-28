// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title EnglishAuction
/// @notice Ascending-price auction with refunds for outbid bidders.
/// @dev CEI ordering: refund the previous bidder before accepting the new bid.
///      Not audited.
contract EnglishAuction {
