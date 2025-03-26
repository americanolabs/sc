// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console2} from "../lib/forge-std/src/console2.sol";
import {Staking} from "../src/Staking.sol";

contract DeployStakingArbitrum is Script {
    Staking public RockX;
    Staking public Camelot;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = address(0);

        vm.startBroadcast(deployerPrivateKey);

        RockX = new Staking(10, 30, 1000000 ether, tokenAddress); // 10% APY, 30 days, max 1,000,000 ether
        Camelot = new Staking(15, 60, 2000000 ether, tokenAddress); // 15% APY, 60 days, max 2,000,000 ether

        vm.stopBroadcast();

        console2.log("RockX contract deployed at:", address(RockX));
        console2.log("Camelot contract deployed at:", address(Camelot));
    }
}
