// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    address[] blockedUsers; 
    mapping (address => bool) public isBlocked;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message, bool);

    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
        bool winner; // whether they won or not.
    }

    Wave[] waves;

    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        require(
            !isBlocked[msg.sender], 
            "You have been previously blocked. Enjoy the gulag for all eternity, sorry bub."
        );

        bool winner = false;
        totalWaves += 1;
        console.log("%s has waved!", msg.sender);
        // waves.push(Wave(msg.sender, _message, block.timestamp));

        // Generate a new seed for the next user that sends a wave
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        // Give a 50% chance that the user wins the prize.

        if (seed <= 50) {
            console.log("%s won!", msg.sender);
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
            winner = true;
        }

        waves.push(Wave(msg.sender, _message, block.timestamp, winner));
        emit NewWave(msg.sender, block.timestamp, _message, winner);
        blockUser(msg.sender);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    // Blocking is permanent for now
    function blockUser(address blockedUser) public {
        if (isBlocked[blockedUser]) {
            console.log("User %s is already blocked", blockedUser);
            revert();
        } else {
            isBlocked[blockedUser] = true;
            blockedUsers.push(blockedUser);
            console.log("user %s has been blocked", blockedUser);
        }
    }

    function getAllBlockedUsers() public view returns (address[] memory){
        return blockedUsers;
    }

}