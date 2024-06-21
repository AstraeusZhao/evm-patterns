// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {UUPSProxy} from "../../src/UUPSProxy/UUPSProxy.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}
