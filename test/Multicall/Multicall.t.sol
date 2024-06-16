// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Multicall} from "../../src/Multicall/Multicall.sol";

interface Vm {
    function expectRevert() external;
