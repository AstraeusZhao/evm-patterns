// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {PullPaymentVault} from "../../src/PullPaymentVault/PullPaymentVault.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
}

contract PullPaymentVaultTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
