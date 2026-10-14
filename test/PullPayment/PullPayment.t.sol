// SPDX-License-Identifier: AGPL-3.0
/*
 * File: test/PullPayment/PullPayment.t.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Foundry tests for PullPayment.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PullPayment} from "../../src/PullPayment/PullPayment.sol";


contract PullPaymentTest is Test {

    address private constant ALICE = address(0xA11CE);

    receive() external payable {}

    function testReceiveCreditsSender() external {
        PullPayment p = new PullPayment();
        vm.deal(ALICE, 5 ether);
        vm.prank(ALICE);
        (bool ok,) = address(p).call{value: 2 ether}("");
        require(ok, "transfer failed");
        require(p.pendingCredits(ALICE) == 2 ether, "credit not recorded");
    }

    function testWithdrawCredits() external {
        PullPayment p = new PullPayment();
        vm.deal(ALICE, 5 ether);
        vm.prank(ALICE);
        (bool ok,) = address(p).call{value: 2 ether}("");
        require(ok, "transfer failed");

        vm.prank(ALICE);
        p.withdrawCredits(1 ether);
        require(p.pendingCredits(ALICE) == 1 ether, "credit not reduced");
        require(ALICE.balance == 4 ether, "withdrawal not paid");
    }

    function testCannotOverWithdraw() external {
        PullPayment p = new PullPayment();
        vm.deal(ALICE, 5 ether);
        vm.prank(ALICE);
        (bool ok,) = address(p).call{value: 2 ether}("");
        require(ok, "transfer failed");

        vm.expectRevert();
        vm.prank(ALICE);
        p.withdrawCredits(3 ether);
    }

    function testCannotWithdrawZero() external {
        PullPayment p = new PullPayment();
        vm.expectRevert();
        vm.prank(ALICE);
        p.withdrawCredits(0);
    }
}




