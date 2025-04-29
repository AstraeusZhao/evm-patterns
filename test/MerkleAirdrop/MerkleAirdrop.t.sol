// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {MerkleAirdrop, IERC20Like} from "../../src/MerkleAirdrop/MerkleAirdrop.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}

contract MockToken is IERC20Like {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract MerkleAirdropTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);
    address private constant OWNER = address(0xB055);

    function _airdrop() internal returns (MerkleAirdrop, MockToken, bytes32[] memory, bytes32[] memory) {
        // Tree with 4 leaves: (ALICE,100), (BOB,50), (CAROL,25), (DAVE,10)
        bytes32 leafA = keccak256(bytes.concat(keccak256(abi.encode(ALICE, uint256(100)))));
        bytes32 leafB = keccak256(bytes.concat(keccak256(abi.encode(BOB, uint256(50)))));
        bytes32 leafC = keccak256(bytes.concat(keccak256(abi.encode(address(0xC001), uint256(25)))));
        bytes32 leafD = keccak256(bytes.concat(keccak256(abi.encode(address(0xD4E), uint256(10)))));

        bytes32 ab =
            leafA < leafB ? keccak256(abi.encodePacked(leafA, leafB)) : keccak256(abi.encodePacked(leafB, leafA));
        bytes32 cd =
            leafC < leafD ? keccak256(abi.encodePacked(leafC, leafD)) : keccak256(abi.encodePacked(leafD, leafC));
        bytes32 root = ab < cd ? keccak256(abi.encodePacked(ab, cd)) : keccak256(abi.encodePacked(cd, ab));

        MockToken t = new MockToken();
        t.mint(address(this), 1000 ether);

        MerkleAirdrop a = new MerkleAirdrop(root, MockToken(address(t)));
        t.transfer(address(a), 185 ether);

        bytes32[] memory proofA = new bytes32[](2);
        proofA[0] = leafB;
        proofA[1] = cd;

        bytes32[] memory proofB = new bytes32[](2);
        proofB[0] = leafA;
        proofB[1] = cd;

        return (a, t, proofA, proofB);
    }

    function testClaimWithValidProof() external {
        (MerkleAirdrop a, MockToken t, bytes32[] memory proofA,) = _airdrop();
        vm.prank(ALICE);
        a.claim(100, proofA);
        require(t.balanceOf(ALICE) == 100, "claim not paid");
        require(a.claimed(ALICE), "claim not recorded");
    }

    function testCannotClaimTwice() external {
        (MerkleAirdrop a,, bytes32[] memory proofA,) = _airdrop();
        vm.prank(ALICE);
        a.claim(100, proofA);
        vm.expectRevert();
        vm.prank(ALICE);
        a.claim(100, proofA);
    }

    function testInvalidProofRejected() external {
        (MerkleAirdrop a,,, bytes32[] memory proofB) = _airdrop();
        // BOB's proof cannot be used by ALICE with amount 100.
