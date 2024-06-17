// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {PullPayment} from "../../src/PullPayment/PullPayment.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
