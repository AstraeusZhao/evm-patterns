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

    function testScheduleWaitingThenReady() external {
        TimelockController tl = _timelock();
        Target target = new Target();
        bytes32 salt = keccak256("op1");

        vm.prank(PROPOSER);
        tl.schedule(address(target), 0, _setValueData(), bytes32(0), salt);

        bytes32 id = tl.hashOperation(address(target), 0, _setValueData(), bytes32(0), salt);
        require(tl.getOperationState(id) == TimelockController.OperationState.Waiting, "should be waiting");
        require(tl.isOperationPending(id), "pending expected");

        vm.warp(start + DELAY);
        require(tl.getOperationState(id) == TimelockController.OperationState.Ready, "should be ready");

        vm.prank(EXECUTOR);
        tl.execute(address(target), 0, _setValueData(), bytes32(0), salt);
        require(target.value() == 42, "call not executed");
    }

    function testCannotExecuteBeforeDelay() external {
        TimelockController tl = _timelock();
        Target target = new Target();
        bytes32 salt = keccak256("op2");

        vm.prank(PROPOSER);
        tl.schedule(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);

        vm.expectRevert();
        vm.prank(EXECUTOR);
        tl.execute(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);
    }

    function testOnlyProposerCanSchedule() external {
        TimelockController tl = _timelock();
        Target target = new Target();

        vm.expectRevert();
        vm.prank(EXECUTOR);
        tl.schedule(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), keccak256("op3"));
    }

    function testOnlyExecutorCanExecute() external {
        TimelockController tl = _timelock();
        Target target = new Target();
        bytes32 salt = keccak256("op4");

        vm.prank(PROPOSER);
        tl.schedule(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);

        vm.warp(start + DELAY);
        vm.expectRevert();
        vm.prank(PROPOSER);
        tl.execute(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);
    }

    function testCancelScheduledOperation() external {
        TimelockController tl = _timelock();
        Target target = new Target();
        bytes32 salt = keccak256("op5");
        bytes32 id = tl.hashOperation(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);

        vm.prank(PROPOSER);
        tl.schedule(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);

        vm.prank(PROPOSER);
        tl.cancel(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);
        require(tl.getOperationState(id) == TimelockController.OperationState.Unset, "not unset after cancel");

        vm.warp(start + DELAY);
        vm.expectRevert();
        vm.prank(EXECUTOR);
        tl.execute(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);
    }

    function testPredecessorBlocksSchedulingUntilDone() external {
        TimelockController tl = _timelock();
        Target target = new Target();
        bytes32 saltA = keccak256("opA");
        bytes32 saltB = keccak256("opB");
        bytes32 idA = tl.hashOperation(address(target), 0, abi.encodeCall(Target.setValue, (1)), bytes32(0), saltA);

        vm.prank(PROPOSER);
        tl.schedule(address(target), 0, abi.encodeCall(Target.setValue, (1)), bytes32(0), saltA);

        // opB depends on opA; opA is still waiting -> must revert
        vm.expectRevert();
        vm.prank(PROPOSER);
        tl.schedule(address(target), 0, abi.encodeCall(Target.setValue, (2)), idA, saltB);

        // finish opA, then opB can be scheduled
        vm.warp(start + DELAY);
        vm.prank(EXECUTOR);
        tl.execute(address(target), 0, abi.encodeCall(Target.setValue, (1)), bytes32(0), saltA);

        vm.prank(PROPOSER);
        tl.schedule(address(target), 0, abi.encodeCall(Target.setValue, (2)), idA, saltB);
        bytes32 idB = tl.hashOperation(address(target), 0, abi.encodeCall(Target.setValue, (2)), idA, saltB);
        require(tl.isOperationPending(idB), "opB should be pending");
    }

    function testOperationExpiresAfterGrace() external {
        TimelockController tl = _timelock();
        Target target = new Target();
        bytes32 salt = keccak256("op6");

        vm.prank(PROPOSER);
        tl.schedule(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);

        vm.warp(start + DELAY + tl.GRACE_PERIOD() + 1);
        vm.expectRevert();
        vm.prank(EXECUTOR);
        tl.execute(address(target), 0, abi.encodeCall(Target.setValue, (42)), bytes32(0), salt);
    }

    function testUpdateDelay() external {
        TimelockController tl = _timelock();

        vm.prank(ADMIN);
        tl.updateDelay(1 days);
        require(tl.minDelay() == 1 days, "delay not updated");

        vm.expectRevert();
        vm.prank(PROPOSER);
        tl.updateDelay(2 days);
    }

    function testAdminCanGrantAndRevokeRole() external {
        TimelockController tl = _timelock();
        address stranger = address(0x57A);
        bytes32 proposerRole = tl.PROPOSER_ROLE();

        vm.prank(ADMIN);
        tl.grantRole(proposerRole, stranger);
        require(tl.roles(proposerRole, stranger), "role not granted");

        vm.prank(ADMIN);
        tl.revokeRole(proposerRole, stranger);
        require(!tl.roles(proposerRole, stranger), "role not revoked");
    }
}
