// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IERC20Minimal, SafeTransfer, TokenSweeper} from "../../src/SafeERC20Wrapper/SafeERC20Wrapper.sol";

interface Vm {
    function prank(address sender) external;
}

/// A token that returns empty data on transfer (USDT-style quirk).
contract SilentToken is IERC20Minimal {
