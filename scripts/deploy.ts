import hre from 'hardhat';
import '@nomiclabs/hardhat-ethers';

import deploymentArguments from '../deploymentArguments';

const { ethers } = hre;

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contract(s) with account:', deployer.address);

  const Nucter = await ethers.getContractFactory('Nucter');
  const nucter = await Nucter.deploy(...deploymentArguments);

  console.log('Nucter deployed:', nucter.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
