// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Whitelist, WhitelistSale} from "../../src/Whitelist/Whitelist.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function expectRevert() external;
}

contract WhitelistTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
