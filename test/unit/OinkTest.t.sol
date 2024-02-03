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
    address BENEFICIARY = makeAddr("beneficiary");
    address BENEFICIARY2 = makeAddr("beneficiary2");
    address OinkCoinAddress = 0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496;
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
        vm.deal(BENEFICIARY, 10 ether);
        vm.deal(BENEFICIARY2, 10 ether);
    }

    function testUserEtherDepositAndThatBalancesUpdate() public {
        vm.prank(USER);
        oink.depositEther(BENEFICIARY, 1 ether);

        assertEq(oink.getEtherBalance(USER), 1 ether);
    }

    function testUserErc20DepositAndThatBalancesUpdate() public {
        vm.prank(USER);
        oinkCoin.approve(address(oink), 10);
        vm.prank(USER);
        oink.depositErc20(BENEFICIARY, OinkCoinAddress, 10);

        assertEq(oink.getErc20Balance(USER, OinkCoinAddress), 10);
    }

    function testUserNftDepositAndThatBalancesUpdate() public {
        vm.prank(USER);
        oinkNft.approve(address(oink), 1);
        vm.prank(USER);
        oink.depositNft(BENEFICIARY, OinkNftAddress, 1);

        assertEq(oink.getNftBalance(USER, OinkNftAddress), 1);
    }

    function testUserAddingBeneficiaries() public {
        vm.prank(USER);
        oink.depositEther(BENEFICIARY, 1);
        vm.prank(USER);
        oink.depositEther(BENEFICIARY2, 1);
        vm.prank(USER);
        oink.getUsersBeneficiaries(USER);
    }

    // function testWrittingAndRetrievingLetter() public {
    //     vm.prank(DECENDANT);
    //     oink.writeLetterToBeneficiary(BENEFICIARY, "I love you.");

    //     vm.prank(BENEFICIARY);
    //     oink.getLetter(BENEFICIARY);
    // }
}
