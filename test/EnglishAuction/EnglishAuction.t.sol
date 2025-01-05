// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {EnglishAuction} from "../../src/EnglishAuction/EnglishAuction.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function warp(uint256 newTimestamp) external;
    function expectRevert() external;
}

contract EnglishAuctionTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant SELLER = address(0xB055);
