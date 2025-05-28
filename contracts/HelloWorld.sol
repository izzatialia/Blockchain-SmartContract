//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract Helloworld{
    string public greeting = "Hello to the World of Blockchain";

    function updateGreeting (string memory _newGreeting) public {
        greeting = _newGreeting;
    }
}