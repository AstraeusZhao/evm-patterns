// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {ERC20Token} from "../../src/ERC20Token/ERC20Token.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}
