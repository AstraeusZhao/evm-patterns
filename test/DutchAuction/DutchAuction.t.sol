// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {DutchAuction} from "../../src/DutchAuction/DutchAuction.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
