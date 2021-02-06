import {
  HardhatUserConfig,
} from 'hardhat/config';
import '@nomiclabs/hardhat-waffle';
import * as dotenv from 'dotenv';
import 'hardhat-typechain';
import '@nomiclabs/hardhat-etherscan';

dotenv.config();

const {
  PRIVATE_KEY,
  ETHERSCAN_KEY,
  RINKEBY_ALCHEMY_KEY,
  MAINNET_ALCHEMY_KEY,
} = process.env;

const config: HardhatUserConfig = {
  solidity: '0.7.6',
  networks: {
    hardhat: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${MAINNET_ALCHEMY_KEY}`,
        blockNumber: 11414913,
      },
    },
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${RINKEBY_ALCHEMY_KEY}`,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_KEY,
  },
  mocha: {
    timeout: '30s',
  },
};

export default config;
