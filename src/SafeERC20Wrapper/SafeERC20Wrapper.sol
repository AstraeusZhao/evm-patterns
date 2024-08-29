// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title SafeERC20Wrapper
/// @notice A minimal ERC20 interface plus a safe-transfer library that
///         tolerates tokens which return nothing (USDT-style).
/// @dev Uses low-level calls so missing or false return values are handled.
///      Not audited.
interface IERC20Minimal {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

library SafeTransfer {
    error TransferFailed();

    function safeTransfer(IERC20Minimal token, address to, uint256 amount) internal {
        _callAndVerify(token, abi.encodeCall(IERC20Minimal.transfer, (to, amount)));
    }

    function safeTransferFrom(IERC20Minimal token, address from, address to, uint256 amount) internal {
        _callAndVerify(token, abi.encodeCall(IERC20Minimal.transferFrom, (from, to, amount)));
    }

