// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {MultiSigWallet} from "../../src/MultiSigWallet/MultiSigWallet.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function expectRevert() external;
}

contract MultiSigWalletTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);
    address private constant CAROL = address(0xCA801);

    receive() external payable {}

    function _wallet(address[] memory owners, uint256 req) internal returns (MultiSigWallet) {
        vm.deal(ALICE, 10 ether);
        vm.deal(BOB, 10 ether);
        vm.deal(CAROL, 10 ether);
        MultiSigWallet w = new MultiSigWallet(owners, req);
        return w;
    }

    function _defaultWallet() internal returns (MultiSigWallet) {
        address[] memory owners = new address[](3);
        owners[0] = ALICE;
        owners[1] = BOB;
        owners[2] = CAROL;
        return _wallet(owners, 2);
    }

    function testSubmitAutoConfirmsAndExecutesWithThreshold() external {
        MultiSigWallet w = _defaultWallet();
        vm.deal(address(w), 5 ether);
        vm.prank(ALICE);
        uint256 txId = w.submitTransaction(ALICE, 1 ether, "");

        require(w.getConfirmationCount(txId) == 1, "proposer did not auto-confirm");
        require(w.transactionCount() == 1, "transaction count wrong");

        vm.prank(BOB);
        w.confirmTransaction(txId);
        require(w.getConfirmationCount(txId) == 2, "second confirmation missing");

        vm.prank(CAROL);
        w.executeTransaction(txId);
