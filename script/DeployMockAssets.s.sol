// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {OinkCoin, OinkNft} from "../src/mocks/MockAssets.m.sol";

contract DeployOinkCoin is Script {
    function run() external returns (OinkCoin) {
        vm.startBroadcast();
        OinkCoin oinkCoin = new OinkCoin();
        vm.stopBroadcast();

        return (oinkCoin);
    }
}

contract DeployOinkNft is Script {
    function run() external returns (OinkNft) {
        vm.startBroadcast();
        OinkNft oinkNft = new OinkNft();
        vm.stopBroadcast();

        return (oinkNft);
    }
}
