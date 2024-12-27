// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title BondingCurve
/// @notice Continuous token issuance with a price that rises linearly with
///         supply (`price = supply`), so `reserve = supply^2 / 2`.
/// @dev Demonstrates the standard quadratic bonding curve and an integer
///      square root routine. Not audited.
