// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Test.sol";
import "../src/Staking.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {
        _mint(msg.sender, 1000 ether);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract StakingTest is Test {
    Staking staking;
    MockERC20 token;
    address user = address(0x123);
    address owner = address(this);

    uint8 constant APY = 10;
    uint256 constant DURATION = 30 days;
    uint256 constant MAX_STAKE = 100 ether;
    uint256 constant STAKE_AMOUNT = 1 ether;

    function setUp() public {
        token = new MockERC20();
        staking = new Staking(
            APY,
            DURATION / 1 days,
            MAX_STAKE,
            address(token)
        );

        token.mint(user, 10 ether);
        vm.prank(user);
        token.approve(address(staking), 10 ether);
    }

    function testStakeERC20() public {
        vm.prank(user);
        staking.stake(STAKE_AMOUNT);

        (uint256 amount, uint256 startTime, uint256 duration) = staking.stakes(
            user
        );
        assertEq(amount, STAKE_AMOUNT);
        assertEq(duration, DURATION);
        assertGt(startTime, 0);
    }

    function testCannotStakeTwice() public {
        vm.prank(user);
        staking.stake(STAKE_AMOUNT);

        vm.prank(user);
        vm.expectRevert("Already staked");
        staking.stake(STAKE_AMOUNT);
    }

    function testWithdrawAfterDuration() public {
        vm.prank(user);
        staking.stake(STAKE_AMOUNT);

        vm.warp(block.timestamp + DURATION);
        vm.prank(user);
        staking.withdraw();

        (uint256 amount, , ) = staking.stakes(user);
        assertEq(amount, 0);
    }

    function testEmergencyWithdraw() public {
        vm.prank(user);
        staking.stake(STAKE_AMOUNT);

        vm.prank(user);
        staking.emergencyWithdraw();

        (uint256 amount, , ) = staking.stakes(user);
        assertEq(amount, 0);
    }

    function testUpdateAPY() public {
        uint8 newAPY = 15;
        vm.prank(owner);
        staking.updateAPY(newAPY);
        assertEq(staking.fixedAPY(), newAPY);
    }

    function testWithdrawAll() public {
        vm.prank(user);
        staking.stake(STAKE_AMOUNT);

        uint256 balanceBefore = token.balanceOf(user);
        vm.prank(user);
        staking.withdrawAll();
        uint256 balanceAfter = token.balanceOf(user);

        assertEq(balanceAfter, balanceBefore + STAKE_AMOUNT);

        (uint256 amount, , ) = staking.stakes(user);
        assertEq(amount, 0);
    }
}
