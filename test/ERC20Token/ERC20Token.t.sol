// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {ERC20Token} from "../../src/ERC20Token/ERC20Token.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}

contract ERC20TokenTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);

    function _token() internal returns (ERC20Token) {
        vm.prank(ALICE);
        ERC20Token t = new ERC20Token("Test", "TST");
        vm.prank(ALICE);
        t.mint(ALICE, 1000 ether);
        return t;
    }

    function testMintAndTransfer() external {
        ERC20Token t = _token();
        vm.prank(ALICE);
        t.transfer(BOB, 100 ether);
        require(t.balanceOf(BOB) == 100 ether, "recipient balance wrong");
        require(t.balanceOf(ALICE) == 900 ether, "sender balance wrong");
    }

    function testTransferFromUsesAllowance() external {
        ERC20Token t = _token();
        vm.prank(ALICE);
        t.approve(BOB, 50 ether);
        vm.prank(BOB);
