// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console2} from "../lib/forge-std/src/console2.sol";
import {Staking} from "../src/Staking.sol";

contract DeployStakingBase is Script {
    Staking public Morpho;
    Staking public Aave;
    Staking public Pendle;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = address(0);

        vm.startBroadcast(deployerPrivateKey);

        Morpho = new Staking(17, 90, 3000000 ether, tokenAddress); // 20% APY, 90 days, max 3,000,000 ether
        Aave = new Staking(13, 120, 4000000 ether, tokenAddress); // 25% APY, 120 days, max 4,000,000 ether
        Pendle = new Staking(12, 30, 1000000 ether, tokenAddress); // 25% APY, 120 days, max 4,000,000 ether

        vm.stopBroadcast();

        console2.log("Morpho contract deployed at:", address(Morpho));
        console2.log("Aave contract deployed at:", address(Aave));
        console2.log("Pendle contract deployed at:", address(Pendle));
    }
}
