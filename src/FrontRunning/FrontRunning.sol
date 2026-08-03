// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title FrontRunning
/// @notice Demonstrates front-running vulnerability: if a transaction is
///         submitted in the mempool before it's mined, a bot can see it
///         and submit a higher-gas transaction to sandwich the trade.
/// @dev Educational demo. For production, use commit-reveal schemes or
///      private mempools. Not audited.
contract FrontRunning {
    error AlreadyCommitted();
    error NoCommit();
    error WrongReveal();

    bytes32 public committedHash;
    address public committedSender;

    event Revealed(address indexed sender, uint256 number);

    /// @notice Commit to a number without revealing it (commit phase).
    function commit(bytes32 hash) external {
        if (committedSender != address(0)) revert AlreadyCommitted();
        committedHash = hash;
        committedSender = msg.sender;
    }

    /// @notice Reveal the number after the commit delay (reveal phase).
    /// @dev In a real system, require a block delay between commit and reveal.
    function reveal(uint256 number, bytes32 salt) external {
        if (committedSender != msg.sender) revert NoCommit();
        if (keccak256(abi.encodePacked(number, salt)) != committedHash) revert WrongReveal();

        emit Revealed(msg.sender, number);

        // Reset for next round
        committedHash = bytes32(0);
        committedSender = address(0);
    }
}
