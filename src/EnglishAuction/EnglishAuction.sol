// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title EnglishAuction
/// @notice Ascending-price auction with refunds for outbid bidders.
/// @dev CEI ordering: refund the previous bidder before accepting the new bid.
///      Not audited.
contract EnglishAuction {
    error NotOwner(address caller);
    error AuctionClosed();
    error AuctionNotEnded();
    error BidTooLow(uint256 currentBid, uint256 bid);
    error TransferFailed();

    event Bid(address indexed bidder, uint256 amount);
