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
