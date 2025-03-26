// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console2} from "../lib/forge-std/src/console2.sol";
import {Staking} from "../src/Staking.sol";

contract DeployStakingDecaf is Script {
    Staking public Veda;
    Staking public Hord;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = address(0);

        vm.startBroadcast(deployerPrivateKey);

        Veda = new Staking(20, 90, 3000000 ether, tokenAddress); // 20% APY, 90 days, max 3,000,000 ether
        Hord = new Staking(25, 120, 4000000 ether, tokenAddress); // 25% APY, 120 days, max 4,000,000 ether

        vm.stopBroadcast();

        console2.log("Veda contract deployed at:", address(Veda));
        console2.log("Hord contract deployed at:", address(Hord));
    }
}
