// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {Multicall} from "../../src/Multicall/Multicall.sol";


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

contract MulticallTest is Test {

    function testBatchIncrements() external {
        Counter c = new Counter();

        Multicall.Call[] memory calls = new Multicall.Call[](3);
        calls[0].data = abi.encodeCall(Counter.increment, (1));
        calls[1].data = abi.encodeCall(Counter.increment, (2));
        calls[2].data = abi.encodeCall(Counter.set, (10));

        c.multicall(calls);
        require(c.count() == 10, "batch not applied in order");
    }

    function testBatchFailureRevertsAll() external {
        Counter c = new Counter();
        c.increment(5);

        Multicall.Call[] memory calls = new Multicall.Call[](2);
        calls[0].data = abi.encodeCall(Counter.increment, (1));
        calls[1].data = abi.encodeCall(Counter.fail, ());

        vm.expectRevert();
        c.multicall(calls);
        require(c.count() == 5, "state must roll back on failure");
    }
}
