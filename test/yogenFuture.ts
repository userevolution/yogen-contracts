/* eslint-env node, mocha */
/* eslint-disable camelcase */

import hre from 'hardhat';
import '@nomiclabs/hardhat-ethers';
import {
  Signer,
} from 'ethers';
import { expect } from 'chai';

import {
  YogenFuture,
  YogenFuture__factory,
} from '../typechain';

const { ethers } = hre;

describe('Pawnda', () => {
  let accounts: Signer[];
  let yogenFuture: YogenFuture;
  let deployer: Signer;
  let alice: Signer;
  let bob: Signer;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    [deployer, alice, bob] = accounts;

    yogenFuture = await new YogenFuture__factory(deployer).deploy();
  });

  it('Should return the name', async () => {
    expect(await yogenFuture.name()).to.equal('YogenFuture');
  });

  it('Should return the symbol', async () => {
    expect(await yogenFuture.symbol()).to.equal('YOGNF');
  });

  it('Should not mint', async () => {
    await expect(yogenFuture.mint(await alice.getAddress(), 0, true)).to.revertedWith('NOT_YOGEN_EXCHANGE');
  });
});
