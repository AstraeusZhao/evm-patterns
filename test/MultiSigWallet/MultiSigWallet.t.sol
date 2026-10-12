// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {MultiSigWallet} from "../../src/MultiSigWallet/MultiSigWallet.sol";


contract MultiSigWalletTest is Test {

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

    function _govern(MultiSigWallet w, bytes memory data) internal {
        address first = w.getOwner(0);uint256 req=w.required();
        vm.prank(first);uint256 id=w.submitTransaction(address(w),0,data);
        for(uint256 i=1;i<req;i++){address signer=w.getOwner(i);vm.prank(signer);w.confirmTransaction(id);}
        vm.prank(first);w.executeTransaction(id);
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
        require(ALICE.balance == 11 ether, "payment was not executed");
    }

    function testCannotExecuteBelowThreshold() external {
        MultiSigWallet w = _defaultWallet();
        vm.prank(ALICE);
        uint256 txId = w.submitTransaction(ALICE, 1 ether, "");

        vm.expectRevert();
        vm.prank(ALICE);
        w.executeTransaction(txId);
    }

    function testNonOwnerCannotSubmit() external {
        MultiSigWallet w = _defaultWallet();
        vm.expectRevert();
        w.submitTransaction(ALICE, 1 ether, "");
    }

    function testRevokeDropsConfirmationAndBlocksExecution() external {
        MultiSigWallet w = _defaultWallet();
        vm.prank(ALICE);
        uint256 txId = w.submitTransaction(ALICE, 1 ether, "");

        vm.prank(BOB);
        w.confirmTransaction(txId);

        vm.prank(BOB);
        w.revokeConfirmation(txId);
        require(w.getConfirmationCount(txId) == 1, "revoke did not drop count");

        vm.expectRevert();
        vm.prank(ALICE);
        w.executeTransaction(txId);
    }

    function testCannotConfirmTwice() external {
        MultiSigWallet w = _defaultWallet();
        vm.prank(ALICE);
        uint256 txId = w.submitTransaction(ALICE, 1 ether, "");

        vm.expectRevert();
        vm.prank(ALICE);
        w.confirmTransaction(txId);
    }

    function testCannotExecuteTwice() external {
        MultiSigWallet w = _defaultWallet();
        vm.deal(address(w), 5 ether);
        vm.prank(ALICE);
        uint256 txId = w.submitTransaction(ALICE, 1 ether, "");
        vm.prank(BOB);
        w.confirmTransaction(txId);
        vm.prank(CAROL);
        w.executeTransaction(txId);

        vm.expectRevert();
        vm.prank(CAROL);
        w.executeTransaction(txId);
    }

    function testAddReplaceRemoveOwner() external {
        MultiSigWallet w = _defaultWallet();
        address dave = address(0xD4E);

        _govern(w, abi.encodeCall(MultiSigWallet.addOwner, (dave)));
        require(w.isOwner(dave), "new owner not recorded");

        _govern(w, abi.encodeCall(MultiSigWallet.replaceOwner, (CAROL, address(0xE0C0))));
        require(!w.isOwner(CAROL), "old owner still active");
        require(w.isOwner(address(0xE0C0)), "replacement missing");

        _govern(w, abi.encodeCall(MultiSigWallet.removeOwner, (BOB)));
        require(!w.isOwner(BOB), "removed owner still active");
        require(w.required() == 2, "threshold changed while owners remain");

        _govern(w, abi.encodeCall(MultiSigWallet.removeOwner, (dave)));
        _govern(w, abi.encodeCall(MultiSigWallet.removeOwner, (address(0xE0C0))));
        require(w.required() == 1, "threshold was not clamped after removal");
    }

    function testChangeRequired() external {
        MultiSigWallet w = _defaultWallet();
        _govern(w, abi.encodeCall(MultiSigWallet.changeRequired, (3)));
        require(w.required() == 3, "required not updated");
    }

    function testExecutePaysContractRecipient() external {
        MultiSigWallet w = _defaultWallet();
        Recipient r = new Recipient();
        vm.deal(address(w), 5 ether);

        vm.prank(ALICE);
        uint256 txId = w.submitTransaction(address(r), 2 ether, "");
        vm.prank(BOB);
        w.confirmTransaction(txId);
        vm.prank(CAROL);
        w.executeTransaction(txId);

        require(address(r).balance == 2 ether, "recipient was not paid");
    }

    function testOwnerCannotBeZeroAddress() external {
        address[] memory owners = new address[](1);
        owners[0] = ALICE;
        MultiSigWallet w = _wallet(owners, 1);

        vm.expectRevert();
        vm.prank(ALICE);w.addOwner(address(0));
    }

    function testCannotRemoveLastOwner() external {
        address[] memory owners = new address[](1);
        owners[0] = ALICE;
        MultiSigWallet w = _wallet(owners, 1);

        vm.expectRevert();
        vm.prank(ALICE);w.removeOwner(ALICE);
        require(w.isOwner(ALICE), "last owner was removed");
    }

    function testReplaceLastOwnerKeepsWalletUsable() external {
        address[] memory owners = new address[](1);
        owners[0] = ALICE;
        MultiSigWallet w = _wallet(owners, 1);
        address dave = address(0xD4E);

        _govern(w, abi.encodeCall(MultiSigWallet.replaceOwner, (ALICE, dave)));
        require(!w.isOwner(ALICE), "old owner still active");
        require(w.isOwner(dave), "replacement missing");
        require(w.required() == 1, "threshold changed during replace");

        // The replacement owner can still run the wallet end to end.
        vm.deal(address(w), 1 ether);
        vm.prank(dave);
        uint256 txId = w.submitTransaction(dave, 1 ether, "");
        vm.prank(dave);
        w.executeTransaction(txId);
        require(dave.balance == 1 ether, "wallet unusable after replace");
    }
}

contract Recipient {
    receive() external payable {}
}
