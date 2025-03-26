// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
    }

    mapping(address => Stake) public stakes;
    uint8 public fixedAPY;
    uint256 public stakingDuration;
    uint256 public maxAmountStaked;
    uint256 public totalAmountStaked;
    address public tokenAddress;
    address public owner;

    event Staked(address indexed staker, uint256 amount, uint256 duration);
    event Withdrawn(address indexed staker, uint256 amount);
    event EmergencyWithdrawn(address indexed staker, uint256 amount);
    event APYUpdated(uint8 oldAPY, uint8 newAPY);
    event WithdrawAll(address indexed staker, uint256 amount);

    constructor(
        uint8 _apy,
        uint256 _durationInDays,
        uint256 _maxAmountStaked,
        address _tokenAddress
    ) {
        fixedAPY = _apy;
        stakingDuration = _durationInDays * 1 days;
        maxAmountStaked = _maxAmountStaked;
        tokenAddress = _tokenAddress;
        owner = msg.sender;
    }

    function stake(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        require(stakes[msg.sender].amount == 0, "Already staked");
        require(
            totalAmountStaked + _amount <= maxAmountStaked,
            "Exceeds max stake limit"
        );

        if (tokenAddress == address(0)) {
            require(msg.value == _amount, "Incorrect amount");
        } else {
            require(
                IERC20(tokenAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Transfer failed"
            );
        }

        stakes[msg.sender] = Stake(_amount, block.timestamp, stakingDuration);
        totalAmountStaked += _amount;

        emit Staked(msg.sender, _amount, stakingDuration);
    }

    function withdraw() external nonReentrant {
        Stake storage stakeData = stakes[msg.sender];
        require(stakeData.amount > 0, "No active stake");
        require(
            block.timestamp >= stakeData.startTime + stakeData.duration,
            "Stake still locked"
        );

        uint256 amount = stakeData.amount;
        delete stakes[msg.sender];
        totalAmountStaked -= amount;

        if (tokenAddress == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            require(
                IERC20(tokenAddress).transfer(msg.sender, amount),
                "Transfer failed"
            );
        }

        emit Withdrawn(msg.sender, amount);
    }

    function emergencyWithdraw() external nonReentrant {
        Stake storage stakeData = stakes[msg.sender];
        require(stakeData.amount > 0, "No active stake");

        uint256 amount = stakeData.amount;
        delete stakes[msg.sender];
        totalAmountStaked -= amount;

        if (tokenAddress == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            require(
                IERC20(tokenAddress).transfer(msg.sender, amount),
                "Transfer failed"
            );
        }

        emit EmergencyWithdrawn(msg.sender, amount);
    }

    function withdrawAll() external nonReentrant {
        Stake storage stakeData = stakes[msg.sender];
        require(stakeData.amount > 0, "No funds to withdraw");

        uint256 amount = stakeData.amount;
        delete stakes[msg.sender];
        totalAmountStaked -= amount;

        if (tokenAddress == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            require(
                IERC20(tokenAddress).transfer(msg.sender, amount),
                "Transfer failed"
            );
        }

        emit WithdrawAll(msg.sender, amount);
    }

    function updateAPY(uint8 _newAPY) external {
        require(msg.sender == owner, "Not the contract owner");
        require(_newAPY > 0, "APY must be greater than 0");

        uint8 oldAPY = fixedAPY;
        fixedAPY = _newAPY;
        emit APYUpdated(oldAPY, _newAPY);
    }
}
