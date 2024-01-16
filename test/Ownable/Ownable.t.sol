// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Ownable} from "../../src/Ownable/Ownable.sol";

interface Vm {
    function prank(address sender) external;
