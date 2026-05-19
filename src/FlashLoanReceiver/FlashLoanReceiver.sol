// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title FlashLoanReceiver
/// @notice A minimal flash loan receiver demo: a pool sends tokens, the
///         receiver does some arbitrary action, then pays back + fee.
/// @dev Demonstrates the EIP-3156 flash loan receiver interface pattern.
///      Not audited.
contract FlashLoanReceiver {
    error UntrustedLender(address lender);
    error InsufficientRepay(uint256 balance, uint256 amount);

    event Received(address indexed lender, address indexed token, uint256 amount, uint256 fee);

    address public immutable owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Called by the flash loan lender after sending the tokens.
    function executeOperation(
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata /* data */
    ) external returns (bool) {
        // In a real contract, do something useful here: arbitrage,
        // collateral swap, liquidation, etc.

        emit Received(msg.sender, token, amount, fee);

        // Approve the lender to pull back the loan + fee
        (bool ok,) = token.call(abi.encodeWithSignature(
            "approve(address,uint256)",
            msg.sender,
            amount + fee
        ));
        require(ok, "approve failed");

        return true;
    }

    /// @notice Withdraw accidentally stuck tokens.
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        (bool ok,) = token.call(abi.encodeWithSignature("transfer(address,uint256)", owner, amount));
        require(ok, "transfer failed");
    }
}
