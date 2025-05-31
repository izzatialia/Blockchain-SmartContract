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

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Deadline passed");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Deadline not yet reached");
        _;
    }

    // Contract setup
    constructor(uint _goalInEther, uint _durationInMinutes) {
        owner = msg.sender;
        goal = _goalInEther * 1 ether;
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    // Functions
    function contribute() public payable beforeDeadline {
        require(msg.value > 0.01 ether, "Minimum contribution is 0.01 ETH");

        if (contributions[msg.sender] == 0) {
            contributorCount++;
        }

        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit FundReceived(msg.sender, msg.value);

        if (raisedAmount >= goal) {
            emit GoalReached(raisedAmount);
        }
    }

    function checkBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdraw() public onlyOwner {
        require(raisedAmount >= goal, "Goal not reached");
        payable(owner).transfer(address(this).balance);
    }

    function refund() public afterDeadline {
        require(raisedAmount < goal, "Goal was met");
        uint contributed = contributions[msg.sender];
        require(contributed > 0, "No contributions found");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributed);

        emit Refunded(msg.sender, contributed);
    }

    function getDetails() public view returns (
        uint _goal,
        uint _deadline,
        uint _raisedAmount,
        uint _contributorCount
    ) {
        return (goal, deadline, raisedAmount, contributorCount);
    }
} 