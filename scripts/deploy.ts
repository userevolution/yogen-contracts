import hre from 'hardhat';
import '@nomiclabs/hardhat-ethers';

const { ethers } = hre;

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contract(s) with account:', deployer.address);

  const YogenFuture = await ethers.getContractFactory('YogenFuture');
  const yogenFuture = await YogenFuture.deploy();

  console.log('YogenFuture deployed:', yogenFuture.address);

  const YogenExchange = await ethers.getContractFactory('YogenExchange');
  const yogenExchange = await YogenExchange.deploy(yogenFuture.address, 0, 0, deployer.address);
  await yogenFuture.updateYogenExchange(yogenExchange.address, true);

  console.log('YogenExchange deployed:', yogenExchange.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
