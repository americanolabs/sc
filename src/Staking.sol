// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Staking {
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public balances;
    uint8 public apy;
    uint256 public stakingDuration;
    uint256 public maxAmountStaked;
    uint256 public totalStaked;

    event EmergencyWithdraw(address indexed withdrawer, uint256 amount);
    event PartialWithdraw(address indexed withdrawer, uint256 amount);
    event WithdrawAll(address indexed withdrawer, uint256 amount);
    event Staked(
        address indexed staker,
        uint256 amount,
        uint256 durationInDays
    );
    event APYUpdated(uint8 oldAPY, uint8 newAPY);

    constructor(uint8 _apy, uint256 _durationInDays, uint256 _maxAmountStaked) {
        apy = _apy;
        stakingDuration = _durationInDays * 1 days;
        maxAmountStaked = _maxAmountStaked;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            totalStaked + _amount <= maxAmountStaked,
            "Exceeds max stake limit"
        );

        balances[msg.sender] += _amount;
        stakes[msg.sender] = Stake(_amount, block.timestamp, stakingDuration);
        totalStaked += _amount;

        emit Staked(msg.sender, _amount, stakingDuration / 1 days);
    }

    function emergencyWithdraw() external {
        uint256 amount = stakes[msg.sender].amount;
        require(amount > 0, "No stake found");

        delete stakes[msg.sender];
        balances[msg.sender] -= amount;
        totalStaked -= amount;

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function partialWithdraw(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            stakes[msg.sender].amount >= _amount,
            "Insufficient staked balance"
        );

        stakes[msg.sender].amount -= _amount;
        balances[msg.sender] -= _amount;
        totalStaked -= _amount;

        emit PartialWithdraw(msg.sender, _amount);
    }

    function withdrawAll() external {
        uint256 amount = stakes[msg.sender].amount;
        require(amount > 0, "No stake found");

        delete stakes[msg.sender];
        balances[msg.sender] -= amount;
        totalStaked -= amount;

        emit WithdrawAll(msg.sender, amount);
    }

    function updateAPY(uint8 _newAPY) external {
        require(_newAPY > 0, "APY must be greater than 0");
        uint8 oldAPY = apy;
        apy = _newAPY;
        emit APYUpdated(oldAPY, _newAPY);
    }
}
