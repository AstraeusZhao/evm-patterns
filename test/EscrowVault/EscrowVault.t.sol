// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {EscrowVault} from "../../src/EscrowVault/EscrowVault.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function expectRevert() external;
}

contract EscrowVaultTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant BUYER = address(0xBABE);
    address private constant SELLER = address(0xCAFE);
    address private constant AGENT = address(0xACE);

    function _escrow() internal returns (EscrowVault) {
        EscrowVault v = new EscrowVault(BUYER, SELLER, AGENT);
        vm.deal(BUYER, 10 ether);
        vm.deal(SELLER, 10 ether);
        return v;
    }

    function _funded() internal returns (EscrowVault) {
        EscrowVault v = _escrow();
        vm.prank(BUYER);
        v.deposit{value: 3 ether}();
        return v;
    }

    function testDepositRecordsBalance() external {
        EscrowVault v = _escrow();

        vm.prank(BUYER);
        v.deposit{value: 3 ether}();

        require(v.getBalance() == 3 ether, "balance not recorded");
        require(v.state() == EscrowVault.State.Active, "state changed on deposit");
    }

    function testOnlyDepositorCanDeposit() external {
        EscrowVault v = _escrow();

        vm.expectRevert();
        vm.prank(SELLER);
        v.deposit{value: 1 ether}();
    }

    function testReleasePaysBeneficiaryAndCloses() external {
        EscrowVault v = _funded();

        vm.prank(AGENT);
        v.release();

        require(v.state() == EscrowVault.State.Released, "state not released");
        require(SELLER.balance == 13 ether, "beneficiary was not paid");
        require(v.getBalance() == 0, "vault not emptied");
    }

    function testRefundReturnsToDepositor() external {
        EscrowVault v = _funded();

        vm.prank(AGENT);
        v.refund();

        require(v.state() == EscrowVault.State.Refunded, "state not refunded");
        require(BUYER.balance == 10 ether, "depositor was not refunded");
    }

    function testOnlyAgentCanRelease() external {
        EscrowVault v = _funded();

        vm.expectRevert();
        vm.prank(BUYER);
        v.release();
    }

    function testDisputeFreezesFunds() external {
        EscrowVault v = _funded();

        vm.prank(SELLER);
        v.raiseDispute();
        require(v.state() == EscrowVault.State.Disputed, "not disputed");
