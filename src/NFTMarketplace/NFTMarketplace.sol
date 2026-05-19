// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title NFTMarketplace
/// @notice A minimal NFT marketplace: sellers list ERC721 tokens for a fixed
///         price, buyers pay ETH, and the marketplace takes a fee.
/// @dev Demonstrates listing, delisting, buying, and fee accounting.
///      Not audited.
contract NFTMarketplace {
    error NotSeller(address caller);
    error NotListed();
    error PriceTooLow(uint256 price, uint256 paid);
    error TransferFailed();
    error ZeroAddress();

    struct Listing {
        address seller;
        address nft;
        uint256 tokenId;
        uint256 price;
    }

    event Listed(address indexed nft, uint256 indexed tokenId, address seller, uint256 price);
    event Delisted(address indexed nft, uint256 indexed tokenId);
    event Bought(address indexed nft, uint256 indexed tokenId, address buyer, uint256 price);

    address public immutable feeRecipient;
    uint256 public immutable feeBps; // basis points (100 = 1%)

    mapping(address nft => mapping(uint256 tokenId => Listing)) public listings;

    /// @param feeRecipient_ Who receives marketplace fees.
    /// @param feeBps_ Fee in basis points (e.g. 250 = 2.5%).
    constructor(address feeRecipient_, uint256 feeBps_) {
        if (feeRecipient_ == address(0)) revert ZeroAddress();
        feeRecipient = feeRecipient_;
        feeBps = feeBps_;
    }

    /// @notice List an NFT for sale.
    function list(address nft, uint256 tokenId, uint256 price) external {
        listings[nft][tokenId] = Listing(msg.sender, nft, tokenId, price);
        emit Listed(nft, tokenId, msg.sender, price);
    }

    /// @notice Remove a listing (only seller).
    function delist(address nft, uint256 tokenId) external {
        Listing storage l = listings[nft][tokenId];
        if (l.seller == address(0)) revert NotListed();
        if (msg.sender != l.seller) revert NotSeller(msg.sender);
        delete listings[nft][tokenId];
        emit Delisted(nft, tokenId);
    }

    /// @notice Buy a listed NFT.
    function buy(address nft, uint256 tokenId) external payable {
        Listing storage l = listings[nft][tokenId];
        if (l.seller == address(0)) revert NotListed();
        if (msg.value < l.price) revert PriceTooLow(l.price, msg.value);

        uint256 fee = l.price * feeBps / 10000;
        uint256 sellerAmount = l.price - fee;

        delete listings[nft][tokenId];
        emit Bought(nft, tokenId, msg.sender, l.price);

        (bool ok1,) = payable(l.seller).call{value: sellerAmount}("");
        if (!ok1) revert TransferFailed();

        (bool ok2,) = payable(feeRecipient).call{value: fee}("");
        if (!ok2) revert TransferFailed();
    }
}
