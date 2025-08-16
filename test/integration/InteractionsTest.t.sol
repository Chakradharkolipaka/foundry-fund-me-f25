// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";    
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test{
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
    
    function testUserCanFundInteractions() public{
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }

}