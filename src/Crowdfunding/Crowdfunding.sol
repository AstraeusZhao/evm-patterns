// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title Crowdfunding
/// @notice A simple reward-based crowdfunding campaign: backers pledge ETH
///         before a deadline; if the goal is met, the creator collects,
///         otherwise backers claim refunds.
/// @dev Demonstrates state machine, deadline checks, and pull-over-push refunds.
///      Not audited.
contract Crowdfunding {
    error GoalNotReached();
    error GoalAlreadyReached();
    error DeadlinePassed();
    error DeadlineNotPassed();
    error NoPledge();
    error NotCreator();
    error TransferFailed();

    event Pledged(address indexed backer, uint256 amount);
    event Refunded(address indexed backer, uint256 amount);
    event FundsCollected(uint256 total);

    address public immutable creator;
    uint256 public immutable goal;
    uint256 public immutable deadline;

    uint256 public totalPledged;
    mapping(address backer => uint256 amount) public pledges;

    bool private _claimed;

    /// @param goal_ Target amount in wei.
    /// @param duration_ Seconds until the campaign ends.
    constructor(uint256 goal_, uint256 duration_) {
        creator = msg.sender;
        goal = goal_;
        deadline = block.timestamp + duration_;
    }

    /// @notice Pledge ETH to the campaign.
    function pledge() external payable {
        if (block.timestamp >= deadline) revert DeadlinePassed();
        pledges[msg.sender] += msg.value;
        totalPledged += msg.value;
        emit Pledged(msg.sender, msg.value);
    }

    /// @notice Claim a refund if the goal wasn't reached.
    function refund() external {
        if (block.timestamp < deadline) revert DeadlineNotPassed();
        if (totalPledged >= goal) revert GoalAlreadyReached();

        uint256 amount = pledges[msg.sender];
        if (amount == 0) revert NoPledge();

        pledges[msg.sender] = 0;
        emit Refunded(msg.sender, amount);

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    /// @notice Creator collects the funds once the goal is met.
    function collect() external {
        if (msg.sender != creator) revert NotCreator();
        if (block.timestamp < deadline) revert DeadlineNotPassed();
        if (totalPledged < goal) revert GoalNotReached();
        if (_claimed) revert GoalAlreadyReached();

        _claimed = true;
        emit FundsCollected(totalPledged);

        (bool ok,) = payable(creator).call{value: totalPledged}("");
        if (!ok) revert TransferFailed();
    }
}
