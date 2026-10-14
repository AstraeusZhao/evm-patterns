// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/Randomness/Randomness.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Demonstrates why blockhash-based randomness is not secure:
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title Randomness
/// @notice Demonstrates why blockhash-based randomness is not secure:
///         miners can manipulate the block hash to influence the outcome.
/// @dev Educational demo of a common vulnerability. Do not use in production.
///      Use Chainlink VRF or similar oracle-based randomness instead.
contract Randomness {
    event WinnerPicked(address indexed winner, uint256 seed);

    address[] public participants;

    /// @notice Enter the lottery.
    function enter() external {
        participants.push(msg.sender);
    }

    /// @notice Pick a winner using blockhash — INSECURE, for demo only.
    function pickWinner() external returns (address winner) {
        uint256 seed = uint256(blockhash(block.number - 1));
        uint256 index = seed % participants.length;
        winner = participants[index];
        emit WinnerPicked(winner, seed);
    }

    function participantCount() external view returns (uint256) {
        return participants.length;
    }
}
