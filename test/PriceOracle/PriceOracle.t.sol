// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {PriceOracle} from "../../src/PriceOracle/PriceOracle.sol";

interface Vm {
    function prank(address sender) external;
    function warp(uint256 newTimestamp) external;
    function expectRevert() external;
}

contract PriceOracleTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

