// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {StorageCollisionProxy, ImplValueSlot0, ImplValueSlot1} from "../../src/StorageCollision/StorageCollision.sol";

interface Vm {
    function prank(address sender) external;
}

contract StorageCollisionTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function _proxy() internal returns (StorageCollisionProxy) {
        vm.prank(address(0xB055));
        return new StorageCollisionProxy();
    }

    function testSlot0CollisionOverwritesImplementation() external {
        StorageCollisionProxy proxy = _proxy();
        ImplValueSlot0 impl = new ImplValueSlot0();
        vm.prank(address(0xB055));
        proxy.setImplementation(address(impl));

