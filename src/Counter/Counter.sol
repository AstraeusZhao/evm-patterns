// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title Counter
/// @notice A minimal increment/decrement counter — the "hello world" of
///         smart contracts, used to sanity-check tooling and deployment.
/// @dev Deliberately tiny; shows storage, events and basic arithmetic.
///      Not audited.
contract Counter {
    event Incremented(uint256 newValue);
    event Decremented(uint256 newValue);

    uint256 public count;

    /// @notice Increase the counter by one.
    function increment() external {
        count += 1;
        emit Incremented(count);
    }

    /// @notice Decrease the counter by one.
    /// @dev Solidity 0.8+ reverts on underflow automatically.
    function decrement() external {
        count -= 1;
        emit Decremented(count);
    }

    /// @notice Reset the counter to zero.
    function reset() external {
        count = 0;
    }
}
