/* eslint-disable no-underscore-dangle, camelcase */
/* eslint-env node, mocha */

import hre from 'hardhat';
import '@nomiclabs/hardhat-ethers';
import {
  BigNumber,
  Signer,
  utils,
  Wallet,
} from 'ethers';
import { expect } from 'chai';

import {
  YogenExchange,
  YogenExchange__factory,
  YogenFuture,
  YogenFuture__factory,
  DummyERC20,
  DummyERC20__factory,
} from '../typechain';

const { ethers } = hre;

async function signCreate(
  signer: Signer,
  verifyingContract: string,
  initiator: string,
  tokenIn: string,
  amountIn: BigNumber,
  tokenOut: string,
  amountOut: BigNumber,
  deliveryDate: string,
  expiryDate: string,
): Promise<string> {
  const sig = await signer._signTypedData({
    name: 'YogenExchange',
    version: '1',
    verifyingContract,
  },
  {
    Create: [
      {
        name: 'initiator',
        type: 'address',
      },
      {
        name: 'tokenIn',
        type: 'address',
      },
      {
        name: 'amountIn',
        type: 'uint256',
      },
      {
        name: 'tokenOut',
        type: 'address',
      },
      {
        name: 'amountOut',
        type: 'uint256',
      },
      {
        name: 'deliveryDate',
        type: 'uint256',
      },
      {
        name: 'expiryDate',
        type: 'uint256',
      },
    ],
  },
  {
    initiator,
    tokenIn,
    amountIn,
    tokenOut,
    amountOut,
    deliveryDate,
    expiryDate,
  });

  return sig;
}

describe('Pawnda', () => {
  let accounts: Signer[];

  let deployer: Signer;
  let alice: Signer;
  let bob: Signer;
  let collector: Signer;

  let yogenFuture: YogenFuture;
  let yogenExchange: YogenExchange;

  let tokenIn: DummyERC20;
  let tokenOut: DummyERC20;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    [deployer, alice, bob, collector] = accounts;

    yogenFuture = await new YogenFuture__factory(deployer).deploy();
    yogenExchange = await new YogenExchange__factory(deployer).deploy(
      yogenFuture.address,
      0,
      0,
      await collector.getAddress(),
    );

    tokenIn = await new DummyERC20__factory(deployer).deploy();
    tokenOut = await new DummyERC20__factory(deployer).deploy();
  });

  it('Should get the constants', async () => {
    expect(await yogenExchange.name()).to.equal('YogenExchange');
    expect(await yogenExchange.version()).to.equal('1');
  });

  it('Should create a future', async () => {
    const delay = 60;

    const deliveryDate = (Math.floor(Date.now() / 1000) + delay * 2).toString();
    const expiryDate = (Math.floor(Date.now() / 1000) + delay).toString();

    const aliceWallet = alice as Wallet;
    const sig = await signCreate(
      ethers.provider.getSigner(1),
      yogenExchange.address,
      await alice.getAddress(),
      tokenIn.address,
      utils.parseEther('1'),
      tokenOut.address,
      utils.parseEther('1'),
      deliveryDate,
      expiryDate,
    );

    await tokenIn.mint(await alice.getAddress(), utils.parseEther('1'));
    await tokenOut.mint(await bob.getAddress(), utils.parseEther('1'));

    await expect(
      yogenExchange.create(
        await alice.getAddress(),
        tokenIn.address,
        utils.parseEther('1'),
        tokenOut.address,
        utils.parseEther('1'),
        deliveryDate,
        expiryDate,
        sig,
      ),
    ).to.emit(yogenExchange, 'FutureCreated').withArgs(
      [
        '0',
        await alice.getAddress(),
        await bob.getAddress(),
      ],
    );
  });
});
