// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title AMM
/// @notice Minimal constant-product automated market maker (x * y = k).
/// @dev Demonstrates the Uniswap V2 formula in its simplest form.
///      Not audited.
contract AMM {
    error InsufficientLiquidity();
    error InvalidAmount();
    error TransferFailed();

    uint256 public reserveA;
    uint256 public reserveB;

    event Swap(address indexed user, uint256 amountIn, uint256 amountOut, bool isAToB);
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);

    /// @notice Add liquidity to the pool.
    function addLiquidity(uint256 amountA, uint256 amountB) external payable {
        reserveA += amountA;
        reserveB += amountB;
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /// @notice Swap token A for token B.
    function swapAForB(uint256 amountAIn) external returns (uint256 amountBOut) {
        if (amountAIn == 0) revert InvalidAmount();
        if (reserveA == 0) revert InsufficientLiquidity();

        // Constant product: (reserveA + amountIn) * (reserveB - amountOut) = reserveA * reserveB
        amountBOut = (amountAIn * reserveB) / (reserveA + amountAIn);

        reserveA += amountAIn;
        reserveB -= amountBOut;

        emit Swap(msg.sender, amountAIn, amountBOut, true);
    }

    /// @notice Swap token B for token A.
    function swapBForA(uint256 amountBIn) external returns (uint256 amountAOut) {
        if (amountBIn == 0) revert InvalidAmount();
        if (reserveB == 0) revert InsufficientLiquidity();

        amountAOut = (amountBIn * reserveA) / (reserveB + amountBIn);

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit Swap(msg.sender, amountBIn, amountAOut, false);
    }

    /// @notice Current spot price of A in terms of B.
    function priceA() external view returns (uint256) {
        if (reserveA == 0) return 0;
        return (reserveB * 1e18) / reserveA;
    }
}
