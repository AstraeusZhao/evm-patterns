// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PriceOracle} from "../../src/PriceOracle/PriceOracle.sol";


contract PriceOracleTest is Test {

    address private constant TOKEN = address(0xA11CE);
    address private constant ADMIN = address(0xB055);
    address private constant ATTACKER = address(0xB0B);

    function _oracle() internal returns (PriceOracle) {
        vm.prank(ADMIN);
        return new PriceOracle();
    }

    function testPostAndRead() external {
        PriceOracle o = _oracle();
        vm.prank(ADMIN);
        o.postPrice(TOKEN, 1.5 ether);
        (uint256 price,) = o.getPrice(TOKEN);
        require(price == 1.5 ether, "price not posted");
    }

    function testOnlyAdminCanPost() external {
        PriceOracle o = _oracle();
        vm.expectRevert();
        vm.prank(ATTACKER);
        o.postPrice(TOKEN, 1 ether);
    }

    function testStaleFeedReverts() external {
        PriceOracle o = _oracle();
        vm.prank(ADMIN);
        o.postPrice(TOKEN, 1 ether);
        vm.warp(block.timestamp + 24 hours + 1);
        vm.expectRevert();
        o.getPrice(TOKEN);
    }

    function testZeroPriceRejected() external {
        PriceOracle o = _oracle();
        vm.expectRevert();
        vm.prank(ADMIN);
        o.postPrice(TOKEN, 0);
    }
}

