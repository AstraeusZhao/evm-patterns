// SPDX-License-Identifier: AGPL-3.0
/*
 * File: test/Ownable/Ownable.t.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Foundry tests for Ownable.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {Ownable} from "../../src/Ownable/Ownable.sol";


contract OwnableTest is Test {

    address private constant OWNER = address(0xB055);
    address private constant OTHER = address(0x07E);

    function _ownable() internal returns (Ownable o) {
        vm.prank(OWNER);
        o = new Ownable();
    }

    function testDeployerIsOwner() external {
        vm.prank(OWNER);
        Ownable o = new Ownable();
        require(o.owner() == OWNER, "deployer not owner");
    }

    function testTransferOwnership() external {
        Ownable o = _ownable();
        vm.prank(OWNER);
        o.transferOwnership(OTHER);
        require(o.owner() == OTHER, "ownership not transferred");
    }

    function testNonOwnerCannotTransfer() external {
        Ownable o = _ownable();
        vm.expectRevert();
        vm.prank(OTHER);
        o.transferOwnership(OTHER);
    }

    function testCannotTransferToZeroAddress() external {
        Ownable o = _ownable();
        vm.expectRevert();
        vm.prank(OWNER);
        o.transferOwnership(address(0));
    }

    function testRenounceOwnership() external {
        Ownable o = _ownable();
        vm.prank(OWNER);
        o.renounceOwnership();
        require(o.owner() == address(0), "owner not renounced");
        vm.expectRevert();
        vm.prank(OWNER);
        o.transferOwnership(OTHER);
    }
}
