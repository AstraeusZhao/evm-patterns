// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title PriceOracle
/// @notice Admin-posted price feeds with staleness protection.
/// @dev Consumers must check the returned timestamp; stale feeds revert.
///      Not audited.
contract PriceOracle {
    error NotAdmin(address caller);
    error ZeroPrice();
    error StalePrice(address token, uint256 updatedAt);

    event PricePosted(address indexed token, uint256 price, uint256 timestamp);

