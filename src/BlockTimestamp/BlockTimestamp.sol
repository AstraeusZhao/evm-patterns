// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title BlockTimestamp
/// @notice Demonstrates block timestamp dependence: miners can manipulate
///         block.timestamp by a few seconds to influence outcomes.
/// @dev For most use cases (auctions, deadlines), block.timestamp is fine.
///      But for high-value randomness or precise timing, it's risky.
///      Not audited.
contract BlockTimestamp {
    event WinnerPicked(address indexed winner);

    mapping(uint256 => address) public winners;

    /// @notice Pick a winner based on timestamp — miners can manipulate this.
    function pickWinner(address[] calldata candidates) external {
        uint256 index = block.timestamp % candidates.length;
        winners[block.number] = candidates[index];
        emit WinnerPicked(candidates[index]);
    }
}
