declare namespace NodeJS {
  export interface ProcessEnv {
    PRIVATE_KEY: string;
    ETHERSCAN_KEY: string;
    RINKEBY_ALCHEMY_KEY: string;
    MAINNET_ALCHEMY_KEY: string;
  }
}
