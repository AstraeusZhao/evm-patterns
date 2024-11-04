// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {PullPaymentVault} from "../../src/PullPaymentVault/PullPaymentVault.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
}

contract PullPaymentVaultTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    receive() external payable {}

    function testDepositAndPullWithdraw() external {
        PullPaymentVault vault = new PullPaymentVault();
        vm.deal(address(this), 3 ether);

        vault.deposit{value: 3 ether}();
        require(vault.credits(address(this)) == 3 ether, "credit was not recorded");
        require(address(vault).balance == 3 ether, "vault balance is wrong");

        vault.withdraw(1 ether);
        require(vault.credits(address(this)) == 2 ether, "credit was not reduced");
        require(address(vault).balance == 2 ether, "withdrawal was not paid");
    }

    function testOwnerCanPauseAndUnpause() external {
        PullPaymentVault vault = new PullPaymentVault();

        vault.pause();
        require(vault.paused(), "vault did not pause");

        vault.unpause();
        require(!vault.paused(), "vault did not unpause");
    }

    function testNonOwnerCannotPause() external {
        PullPaymentVault vault = new PullPaymentVault();
        NonOwner caller = new NonOwner();
        bool reverted;

        try caller.pause(vault) {
            reverted = false;
        } catch {
            reverted = true;
        }

        require(reverted, "non-owner was allowed to pause");
    }

    function testPausedVaultRejectsDeposit() external {
        PullPaymentVault vault = new PullPaymentVault();
        vm.deal(address(this), 1 ether);
        vault.pause();
        bool reverted;

        try vault.deposit{value: 1 ether}() {
            reverted = false;
        } catch {
            reverted = true;
        }

        require(reverted, "paused vault accepted a deposit");
    }
