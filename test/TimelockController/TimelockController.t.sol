// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {TimelockController} from "../../src/TimelockController/TimelockController.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function warp(uint256 newTimestamp) external;
    function expectRevert() external;
}

contract Target {
    uint256 public value;

    function setValue(uint256 v) external {
        value = v;
    }

    receive() external payable {}
}

contract TimelockControllerTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant ADMIN = address(0xA0A);
    address private constant PROPOSER = address(0xA5E);
    address private constant EXECUTOR = address(0xECC);

    uint256 private constant DELAY = 2 days;
    uint256 private start;

    receive() external payable {}

    function _timelock() internal returns (TimelockController) {
        address[] memory proposers = new address[](1);
        proposers[0] = PROPOSER;
        address[] memory executors = new address[](1);
        executors[0] = EXECUTOR;

        start = block.timestamp;
        vm.warp(start);
        return new TimelockController(DELAY, proposers, executors, ADMIN);
    }

    function _setValueData() internal pure returns (bytes memory) {
        return abi.encodeCall(Target.setValue, (42));
    }
