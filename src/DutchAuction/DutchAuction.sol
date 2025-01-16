// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title DutchAuction
/// @notice Descending-price auction: the price falls linearly over time.
/// @dev The first bidder who accepts the current price wins; excess payment
///      is refunded. Not audited.
contract DutchAuction {
    error NotOwner(address caller);
    error AuctionNotEnded();
    error AuctionEnded();
    error BidBelowPrice(uint256 price, uint256 bid);
    error TransferFailed();

    event Bid(address indexed bidder, uint256 amount);

    address public immutable seller;
    uint256 public immutable startAt;
    uint256 public immutable endAt;
    uint256 public immutable startPrice;
    uint256 public immutable endPrice;

    bool public ended;

    constructor(uint256 startPrice_, uint256 endPrice_, uint256 duration) {
        seller = msg.sender;
        startAt = block.timestamp;
        endAt = block.timestamp + duration;
        startPrice = startPrice_;
        endPrice = endPrice_;
    }

    /// @notice Current ask price, linearly interpolated between start and end.
    function currentPrice() public view returns (uint256) {
        if (block.timestamp >= endAt) return endPrice;
        if (block.timestamp < startAt) return startPrice;
        uint256 elapsed = block.timestamp - startAt;
        uint256 total = endAt - startAt;
