// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Pausable} from "../../src/Pausable/Pausable.sol";

interface Vm {
    function prank(address sender) external;
