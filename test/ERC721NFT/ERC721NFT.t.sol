// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {ERC721NFT} from "../../src/ERC721NFT/ERC721NFT.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}

contract ERC721NFTTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);

    function _nft() internal returns (ERC721NFT) {
        vm.prank(ALICE);
        ERC721NFT n = new ERC721NFT("NFT", "NFT");
        vm.prank(ALICE);
        n.mint(ALICE, 1);
        return n;
    }

    function testMintAndOwnerOf() external {
        ERC721NFT n = _nft();
        require(n.ownerOf(1) == ALICE, "owner wrong");
        require(n.balanceOf(ALICE) == 1, "balance wrong");
    }

    function testTransferFrom() external {
        ERC721NFT n = _nft();
        vm.prank(ALICE);
        n.transferFrom(ALICE, BOB, 1);
        require(n.ownerOf(1) == BOB, "not transferred");
        require(n.balanceOf(ALICE) == 0, "sender balance not cleared");
    }

    function testApproveThenTransferByOperator() external {
        ERC721NFT n = _nft();
        vm.prank(ALICE);
        n.approve(BOB, 1);
        require(n.getApproved(1) == BOB, "approval not recorded");
        vm.prank(BOB);
        n.transferFrom(ALICE, BOB, 1);
        require(n.ownerOf(1) == BOB, "operator transfer failed");
        require(n.getApproved(1) == address(0), "approval not cleared");
    }

    function testNonOwnerCannotTransfer() external {
