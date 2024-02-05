// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Oink} from "../../src/Oink.sol";
import {OinkCoin} from "../../src/mocks/MockAssets.m.sol";
import {DeployOink} from "../../script/DeployOink.s.sol";
import {DeployOinkCoin} from "../../script/DeployMockAssets.s.sol";

contract OinkTest is Test {
    Oink oink;
    OinkCoin oinkCoin;

    address OinkContract = 0x90193C961A926261B756D1E5bb255e67ff9498A1;
    address USER = makeAddr("user");
    address BENEFICIARY = makeAddr("beneficiary");
    address BENEFICIARY2 = makeAddr("beneficiary2");
    address OinkCoinAddress = 0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496;
    address UserAddrses = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;

    function setUp() external {
        DeployOink deployOink = new DeployOink();
        oink = deployOink.run();

        DeployOinkCoin deployOinkCoin = new DeployOinkCoin();
        oinkCoin = deployOinkCoin.run();

        vm.deal(OinkContract, 10 ether);
        vm.deal(USER, 10 ether);
        vm.deal(USER, 10 ether);
        vm.deal(BENEFICIARY, 10 ether);
        vm.deal(BENEFICIARY2, 10 ether);
    }

    function testEtherDepositAndThatBalancesUpdate() public {
        vm.prank(USER);
        oink.depositEther(1 ether);

        assertEq(oink.getEtherBalance(USER), 1 ether);
    }

    function testErc20DepositAndThatBalancesUpdate() public {
        vm.prank(USER);
        oinkCoin.approve(address(oink), 10);
        vm.prank(USER);
        oink.depositErc20(OinkCoinAddress, 10);

        assertEq(oink.getErc20Balance(USER, OinkCoinAddress), 10);
    }

    function testEtherWithdrawlAndBalancesUpdate() public {
        vm.prank(USER);
        oink.depositEther(5 ether);

        vm.prank(USER);
        oink.withdrawEther(1 ether);

        assertEq(oink.getEtherBalance(USER), 4 ether);

        vm.expectRevert();
        vm.prank(USER);
        oink.withdrawEther(6 ether);
    }

    function testErc20WithdrawlAndBalancesUpdate() public {
        vm.prank(USER);
        oinkCoin.approve(address(oink), 10);
        vm.prank(USER);
        oink.depositErc20(OinkCoinAddress, 10);

        vm.prank(USER);
        oink.withdrawErc20(OinkCoinAddress, 5);

        assertEq(oink.getErc20Balance(USER, OinkCoinAddress), 5);

        vm.expectRevert();
        vm.prank(USER);
        oink.withdrawErc20(OinkCoinAddress, 10);
    }

    function testUserAddingBeneficiaries() public {
        vm.prank(USER);
        oink.addBeneficiary(BENEFICIARY);
        vm.prank(USER);
        oink.addBeneficiary(BENEFICIARY2);
        vm.prank(USER);
        oink.getListOfBeneficiaries(USER);
    }

    function testInheritingEtherAndBalancesUpdate() public {
        vm.prank(USER);
        oink.depositEther(5 ether);

        vm.expectRevert();
        vm.prank(BENEFICIARY);
        oink.inheritEther(USER, 5 ether);

        vm.prank(USER);
        oink.addBeneficiary(BENEFICIARY);

        vm.prank(BENEFICIARY);
        oink.inheritEther(USER, 5 ether);
    }

    function testInheritingErc20AndBalancesUpdate() public {
        vm.prank(USER);
        oinkCoin.approve(address(oink), 10);
        vm.prank(USER);
        oink.depositErc20(OinkCoinAddress, 10);

        vm.expectRevert();
        vm.prank(BENEFICIARY);
        oink.inheritErc20(USER, OinkCoinAddress, 10);

        vm.prank(USER);
        oink.addBeneficiary(BENEFICIARY);

        vm.prank(BENEFICIARY);
        oink.inheritErc20(USER, OinkCoinAddress, 10);
    }

    // function testWrittingAndRetrievingLetter() public {
    //     vm.prank(DECENDANT);
    //     oink.writeLetterToBeneficiary(BENEFICIARY, "I love you.");

    //     vm.prank(BENEFICIARY);
    //     oink.getLetter(BENEFICIARY);
    // }
}
