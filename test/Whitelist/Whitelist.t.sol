// SPDX-License-Identifier: AGPL-3.0
/*
 * File: test/Whitelist/Whitelist.t.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Foundry tests for Whitelist.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {Whitelist, WhitelistSale} from "../../src/Whitelist/Whitelist.sol";


contract WhitelistTest is Test {

    address private constant OWNER = address(0xB055);
    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);

    function _whitelist() internal returns (Whitelist) {
        vm.deal(ALICE, 5 ether);
        vm.deal(BOB, 5 ether);
        vm.prank(OWNER);
        return new Whitelist();
    }

    function testAddAndRemove() external {
        Whitelist w = _whitelist();
        vm.prank(OWNER);
        w.addToWhitelist(ALICE);
        require(w.whitelisted(ALICE), "not listed");

        vm.prank(OWNER);
        w.removeFromWhitelist(ALICE);
        require(!w.whitelisted(ALICE), "still listed");
    }

    function testOnlyOwnerManages() external {
        Whitelist w = _whitelist();
        vm.expectRevert();
        vm.prank(ALICE);
        w.addToWhitelist(ALICE);
    }

    function testCannotAddTwice() external {
        Whitelist w = _whitelist();
        vm.prank(OWNER);
        w.addToWhitelist(ALICE);
        vm.expectRevert();
        vm.prank(OWNER);
        w.addToWhitelist(ALICE);
    }

    function testSaleAcceptsOnlyWhitelisted() external {
        Whitelist w = _whitelist();
        vm.prank(OWNER);
        w.addToWhitelist(ALICE);

        vm.prank(OWNER);
        WhitelistSale sale = new WhitelistSale(w);

        vm.expectRevert();
        vm.prank(BOB);
        sale.buy{value: 1 ether}();

        vm.prank(ALICE);
        sale.buy{value: 1 ether}();
        require(sale.purchased(ALICE), "purchase not recorded");
    }

    function testSaleRejectsRepeatPurchase() external {
        Whitelist w = _whitelist();
        vm.prank(OWNER);
        w.addToWhitelist(ALICE);
        vm.prank(OWNER);
        WhitelistSale sale = new WhitelistSale(w);

        vm.prank(ALICE);
        sale.buy{value: 1 ether}();

        vm.expectRevert();
        vm.prank(ALICE);
        sale.buy{value: 1 ether}();
    }

    function testOwnerWithdrawsProceeds() external {
        Whitelist w = _whitelist();
        vm.prank(OWNER);
        w.addToWhitelist(ALICE);
        vm.prank(OWNER);
        WhitelistSale sale = new WhitelistSale(w);

        vm.prank(ALICE);
        sale.buy{value: 1 ether}();

        uint256 before = OWNER.balance;
        vm.prank(OWNER);
        sale.withdrawProceeds();
        require(OWNER.balance - before == 1 ether, "proceeds not withdrawn");
        require(address(sale).balance == 0, "funds stuck after withdrawal");
    }
}


