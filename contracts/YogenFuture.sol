// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract YogenFuture is ERC721, Ownable {
  mapping (address => bool) public isYogenExchange;

  uint256 public currentTokenId;
  mapping (uint256 => uint256) public tokenToFuture;
  mapping (uint256 => bool) public isInitiatorToken;

  constructor() ERC721(
    "YogenFuture",
    "YOGNF"
  ) {}

  modifier onlyYogenExchange() {
    require(isYogenExchange[msg.sender], "ERR_NOT_YOGEN_EXCHANGE");
    _;
  }

  function mint(
    address to,
    uint256 futureId,
    bool isInitiator
  ) external onlyYogenExchange() returns (uint256) {
    _mint(to, currentTokenId);
    tokenToFuture[currentTokenId] = futureId;
    isInitiatorToken[currentTokenId] = isInitiator;
    currentTokenId += 1;

    return currentTokenId - 1;
  }

  function burn(
    uint256 tokenId
  ) external onlyYogenExchange() {
    _burn(tokenId);
  }

  function updateYogenExchange(
    address yogenExchange,
    bool status
  ) external onlyOwner() {
    isYogenExchange[yogenExchange] = status;
  }
}
