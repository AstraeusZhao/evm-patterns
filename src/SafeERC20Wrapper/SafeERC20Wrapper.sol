// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title SafeERC20Wrapper
/// @notice A minimal ERC20 interface plus a safe-transfer library that
///         tolerates tokens which return nothing (USDT-style).
/// @dev Uses low-level calls so missing or false return values are handled.
