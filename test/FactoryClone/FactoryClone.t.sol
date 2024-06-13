// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {FactoryClone} from "../../src/FactoryClone/FactoryClone.sol";

interface Vm {
    function expectRevert() external;
