// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract LotteryToken is ERC721, ERC721Pausable, Ownable, ERC721URIStorage {
    uint256 private _nextTokenId;
    mapping(uint256 => address) LotteryWinners;
    uint256 public mintFee = 1 ether;

    constructor(
        address initialOwner
    ) ERC721("LotteryTocken", "LTK") Ownable(initialOwner) {}

    function CheckLotteryWinner(uint256 No) external view returns (address) {
        return LotteryWinners[No];
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string calldata MtokenURI) external payable {
        require(msg.value > mintFee, "Mint Fee Insufficient");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, MtokenURI);
    }

    function LotteryWins() public view returns (uint256) {
        return _nextTokenId;
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Pausable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function withdrawPlatformFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner()).transfer(balance);
    }
}
