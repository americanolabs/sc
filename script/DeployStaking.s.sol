// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console2} from "../lib/forge-std/src/console2.sol";
import {Staking} from "../src/Staking.sol";

contract DeployStaking is Script {
    Staking public AAVEV3;
    Staking public SiloV2;
    Staking public EulerV2;
    Staking public SpectraV2;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        AAVEV3 = new Staking(10, 30, 1000000 ether); // 10% APY, 30 days, max 1,000,000 ether
        SiloV2 = new Staking(15, 60, 2000000 ether); // 15% APY, 60 days, max 2,000,000 ether
        EulerV2 = new Staking(20, 90, 3000000 ether); // 20% APY, 90 days, max 3,000,000 ether
        SpectraV2 = new Staking(25, 120, 4000000 ether); // 25% APY, 120 days, max 4,000,000 ether

        vm.stopBroadcast();

        console2.log("AAVEV3 contract deployed at:", address(AAVEV3));
        console2.log("SiloV2 contract deployed at:", address(SiloV2));
        console2.log("EulerV2 contract deployed at:", address(EulerV2));
        console2.log("SpectraV2 contract deployed at:", address(SpectraV2));
    }
}
