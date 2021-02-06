// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./YogenFuture.sol";


contract YogenExchange {
  string public constant name = "YogenExchange";
  string public constant version = "0";
  bytes32 public DOMAIN_SEPARATOR;

  bytes32 public constant SWAP_TYPEHASH = keccak256("swap(uint256 amountIn,address tokenIn,uint256 amountOut,address tokenOut,uint256 maxCost,uint256 nonce");

  enum FutureType { CALL, PUT }
  enum FutureStyle { EU, US }

  struct Future {
    address initiator;
    uint256 initiatorNFTId;
    address underlyingAsset;
    uint256 underlyingAssetQty;
    address counterparty;
    uint256 counterpartyNFTId;
    address currency;
    uint256 currencyQty;
    uint256 targetDate;
    FutureType futureType;
    FutureStyle futureStyle;
    bool isExecuted;
  }

  Future[] public futures;

  YogenFuture public yogenFuture;
  uint256 public currentFee = 5; // 0.05%
  address public feeCollector;

  mapping (bytes => bool) public isSigBurnt;

  constructor(
    address yogenFutureAddress,
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
    Future memory future,
    bytes memory initiatorSig
  ) external {
    require(isSigBurnt[initiatorSig] == false, "ERR_SIG_BURNT");

    // TODO: Check the sig

    futures.push(future);

    yogenFuture.mint(future.initiator, future.length - 1, true);
    yogenFuture.mint(future.counterparty, future.length - 1, false);
  }

  function swap(
    uint256 amountIn,
    address tokenIn,
    uint256 amountOut,
    address tokenOut,
    uint256 maxCost,
    uint256 nonce,
    address investor,
    bytes memory sig
  ) external {
    require(nonces[investor] == nonce, "Wrong nonce");
    require(isSigCanceled[sig] == false, "Canceled sig");

    uint256 initialGas = gasleft();
    nonces[investor] += 1;

    bytes memory data = abi.encode(
      SWAP_TYPEHASH,
      amountIn,
      tokenIn,
      amountOut,
      tokenOut,
      maxCost,
      nonce
    );

    require(_recover(DOMAIN_SEPARATOR, sig, data), "Wrong sig");

    require(
      IERC20(tokenIn).transferFrom(investor, address(this), amountIn) == true,
      "Token transfer failed"
    );

    uint256 allowance = token.allowance(address(this), address(router));

    if (amountIn > allowance) {
      token.approve(address(router), uint256(-1));
    }

    uint256[] memory amounts;
    uint256[] memory path = uint256[](2);
    path[0] = tokenIn;
    path[1] = tokenOut;

    if (tokenOut == WETH) {
      amounts = router.swapExactTokensForETH(
        amountIn,
        amountOut,
        path,
        investor,
        block.timestamp
      );
    } else {
      amounts = router.swapExactTokensForTokens(
        amountIn,
        amountOut,
        path,
        investor,
        block.timestamp
      );
    }

    require(
      IERC20(WETH).transferFrom(investor, operator, maxCost) == true,
      "Cannot pay cost"
    );

    emit Swapped(
      investor,
      amountIn,
      amounts[amounts.length - 1]
    );

    require(
      SafeMath.mul(
        SafeMath.sub(initialGas - gasleft()),
        tx.gas
      ) > maxCost,
     "Cost too high"
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
