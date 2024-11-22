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
        returns (bytes memory sig)
    {
        bytes32 digest = r.getDigest(CLAIMER, amount, nonce, deadline);
        (uint8 v, bytes32 r_, bytes32 s_) = vm.sign(SIGNER_KEY, digest);
        sig = abi.encodePacked(r_, s_, v);
    }

    function testClaimWithValidSignature() external {
        SignatureReplay r = _replay();
        uint256 deadline = block.timestamp + 1 days;
        bytes memory sig = _signature(r, 100, 0, deadline);

        vm.prank(CLAIMER);
        r.claim(100, deadline, sig);
        require(r.nonces(CLAIMER) == 1, "nonce not incremented");
    }

    function testReplayedSignatureRejected() external {
        SignatureReplay r = _replay();
        uint256 deadline = block.timestamp + 1 days;
        bytes memory sig = _signature(r, 100, 0, deadline);

        vm.prank(CLAIMER);
        r.claim(100, deadline, sig);

        // Same signature now hashes a stale nonce; recovery yields a
        // different signer, so the claim must revert.
        vm.expectRevert();
        vm.prank(CLAIMER);
        r.claim(100, deadline, sig);
    }

    function testExpiredSignatureRejected() external {
        SignatureReplay r = _replay();
        uint256 deadline = block.timestamp - 1;
        bytes memory sig = _signature(r, 100, 0, deadline);

        vm.expectRevert();
        vm.prank(CLAIMER);
        r.claim(100, deadline, sig);
    }

    function testSignatureFromWrongSignerRejected() external {
        SignatureReplay r = _replay();
        uint256 deadline = block.timestamp + 1 days;
        bytes32 digest = r.getDigest(CLAIMER, 100, 0, deadline);
        (uint8 v, bytes32 r_, bytes32 s_) = vm.sign(0x0AA, digest);
        bytes memory sig = abi.encodePacked(r_, s_, v);

        vm.expectRevert();
        vm.prank(CLAIMER);
        r.claim(100, deadline, sig);
    }

