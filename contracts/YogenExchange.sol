// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./YogenFuture.sol";


contract YogenExchange {
  struct Future {
    address initiator;
    uint256 initiatorNFTId;
    address tokenIn;
    uint256 amountIn;
    address tokenOut;
    uint256 amountOut;
    address counterparty;
    uint256 counterpartyNFTId;
    uint256 deliveryDate;
    bool isExecuted;
  }

  string public constant name = "YogenExchange";
  string public constant version = "0";
  bytes32 public DOMAIN_SEPARATOR;

  bytes32 public constant CREATE_TYPEHASH = keccak256("create()");

  YogenFuture public yogenFuture;
  uint256 public executorFee;
  uint256 public currentFee;
  address public feeCollector;

  Future[] public futures;

  mapping (bytes => bool) public isSigBurnt;

  event FutureCreated(
    uint256 futureId,
    address indexed initiator,
    address indexed counterparty
  );

  event FutureExecuted(
    uint256 futureId,
    address indexed initiator,
    address indexed counterparty,
    address indexed executor
  );

  constructor(
    address yogenFutureAddress,
    uint256 executorFee,
    uint256 initialFee,
    address initialFeeCollector
  ) {
    yogenFuture = YogenFuture(yogenFutureAddress);
    currentFee = initialFee;
    feeCollector = initialFeeCollector;

    uint256 chainId;

    assembly {
      chainId := chainid()
    }

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
        // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(name)),
        keccak256(bytes(version)),
        chainId,
        address(this)
      )
    );
  }

  function create(
    address initiator,
    address tokenIn,
    uint256 amountIn,
    address tokenOut,
    uint256 amountOut,
    uint256 deliveryDate,
    uint256 expirationDate,
    bytes memory initiatorSig
  ) external nonReentrant() {
    require(isSigBurnt[initiatorSig] == false, "SIG_BURNT");

    bytes memory data = abi.encode(
      CREATE_TYPEHASH,
      initiator,
      tokenIn,
      amountIn,
      tokenOut,
      amountOut,
      deliveryDate,
      expirationDate
    );

    require(_recover(DOMAIN_SEPARATOR, sig, data), "INVALID_SIG");

    uint256 initiatorNFTId = yogenFuture.mint(future.initiator, future.length - 1, true);
    uint256 counterpartyNFTId = yogenFuture.mint(future.counterparty, future.length - 1, false);

    require(
      IERC20(tokenIn).transferFrom(initiator, address(this), amountIn),
      "TOKEN_IN_TRANSFER_FAILED"
    );

    require(
      IERC20(tokenOut).transferFrom(msg.sender, address(this), amountOut),
      "TOKEN_OUT_TRANSFER_FAILED"
    );

    futures.push(
      Future({
        initiator: initiator,
        initiatorNFTId: initiatorNFTId,
        tokenIn: tokenIn,
        amountIn: amountIn,
        tokenOut: tokenOut,
        amountOut: amountOut,
        counterparty: msg.sender,
        counterpartyNFTId: counterpartyNFTId,
        deliveryDate: deliveryDate,
        isExecuted: false
      })
    );

    emit FutureCreated(futures.length - 1, initiator, msg.sender);
  }

  function execute(
    uint256 futureId
  ) external {
    address initiator = YogenFuture(yogenFuture).ownerOf(futures[futureid].initiatorNFTId);
    require(msg.sender == initiator, "NOT_INITIATOR");

    if (futures[futureId].futureStyle == FutureStyle.BEFORE) {

    }

    YogenFuture(yogenFuture).burn(futures[futureid].initiatorNFTId);
    YogenFuture(yogenFuture).burn(futures[futureid].counterpartyNFTId);

    require(
      IERC20(underlyingAsset).transferFrom(initiator, address(this), underlyingAssetQty),
      "UNDERLYING_ASSET_TRANSFER_FAILED"
    );

    require(
      IERC20(currency).transferFrom(msg.sender, address(this), currencyQty),
      "CURRENCY_TRANSFER_FAILED"
    );
  }

  function _recover(
    bytes32 domainSeparator,
    bytes memory sig,
    bytes memory typeHashAndData
  ) private pure returns (address) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        domainSeparator,
        keccak256(typeHashAndData)
      )
    );

    return ECDSA.recover(digest, sig);
  }
}
