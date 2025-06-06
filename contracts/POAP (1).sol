// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract POAP is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    struct Event {
        uint256 eventId;
        string name;
        uint256 startTime;
        uint256 endTime;
        bytes32[] secretHashes;
        mapping(address => bool) hasClaimed;
        address[] participants;
    }

    mapping(uint256 => Event) private events;

    event POAPClaimed(address indexed user, uint256 tokenId, uint256 eventId);

    constructor() ERC721("POAP Attendance Badge", "POAP") Ownable(msg.sender) {}

    // ---- Create a new event ----
    function createEvent(
        uint256 eventId,
        string memory name,
        uint256 startInMinutes,
        uint256 durationInMinutes,
        bytes32[] memory secretHashes
    ) external onlyOwner {
        require(events[eventId].startTime == 0, "Event already exists");

        uint256 startTime = block.timestamp + (startInMinutes * 60);
        uint256 endTime = startTime + (durationInMinutes * 60);

        Event storage newEvent = events[eventId];
        newEvent.eventId = eventId;
        newEvent.name = name;
        newEvent.startTime = startTime;
        newEvent.endTime = endTime;

        for (uint256 i = 0; i < secretHashes.length; i++) {
            newEvent.secretHashes.push(secretHashes[i]);
        }
    }

    // ---- Claim POAP by entering eventId and secret code ----
    function claimPOAP(uint256 eventId, string memory secretCode) external {
        Event storage eventInfo = events[eventId];

        require(block.timestamp >= eventInfo.startTime, "Claim period not started");
        require(block.timestamp <= eventInfo.endTime, "Claim period ended");
        require(!eventInfo.hasClaimed[msg.sender], "You already claimed this POAP");

        bytes32 hashedSecret = keccak256(abi.encodePacked(secretCode));

        bool valid = false;
        for (uint256 i = 0; i < eventInfo.secretHashes.length; i++) {
            if (eventInfo.secretHashes[i] == hashedSecret) {
                valid = true;
                break;
            }
        }

        require(valid, "Invalid secret code");

        // Restrict one claim per wallet + track claimed
        eventInfo.hasClaimed[msg.sender] = true;
        eventInfo.participants.push(msg.sender);

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);

        emit POAPClaimed(msg.sender, newTokenId, eventId);
    }

    function getParticipants(uint256 eventId) external view returns (address[] memory) {
        return events[eventId].participants;
    }

    function totalSupply() external view returns (uint256) {
        return _tokenIds.current();
    }

}
