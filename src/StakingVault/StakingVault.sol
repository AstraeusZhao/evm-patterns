// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;


/// @notice Teaching ETH vault with lazy, funded rewards. Rate is WAD per staked wei/second.
contract StakingVault {
    error ZeroAmount();error NotOwner(address caller);error InsufficientStake(uint256 available,uint256 requested);
    error TransferFailed();error Reentrancy();error InvalidRate();
    struct StakeInfo{uint256 amount;uint256 lastUpdate;uint256 accumulatedReward;}
    mapping(address=>StakeInfo) public stakes;mapping(address=>uint256) private paidPerToken;
    uint256 public totalStaked;uint256 public rewardReserve;uint256 public rewardRemaining;
    uint256 public rewardPerTokenStored;uint256 public lastUpdate;uint256 public rewardRatePerSecond;
    uint256 public constant SCALE=1e18;address public immutable owner;uint256 private lock=1;
    event Staked(address indexed account,uint256 amount);event Withdrawn(address indexed account,uint256 amount);
    event RewardClaimed(address indexed account,uint256 amount);event RewardRateSet(uint256 ratePerSecond);event RewardsFunded(uint256 amount);
    modifier onlyOwner(){if(msg.sender!=owner)revert NotOwner(msg.sender);_;}
    modifier guarded(){if(lock!=1)revert Reentrancy();lock=2;_;lock=1;}
    constructor(){owner=msg.sender;lastUpdate=block.timestamp;}
    function _sync() internal {
        uint256 elapsed=block.timestamp-lastUpdate;lastUpdate=block.timestamp;
        if(totalStaked==0||rewardRemaining==0||rewardRatePerSecond==0)return;
        // Rate capped at SCALE; cap before multiplying by an arbitrary elapsed time.
        uint256 rateTime=elapsed>type(uint256).max/rewardRatePerSecond?type(uint256).max:elapsed*rewardRatePerSecond;
        uint256 reward=rateTime>=SCALE&&totalStaked>type(uint256).max/rateTime?rewardRemaining:totalStaked*rateTime/SCALE;
        if(reward>rewardRemaining)reward=rewardRemaining;
        uint256 increment=(reward/totalStaked)*SCALE+(reward%totalStaked)*SCALE/totalStaked;
        rewardPerTokenStored+=increment;rewardRemaining-=reward;
    }
    function _update(address account) internal {
        _sync();StakeInfo storage s=stakes[account];
        s.accumulatedReward+=s.amount*(rewardPerTokenStored-paidPerToken[account])/SCALE;
        paidPerToken[account]=rewardPerTokenStored;s.lastUpdate=block.timestamp;
    }
    function fundRewards() external payable onlyOwner guarded {
        if(msg.value==0)revert ZeroAmount();_sync();rewardReserve+=msg.value;rewardRemaining+=msg.value;emit RewardsFunded(msg.value);
    }
    function setRewardRate(uint256 rate) external onlyOwner guarded {
        if(rate>SCALE)revert InvalidRate();_sync();rewardRatePerSecond=rate;emit RewardRateSet(rate);
    }
    function stake() external payable guarded {
        if(msg.value==0)revert ZeroAmount();_update(msg.sender);stakes[msg.sender].amount+=msg.value;totalStaked+=msg.value;emit Staked(msg.sender,msg.value);
    }
    function unstake(uint256 amount) external guarded {
        if(amount==0)revert ZeroAmount();_update(msg.sender);StakeInfo storage s=stakes[msg.sender];
        if(amount>s.amount)revert InsufficientStake(s.amount,amount);s.amount-=amount;totalStaked-=amount;
        emit Withdrawn(msg.sender,amount);(bool ok,)=payable(msg.sender).call{value:amount}("");if(!ok)revert TransferFailed();
    }
    function claimRewards() external guarded {
        _update(msg.sender);uint256 reward=stakes[msg.sender].accumulatedReward;if(reward==0)revert ZeroAmount();
        require(reward<=rewardReserve&&reward<=address(this).balance-totalStaked,"unfunded reward");
        stakes[msg.sender].accumulatedReward=0;rewardReserve-=reward;emit RewardClaimed(msg.sender,reward);
        (bool ok,)=payable(msg.sender).call{value:reward}("");if(!ok)revert TransferFailed();
    }
    function stakedOf(address account) external view returns(uint256){return stakes[account].amount;}
}
