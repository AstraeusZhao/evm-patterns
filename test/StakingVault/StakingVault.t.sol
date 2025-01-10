// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {StakingVault} from "../../src/StakingVault/StakingVault.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function warp(uint256 newTimestamp) external;
    function expectRevert() external;
