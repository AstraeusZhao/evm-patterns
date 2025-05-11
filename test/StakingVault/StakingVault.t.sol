// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {StakingVault} from "../../src/StakingVault/StakingVault.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function warp(uint256 newTimestamp) external;
    function expectRevert() external;
}

contract StakingVaultTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant ALICE = address(0xA11CE);

    receive() external payable {}

    function _vault() internal returns (StakingVault) {
        StakingVault v = new StakingVault();
        v.setRewardRate(1); // 1 wei per token per second
        vm.deal(ALICE, 10 ether);
        vm.deal(address(v), 1000 ether); // fund the rewards pool
        vm.prank(ALICE);
        v.stake{value: 1 ether}();
        return v;
    }

    function testStakeRecordsPrincipal() external {
        StakingVault v = _vault();
        require(v.stakedOf(ALICE) == 1 ether, "stake not recorded");
    }

    function testRewardsAccrueOverTime() external {
        StakingVault v = _vault();
        vm.warp(block.timestamp + 100);
        vm.prank(ALICE);
        v.unstake(1 ether); // triggers _update and keeps rewards in storage
        (,, uint256 accrued) = v.stakes(ALICE);
        require(accrued == 100 * 1 ether, "reward not accrued");
    }
