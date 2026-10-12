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
    event AuctionEnded(address indexed winner, uint256 amount);

    address public immutable seller;
    uint256 public immutable endAt;

    address public highestBidder;
    uint256 public highestBid;
    bool public ended;

    constructor(uint256 biddingTime) {
        seller = msg.sender;
        endAt = block.timestamp + biddingTime;
    }

    /// @notice Place a bid; the previous bidder is refunded immediately.
    /// @dev Checks-effects-interactions: bidder state is committed before the
    ///      refund transfer, so a re-entering fallback cannot observe stale
    ///      state or drain the contract.
    function bid() external payable {
        if (block.timestamp >= endAt) revert AuctionClosed();
        if (msg.value <= highestBid) revert BidTooLow(highestBid, msg.value);

        address previousBidder = highestBidder;
        uint256 refund = highestBid;

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit Bid(msg.sender, msg.value);

        if (previousBidder != address(0)) {
            (bool ok,) = payable(previousBidder).call{value: refund}("");
            if (!ok) revert TransferFailed();
        }
    }

    /// @notice Finalize once the bidding window has closed.
    function end() external {
        if (block.timestamp < endAt) revert AuctionNotEnded();
        if (ended) revert AuctionClosed();
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
    }

    /// @notice Seller collects the winning bid after the auction ends.
    function withdraw() external {
        if (msg.sender != seller) revert NotOwner(msg.sender);
        if (!ended) revert AuctionNotEnded();

        uint256 amount = highestBid;
        highestBid = 0;
        (bool ok,) = payable(seller).call{value: amount}("");
        if (!ok) revert TransferFailed();
    }
}
