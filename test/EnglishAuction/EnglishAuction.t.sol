// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {EnglishAuction} from "../../src/EnglishAuction/EnglishAuction.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function warp(uint256 newTimestamp) external;
    function expectRevert() external;
}

contract EnglishAuctionTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant SELLER = address(0xB055);
    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);

    function _auction() internal returns (EnglishAuction) {
        vm.deal(ALICE, 10 ether);
        vm.deal(BOB, 10 ether);
        vm.prank(SELLER);
        return new EnglishAuction(1 days);
    }

    function testBidAndOutbid() external {
        EnglishAuction a = _auction();
        vm.prank(ALICE);
        a.bid{value: 1 ether}();
        require(a.highestBidder() == ALICE, "first bidder not recorded");
