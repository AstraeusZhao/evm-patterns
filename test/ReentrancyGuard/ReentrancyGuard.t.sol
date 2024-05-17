// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "../../src/ReentrancyGuard/ReentrancyGuard.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function expectRevert() external;
}

contract GuardedBank is ReentrancyGuard {
    error ZeroAmount();
    error InsufficientBalance(uint256 available, uint256 requested);
    error TransferFailed();

    mapping(address => uint256) public balances;

    function deposit() external payable {
        if (msg.value == 0) revert ZeroAmount();
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        uint256 available = balances[msg.sender];
        if (amount > available) revert InsufficientBalance(available, amount);

        balances[msg.sender] = available - amount;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        if (!ok) revert TransferFailed();
    }
}

contract ReentrancyAttack {
    GuardedBank public bank;
    uint256 public attempts;

    constructor(GuardedBank bank_) {
        bank = bank_;
    }

    receive() external payable {
        attempts += 1;
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() external payable {
        bank.deposit{value: msg.value}();
        bank.withdraw(msg.value);
    }
}

contract ReentrancyGuardTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    receive() external payable {}

    function testWithdrawWithGuard() external {
        GuardedBank bank = new GuardedBank();
        vm.deal(address(this), 3 ether);
        bank.deposit{value: 3 ether}();
        bank.withdraw(1 ether);
        require(bank.balances(address(this)) == 2 ether, "balance not reduced");
        require(address(this).balance >= 1 ether, "withdrawal not paid");
    }

    function testReentrancyAttackIsBlocked() external {
        GuardedBank bank = new GuardedBank();

        // Seed the target account through a normal deposit.
        vm.deal(address(0xA77A), 5 ether);
        vm.prank(address(0xA77A));
        bank.deposit{value: 5 ether}();

        ReentrancyAttack attacker = new ReentrancyAttack(bank);
        vm.deal(address(attacker), 5 ether);

        vm.expectRevert();
        attacker.attack{value: 5 ether}();
    }
}
