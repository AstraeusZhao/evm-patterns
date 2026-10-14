// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/VestingWallet/VestingWallet.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Linear token vesting: tokens release gradually to a beneficiary
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title VestingWallet
/// @notice Linear token vesting: tokens release gradually to a beneficiary
///         over a cliff and vesting period.
/// @dev Common pattern for team tokens, advisor grants, and investor allocations.
///      Uses the ERC20 transfer/balanceOf interface loosely (no strict interface).
///      Not audited.
import {IERC20Minimal, SafeTransfer} from "../SafeERC20Wrapper/SafeERC20Wrapper.sol";
contract VestingWallet {
    error ZeroAddress();
    error NothingToRelease();
    error TransferFailed();

    event ERC20Released(address indexed token, uint256 amount);

    address public immutable beneficiary;
    uint64 public immutable start;
    uint64 public immutable duration;

    mapping(address token => uint256 released) public released;

    /// @param beneficiary_ Who receives the vested tokens.
    /// @param start_ Unix timestamp when vesting begins.
    /// @param duration_ Seconds over which tokens linearly release.
    constructor(address beneficiary_, uint64 start_, uint64 duration_) {
        if (beneficiary_ == address(0)) revert ZeroAddress();
        beneficiary = beneficiary_;
        start = start_;
        duration = duration_;
    }

    /// @notice Release all vested tokens of a given ERC20 to the beneficiary.
    function release(address token) external {
        uint256 vested = vestedAmount(token, uint64(block.timestamp));
        uint256 already = released[token];
        uint256 payable_ = vested - already;

        if (payable_ == 0) revert NothingToRelease();

        released[token] = already + payable_;
        emit ERC20Released(token, payable_);

        SafeTransfer.safeTransfer(IERC20Minimal(token), beneficiary, payable_);
    }

    /// @notice How many tokens of `token` have vested up to `timestamp`.
    function vestedAmount(address token, uint64 timestamp) public view returns (uint256) {
        (bool ok, bytes memory balData) = token.staticcall(abi.encodeWithSignature("balanceOf(address)", address(this)));
        if (!ok || token.code.length == 0 || balData.length != 32) revert TransferFailed();
        uint256 balance = abi.decode(balData, (uint256));
        uint256 total = balance + released[token];

        if (timestamp < start) return 0;
        if (timestamp >= start + duration) return total;
        return total * (timestamp - start) / duration;
    }
}
