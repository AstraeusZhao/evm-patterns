// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {FactoryClone} from "../../src/FactoryClone/FactoryClone.sol";

interface Vm {
    function expectRevert() external;
}

contract CloneCounter {
    uint256 public count;

    function increment() external {
        count += 1;
    }
}

contract FactoryCloneTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function testDeployCloneAndInteract() external {
        CloneCounter impl = new CloneCounter();
        FactoryClone factory = new FactoryClone(address(impl));

        bytes32 salt = keccak256("clone-1");
        address predicted = factory.getAddress(salt);
        address clone = factory.deploy(salt);
        require(clone == predicted, "CREATE2 address mismatch");

        CloneCounter c = CloneCounter(payable(clone));
        require(c.count() == 0, "clone initial state wrong");
        c.increment();
        c.increment();
        require(c.count() == 2, "clone state not independent");
        require(impl.count() == 0, "implementation polluted by clone");
    }

    function testCannotDeployTwiceWithSameSalt() external {
        CloneCounter impl = new CloneCounter();
        FactoryClone factory = new FactoryClone(address(impl));

