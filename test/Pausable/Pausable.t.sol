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
    address private constant OTHER = address(0x07E);

    function _pausable() internal returns (Pausable p) {
        vm.prank(OWNER);
        p = new Pausable();
    }

    function testPauseAndUnpause() external {
        Pausable p = _pausable();
        vm.prank(OWNER);
        p.pause();
        require(p.paused(), "not paused");
        vm.prank(OWNER);
        p.unpause();
        require(!p.paused(), "not unpaused");
    }

    function testCannotPauseTwice() external {
        Pausable p = _pausable();
        vm.prank(OWNER);
        p.pause();
        vm.expectRevert();
        vm.prank(OWNER);
        p.pause();
    }

    function testCannotUnpauseWhenActive() external {
        Pausable p = _pausable();
        vm.expectRevert();
        vm.prank(OWNER);
        p.unpause();
    }

    function testNonOwnerCannotPause() external {
        Pausable p = _pausable();
        vm.expectRevert();
        vm.prank(OTHER);
        p.pause();
    }
}
