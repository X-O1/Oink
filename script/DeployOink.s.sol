// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Oink} from "../src/Oink.sol";

contract DeployOink is Script {
    function run() external returns (Oink) {
        vm.startBroadcast();
        Oink oink = new Oink();
        vm.stopBroadcast();

        return oink;
    }
}
