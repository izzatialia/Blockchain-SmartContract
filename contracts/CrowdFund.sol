// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0; 
 
contract CrowdFund { 
    address public owner;      // Owner of the contract
    uint public goal;
    uint public deadline;
    uint public raisedAmount;
    uint public contributorCount; 
    mapping(address => uint) public contributions;

    // Log purposes
    event FundReceived(address contributor, uint amount);
    event GoalReached(uint totalRaised);
    event Refunded(address contributor, uint amount);

    modifier onlyOwner() { 
        require(msg.sender == owner, "Not authorized"); 
        _; 
    }
} 