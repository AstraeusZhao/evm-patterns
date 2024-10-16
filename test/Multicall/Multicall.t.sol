// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Multicall} from "../../src/Multicall/Multicall.sol";

interface Vm {
    function expectRevert() external;
}

contract Counter is Multicall {
    uint256 public count;

    function increment(uint256 by) external {
        count += by;
    }

    function set(uint256 v) external {
        count = v;
    }

    function fail() external pure {
        revert("boom");
    }
}

contract MulticallTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function testBatchIncrements() external {
        Counter c = new Counter();

        Multicall.Call[] memory calls = new Multicall.Call[](3);
        calls[0].data = abi.encodeCall(Counter.increment, (1));
