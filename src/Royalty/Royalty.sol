// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/Royalty/Royalty.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: EIP-2981 royalty info: NFT marketplaces can query the creator
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

/// @title Royalty
/// @notice EIP-2981 royalty info: NFT marketplaces can query the creator
///         royalty for a given token and sale price.
/// @dev Demonstrates the standard royalty interface used across OpenSea,
///      Blur, etc. Not audited.
contract Royalty {
    error InvalidBps(uint256 bps);

    address public immutable creator;
    uint256 public royaltyBps; // basis points (e.g. 500 = 5%)

    event RoyaltyUpdated(uint256 bps);

    /// @param creator_ Who receives royalties.
    /// @param royaltyBps_ Royalty in basis points (max 1000 = 10%).
    constructor(address creator_, uint256 royaltyBps_) {
        if (royaltyBps_ > 1000) revert InvalidBps(royaltyBps_);
        creator = creator_;
        royaltyBps = royaltyBps_;
    }

    /// @notice EIP-2981 royalty info for a given token and sale price.
    function royaltyInfo(uint256 /* tokenId */, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = creator;
        royaltyAmount = (salePrice * royaltyBps) / 10000;
    }

    /// @notice Update the royalty percentage (creator only).
    function setRoyaltyBps(uint256 bps) external {
        require(msg.sender == creator, "not creator");
        if (bps > 1000) revert InvalidBps(bps);
        royaltyBps = bps;
        emit RoyaltyUpdated(bps);
    }

    /// @notice ERC165 interface support.
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x01ffc9a7 || interfaceId == 0x2a55205c; // EIP-2981
    }
}
