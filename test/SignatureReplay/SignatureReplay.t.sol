// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {SignatureReplay} from "../../src/SignatureReplay/SignatureReplay.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
    function addr(uint256 privateKey) external returns (address);
    function sign(uint256 privateKey, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);
}

contract SignatureReplayTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint256 private constant SIGNER_KEY = 0xB0B;
    address private constant CLAIMER = address(0xC1A1);

    function _replay() internal returns (SignatureReplay) {
        address signer = vm.addr(SIGNER_KEY);
        vm.prank(signer);
        return new SignatureReplay(signer);
    }

    function _signature(SignatureReplay r, uint256 amount, uint256 nonce, uint256 deadline)
        internal
