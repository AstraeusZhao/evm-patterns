// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/Multicall/Multicall.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Batches multiple self-calls into a single transaction.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title Multicall
/// @notice Batches multiple self-calls into a single transaction.
/// @dev Uses delegatecall so `msg.sender` and storage context are preserved.
///      The batch is nonpayable; delegated calls receive zero msg.value.
///      A failure reverts the entire batch (atomic rollback).
///      A variant could collect per-call results instead. Not audited.
contract Multicall {
    error CallFailed(uint256 index);

    /// @notice Execute several calls to this contract in sequence.
    /// @dev The nonpayable entry point prevents repeated crediting of ETH value.
    /// @param calls Encoded self-calls to execute.
    function multicall(Call[] calldata calls) external returns (bytes[] memory results) {
        results = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool ok, bytes memory ret) = address(this).delegatecall(calls[i].data);
            if (!ok) revert CallFailed(i);
            results[i] = ret;
        }
    }

    struct Call {
        bytes data;
    }
}
