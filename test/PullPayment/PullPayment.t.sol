// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {PullPayment} from "../../src/PullPayment/PullPayment.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function expectRevert() external;
}

contract PullPaymentTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

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
