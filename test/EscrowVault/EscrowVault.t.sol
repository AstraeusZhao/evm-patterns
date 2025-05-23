// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {EscrowVault} from "../../src/EscrowVault/EscrowVault.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function expectRevert() external;
}

contract EscrowVaultTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant BUYER = address(0xBABE);
    address private constant SELLER = address(0xCAFE);
    address private constant AGENT = address(0xACE);
