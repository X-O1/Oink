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
    address OinkAddress = 0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496;
    address OinkNftAddress = 0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3;
    address UserAddrses = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;

    function setUp() external {
        DeployOink deployOink = new DeployOink();
        oink = deployOink.run();

        DeployOinkCoin deployOinkCoin = new DeployOinkCoin();
        oinkCoin = deployOinkCoin.run();

        DeployOinkNft deployOinkNft = new DeployOinkNft();
        oinkNft = deployOinkNft.run();

        vm.deal(USER, 10 ether);
    }

    function testUserEtherDeposit() public {
        vm.prank(USER);
        oink.depositEther(1 ether);
    }

    function testUserErc20Deposit() public {
        vm.prank(USER);
        oinkCoin.approve(address(oink), 10);
        vm.prank(USER);
        oink.depositToken(OinkAddress, 10);
    }

    function testUserNftDeposit() public {
        vm.prank(USER);
        oinkNft.approve(address(oink), 1);
        vm.prank(USER);
        oink.depositNft(OinkNftAddress, 1);
    }
}
