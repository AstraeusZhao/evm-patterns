// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title DutchAuction
/// @notice Descending-price auction: the price falls linearly over time.
/// @dev The first bidder who accepts the current price wins; excess payment
///      is refunded. Not audited.
contract DutchAuction {
