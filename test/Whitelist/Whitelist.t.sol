// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Whitelist, WhitelistSale} from "../../src/Whitelist/Whitelist.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function expectRevert() external;
}

contract WhitelistTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

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
