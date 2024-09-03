// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./LotteryToken.sol";

contract Lottery {
    LotteryToken public nft;
    uint256 public lotteryId = 0;
    uint256 public constant LOTTERY_CREATING_PRICE = 1 ether;

    struct LotteryDetails {
        uint256 lotteryMembers;
        uint256 lotteryAmount;
        address lotteryWinner;
        uint256 lotteryEndTime;
        bool lotteryStatus;
    }

    mapping(uint256 => LotteryDetails) public lotteries;
    mapping(uint256 => mapping(uint256 => address)) public lotteryParticipants;

    event LotteryCreated(
        uint256 indexed lotteryId,
        uint256 ticketPrice,
        uint256 endTime
    );
    event TicketPurchased(uint256 indexed lotteryId, address buyer);
    event LotteryEnded(
        uint256 indexed lotteryId,
        address winner,
        uint256 prize
    );

    constructor(LotteryToken _nft) {
        nft = _nft;
    }

    function createLottery(
        uint256 ticketPrice,
        uint256 timeSpan
    ) public payable returns (uint256) {
        require(msg.value >= LOTTERY_CREATING_PRICE, "Insufficient balance");

        lotteryId++;
        lotteries[lotteryId] = LotteryDetails({
            lotteryMembers: 0,
            lotteryAmount: ticketPrice,
            lotteryWinner: address(0),
            lotteryEndTime: block.timestamp + timeSpan,
            lotteryStatus: true
        });

        emit LotteryCreated(lotteryId, ticketPrice, block.timestamp + timeSpan);
        return lotteryId;
    }

    function buyLotteryTicket(uint256 lotteryId) public payable {
        LotteryDetails storage lottery = lotteries[lotteryId];
        require(lottery.lotteryStatus, "Lottery is not active");
        require(msg.value >= lottery.lotteryAmount, "Insufficient amount");
        require(block.timestamp < lottery.lotteryEndTime, "Lottery has ended");

        lottery.lotteryMembers++;
        lotteryParticipants[lotteryId][lottery.lotteryMembers] = msg.sender;

        emit TicketPurchased(lotteryId, msg.sender);
    }

    function endLottery(uint256 lotteryId) public {
        LotteryDetails storage lottery = lotteries[lotteryId];
        require(
            block.timestamp >= lottery.lotteryEndTime,
            "Lottery has not ended yet"
        );
        require(lottery.lotteryStatus, "Lottery is not active");
        require(lottery.lotteryMembers > 0, "No participants in the lottery");

        lottery.lotteryStatus = false;
        uint256 winnerIndex = (uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        ) % lottery.lotteryMembers) + 1;
        address winner = lotteryParticipants[lotteryId][winnerIndex];
        lottery.lotteryWinner = winner;

        uint256 prize = lottery.lotteryAmount * lottery.lotteryMembers;
        payable(winner).transfer(prize);

        emit LotteryEnded(lotteryId, winner, prize);
    }

    function getLotteryDetails(
        uint256 lotteryId
    ) public view returns (LotteryDetails memory) {
        return lotteries[lotteryId];
    }
}
