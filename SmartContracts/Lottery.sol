// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./LotteryToken.sol";

contract Lottery {
    LotteryToken public nft;

    constructor(LotteryToken _nft) {
        nft = _nft;
    }

    uint256 lotteryId = 0;
    uint256 LotteryCreatingPrice = 1 ether;

    struct LotteryDetails {
        uint256 lotteryMembers;
        uint256 lotteryAmount;
        uint256 lotteryWinner;
        uint256 lotteryEndTime;
        bool LotteryStatus;
    }

    mapping(uint256 => LotteryDetails) LotteryUser;
    mapping(uint256 => address) LotteryUserAddress;

    function createLottery(
        uint256 TicketPrice,
        uint256 TimeSpan
    ) public payable returns (uint256) {
        require(msg.value > LotteryCreatingPrice, "Insufficient balance");
        payable(address(this)).transfer(LotteryCreatingPrice);
        ++lotteryId;
        LotteryUser[lotteryId].lotteryMembers = 0;
        LotteryUser[lotteryId].lotteryAmount = TicketPrice;
        LotteryUser[lotteryId].lotteryEndTime = block.timestamp + TimeSpan;
        LotteryUser[lotteryId].LotteryStatus = true;
        return lotteryId;
    }

    function BuyLotery(uint256 no) public payable {
        require(
            msg.value > LotteryUser[no].lotteryAmount,
            "Insufficient Amount"
        );
        require(LotteryUser[no].LotteryStatus == true, "Unintialized Lottery");
        LotteryUser[no].lotteryMembers++;
        LotteryUserAddress[LotteryUser[no].lotteryMembers] = msg.sender ;
        payable(address(this)).transfer(msg.value);
    }

    function EndLottery(uint256 Lotteryid , uint256 LotteryWinner) public {
        require(
            block.timestamp > LotteryUser[Lotteryid].lotteryEndTime,
            " Lottery Not Ended"
        );
        require(LotteryUserAddress[LotteryWinner] != address(0) , "Malfunctionad account");
        payable()

    }
}
