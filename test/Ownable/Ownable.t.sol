// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Ownable} from "../../src/Ownable/Ownable.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}

contract OwnableTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

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
