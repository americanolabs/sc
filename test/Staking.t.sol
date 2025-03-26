// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/forge-std/src/Test.sol";
import "../src/Staking.sol";

contract StakingTest is Test {
    Staking public staking;
    address public user = address(1);

    function setUp() public {
        staking = new Staking(10, 30, 1000 ether); // 10% APY, 30 days, max 1000 ether
    }

    function testStake() public {
        vm.startPrank(user);
        staking.stake(100 ether);
        vm.stopPrank();
        assertEq(staking.balances(user), 100 ether);
    }

    function testEmergencyWithdraw() public {
        vm.startPrank(user);
        staking.stake(100 ether);
        staking.emergencyWithdraw();
        vm.stopPrank();
        assertEq(staking.balances(user), 0);
    }

    function testPartialWithdraw() public {
        vm.startPrank(user);
        staking.stake(100 ether);
        staking.partialWithdraw(50 ether);
        vm.stopPrank();
        assertEq(staking.balances(user), 50 ether);
    }

    function testWithdrawAll() public {
        vm.startPrank(user);
        staking.stake(100 ether);
        staking.withdrawAll();
        vm.stopPrank();
        assertEq(staking.balances(user), 0);
    }
}
