// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {UUPSProxy} from "../../src/UUPSProxy/UUPSProxy.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}

contract CounterV1 {
    uint256 public count;

    function increment() external {
        count += 1;
    }
}

contract CounterV2 {
    uint256 public count;

    function increment() external {
        count += 1;
    }

    function double() external {
        count *= 2;
    }
}

contract UUPSProxyTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant ATTACKER = address(0xB0B);

    function testCallsThroughProxy() external {
        CounterV1 impl = new CounterV1();
        UUPSProxy proxy = new UUPSProxy(address(impl));

        CounterV1(address(proxy)).increment();
        require(CounterV1(address(proxy)).count() == 1, "proxy call failed");
        require(impl.count() == 0, "implementation state polluted");
    }

    function testUpgradePreservesState() external {
        CounterV1 impl = new CounterV1();
