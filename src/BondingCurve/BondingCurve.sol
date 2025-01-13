// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title BondingCurve
/// @notice Continuous token issuance with a price that rises linearly with
///         supply (`price = supply`), so `reserve = supply^2 / 2`.
/// @dev Demonstrates the standard quadratic bonding curve and an integer
///      square root routine. Not audited.
contract BondingCurve {
    error ZeroAmount();
    error InsufficientSupply(uint256 supply, uint256 requested);
    error InsufficientReserve(uint256 reserve, uint256 required);
    error TransferFailed();

    event Buy(address indexed buyer, uint256 amount, uint256 price);
    event Sell(address indexed seller, uint256 amount, uint256 refund);

    uint256 private _supply;
    uint256 private _reserve;

    /// @notice Buy tokens at the current curve price.
    function buy() external payable returns (uint256 minted) {
        if (msg.value == 0) revert ZeroAmount();

        uint256 newSupply = _sqrt(_supply * _supply + 2 * msg.value);
        minted = newSupply - _supply;

        _supply = newSupply;
        _reserve += msg.value;
        emit Buy(msg.sender, minted, msg.value);
    }

    /// @notice Sell tokens back to the curve for the current reserve share.
    function sell(uint256 amount) external returns (uint256 refund) {
        if (amount == 0) revert ZeroAmount();
        if (amount > _supply) revert InsufficientSupply(_supply, amount);

        uint256 newSupply = _supply - amount;
        refund = (_supply * _supply - newSupply * newSupply) / 2;
        if (refund > _reserve) revert InsufficientReserve(_reserve, refund);

        _supply = newSupply;
        _reserve -= refund;
        emit Sell(msg.sender, amount, refund);

        (bool ok,) = payable(msg.sender).call{value: refund}("");
        if (!ok) revert TransferFailed();
    }

    function supply() external view returns (uint256) {
        return _supply;
    }

    function reserve() external view returns (uint256) {
        return _reserve;
    }

    /// @notice Current marginal price per token.
    function price() external view returns (uint256) {
        return _supply;
    }

    /// @notice Integer square root (Babylonian method).
    function _sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}
