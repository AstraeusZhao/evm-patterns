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

        // Call setValue(42) through the proxy: delegatecall writes slot 0,
        // which is the proxy's own `implementation` slot.
        (bool ok,) = address(proxy).call(abi.encodeCall(ImplValueSlot0.setValue, (42)));
        require(ok, "call failed");

        // The implementation address was destroyed by the write.
        require(proxy.implementation() == address(42), "implementation slot corrupted");
    }

    function testNonCollidingSlotPreservesProxyStorage() external {
        StorageCollisionProxy proxy = _proxy();
        ImplValueSlot1 impl = new ImplValueSlot1();
        vm.prank(address(0xB055));
        proxy.setImplementation(address(impl));

        address implBefore = proxy.implementation();

        (bool ok,) = address(proxy).call(abi.encodeCall(ImplValueSlot1.setValue, (7)));
        require(ok, "call failed");

        require(proxy.implementation() == implBefore, "implementation slot changed");
    }
}
