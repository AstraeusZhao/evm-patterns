// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Pausable} from "../../src/Pausable/Pausable.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}

contract PausableTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant OWNER = address(0xB055);
