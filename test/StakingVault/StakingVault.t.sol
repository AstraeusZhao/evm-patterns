// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {StakingVault} from "../../src/StakingVault/StakingVault.sol";


contract StakingVaultTest is Test {

    address private constant ALICE = address(0xA11CE);

    receive() external payable {}

    function _vault() internal returns (StakingVault) {
        StakingVault v = new StakingVault();
        v.setRewardRate(1e16); // 1 wei per token per second
        vm.deal(ALICE, 10 ether);
        vm.deal(address(this), 1000 ether);v.fundRewards{value: 1000 ether}(); // fund the rewards pool
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
        require(accrued == 1 ether, "reward not accrued");
    }

    function testClaimRewards() external {
        StakingVault v = _vault();
        vm.warp(block.timestamp + 100);
        uint256 before = ALICE.balance;
        vm.prank(ALICE);
        v.claimRewards();
        require(ALICE.balance - before == 1 ether, "reward not paid");
        require(v.stakedOf(ALICE) == 1 ether, "principal must stay");
    }

    function testUnstakeReducesPrincipal() external {
        StakingVault v = _vault();
        vm.warp(block.timestamp + 50);
        vm.prank(ALICE);
        v.unstake(0.5 ether);
        require(v.stakedOf(ALICE) == 0.5 ether, "principal not reduced");
    }

    function testCannotUnstakeMoreThanStake() external {
        StakingVault v = _vault();
        vm.expectRevert();
        vm.prank(ALICE);
        v.unstake(2 ether);
    }

    function testRateChangeSettlesHistoricalRewards() external {
        StakingVault v = _vault();

        // Settle 100s at the old rate (1 wei per token per second) by
        // changing the rate; the accrued amount must not be recomputed
        // at the new rate afterwards.
        vm.warp(block.timestamp + 100);
        v.setRewardRate(2e16);

        vm.warp(block.timestamp + 100);
        uint256 before = ALICE.balance;
        vm.prank(ALICE);
        v.claimRewards();
        require(ALICE.balance - before == 3 ether, "historical reward mis-accrued");
    }
}
