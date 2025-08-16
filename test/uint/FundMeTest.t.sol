// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";    
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;

    address USER = makeAddr("user");    
    uint256 constant SEND_VALUE = 0.1 ether; //cheat code's values
    uint256 constant STARTING_BALANCE = 10 ether;

    uint256 GAS_PRICE=1;
    function setUp() external {
        // fundMe =new FundMe(AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306));
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE); //cheat code for a local user
    }

    function testMinimumDollarIsFive() view public{
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }

    function testOwnerIsMsgSender() view public {
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() view public{
        uint256 version = fundMe.getVersion();
        assertEq(version,4); //6-mainnet ,4-sepolia
    }

    function testFundFailsWithoutEnoughEth() public  {
        vm.expectRevert(); // next line should revert ie the next line is the actual test case checking with <req val
        fundMe.fund();// fund 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // next tx will be sent from USER address 
        fundMe.fund{value: SEND_VALUE}(); //for payable fnx we send value not params
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }
   
   function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
   }

    modifier funded(){  //for this we can write multiple tests without repeating the same code in multiple tests
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }

   function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert(); //cheat codes skip other cheat codes
        vm.prank(USER);
        fundMe.withdraw();
   }
   function testWithDrawWithASingleFunder() public funded {
     //Arrange 
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    //Act    
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // Assert
    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingFundMeBalance = address(fundMe).balance;
    assertEq(endingFundMeBalance , 0);
    assertEq(
        startingFundMeBalance + startingOwnerBalance , endingOwnerBalance
        );
   }

   function testWithdrawFromMultipleFunders() public funded{
        //Arrange

        uint160 numberOfFunders = 10 ;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex ; i<numberOfFunders ; i++){
            //vm.prank
            //vm.deal
            //address
            hoax(address(i),SEND_VALUE); //for a num to be an address we need to cast it to uint160 "or" directly use uint160
            //hoax is a cheat code that sends value and sets msg.sender
            //hoax is a combination of vm.prank and vm.deal
            fundMe.fund{value:SEND_VALUE}();
            //fund
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
   }
    
}
//unit
//integration
//forked
//staging
