/* eslint-env node, mocha */
/* eslint-disable camelcase */

import hre from 'hardhat';
import '@nomiclabs/hardhat-ethers';
import {
  Signer,
  utils,
} from 'ethers';
import { expect } from 'chai';

import {
  Pawnda,
  Pawnda__factory,
  DummyERC20,
  DummyERC20__factory,
  DummyERC721,
  DummyERC721__factory,
  DummyERC1155,
  DummyERC1155__factory,
  IERC721__factory,
  IERC1155__factory,
  IERC20__factory,
} from '../typechain';

import {
  increaseTime,
} from './utils';

const { ethers } = hre;

const cryptoKittiesAddress = '0x06012c8cf97bead5deae237070f9587f8e7a266d';
const axieInfinityAddress = '0xF5b0A3eFB8e8E4c201e2A935F110eAaF3FFEcb8d';
const cryptoVoxelsWearablesAddress = '0xa58b5224e2FD94020cb2837231B2B0E4247301A6';
const manaAddress = '0x0f5d2fb29fb7d3cfee444a200298f468908cc942';

describe('Pawnda', () => {
  let accounts: Signer[];
  let pawnda: Pawnda;
  let dummyERC20: DummyERC20;
  let dummyERC721: DummyERC721;
  let dummyERC1155: DummyERC1155;
  let deployer: Signer;
  let alice: Signer;
  let bob: Signer;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    [deployer, alice, bob] = accounts;

    dummyERC20 = await new DummyERC20__factory(deployer).deploy();
    dummyERC721 = await new DummyERC721__factory(deployer).deploy();
    dummyERC1155 = await new DummyERC1155__factory(deployer).deploy();
    pawnda = await new Pawnda__factory(deployer).deploy(0);
  });

  it('Should check the current fee', async () => {
    expect(await pawnda.fee()).to.equal(0);
  });
});
