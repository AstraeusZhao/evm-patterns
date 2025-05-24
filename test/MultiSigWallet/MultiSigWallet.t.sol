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
