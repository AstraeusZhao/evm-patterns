// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title PriceOracle
/// @notice Admin-posted price feeds with staleness protection.
/// @dev Consumers must check the returned timestamp; stale feeds revert.
///      Not audited.
contract PriceOracle {
    error NotAdmin(address caller);
    error ZeroPrice();
    error StalePrice(address token, uint256 updatedAt);

    event PricePosted(address indexed token, uint256 price, uint256 timestamp);

    struct Feed {
        uint256 price;
        uint256 updatedAt;
    }

    mapping(address token => Feed feed) public feeds;

    address public admin;
    uint256 public constant MAX_STALENESS = 24 hours;

    constructor() {
        admin = msg.sender;
    }

    /// @notice Post or update a price for a token.
    function postPrice(address token, uint256 price) external {
        if (msg.sender != admin) revert NotAdmin(msg.sender);
        if (price == 0) revert ZeroPrice();
        feeds[token] = Feed(price, block.timestamp);
        emit PricePosted(token, price, block.timestamp);
    }

    /// @notice Read a fresh price; reverts if the feed is stale.
    function getPrice(address token) external view returns (uint256 price, uint256 updatedAt) {
        Feed memory f = feeds[token];
        if (block.timestamp - f.updatedAt > MAX_STALENESS) revert StalePrice(token, f.updatedAt);
        return (f.price, f.updatedAt);
    }
}
