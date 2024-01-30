// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Oink} from "../../src/Oink.sol";
import {OinkCoin, OinkNft} from "../../src/mocks/MockAssets.m.sol";
import {DeployOink} from "../../script/DeployOink.s.sol";
import {DeployOinkCoin, DeployOinkNft} from "../../script/DeployMockAssets.s.sol";

contract OinkTest is Test {
    Oink oink;
    OinkCoin oinkCoin;
    OinkNft oinkNft;

    address USER = makeAddr("user");

    function setUp() external {
        DeployOink deployOink = new DeployOink();
        oink = deployOink.run();

        DeployOinkCoin deployOinkCoin = new DeployOinkCoin();
        oinkCoin = deployOinkCoin.run();

        DeployOinkNft deployOinkNft = new DeployOinkNft();
        oinkNft = deployOinkNft.run();

        vm.deal(USER, 10 ether);
    }
}
