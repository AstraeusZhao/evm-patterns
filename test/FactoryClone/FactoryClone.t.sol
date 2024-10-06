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
