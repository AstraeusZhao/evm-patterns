// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {BondingCurve} from "../../src/BondingCurve/BondingCurve.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function expectRevert() external;
}

contract BondingCurveTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);

    receive() external payable {}

    function _curve() internal returns (BondingCurve) {
        vm.deal(ALICE, 10 ether);
        vm.deal(BOB, 10 ether);
        return new BondingCurve();
    }

    function testBuyMintsTokens() external {
        BondingCurve c = _curve();
        vm.prank(ALICE);
        uint256 minted = c.buy{value: 1 ether}();
        require(minted > 0, "nothing minted");
        require(c.supply() == minted, "supply mismatch");
        require(c.reserve() == 1 ether, "reserve mismatch");
    }

    function testPriceRisesWithSupply() external {
        BondingCurve c = _curve();
        vm.prank(ALICE);
        uint256 first = c.buy{value: 1 ether}();
        vm.prank(BOB);
        uint256 second = c.buy{value: 1 ether}();
        require(second < first, "later buys must mint fewer tokens");
        require(c.price() == c.supply(), "price != supply");
    }

    function testSellRefundsBelowPaid() external {
        BondingCurve c = _curve();
        vm.prank(ALICE);
        c.buy{value: 1 ether}();
        uint256 supplyBefore = c.supply();

        uint256 before = ALICE.balance;
