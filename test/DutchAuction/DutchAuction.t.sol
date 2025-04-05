// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {DutchAuction} from "../../src/DutchAuction/DutchAuction.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function warp(uint256 newTimestamp) external;
    function expectRevert() external;
}

contract DutchAuctionTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant SELLER = address(0xB055);
    address private constant BUYER = address(0xA11CE);

    function _auction() internal returns (DutchAuction) {
        vm.deal(BUYER, 50 ether);
        vm.prank(SELLER);
        return new DutchAuction(10 ether, 1 ether, 100);
    }

    function testPriceFallsOverTime() external {
        DutchAuction a = _auction();
        require(a.currentPrice() == 10 ether, "start price wrong");

        vm.warp(block.timestamp + 50);
        require(a.currentPrice() == 5.5 ether, "mid price wrong");

        vm.warp(block.timestamp + 100);
        require(a.currentPrice() == 1 ether, "end price wrong");
    }

    function testBidBelowPriceRejected() external {
        DutchAuction a = _auction();
        vm.expectRevert();
        vm.prank(BUYER);
