// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  const [owner, feeCollector, operator] = await ethers.getSigners();

  const GoodieBag = await hre.ethers.getContractFactory("GoodieBag");
  goodieBag = await GoodieBag.deploy();
  await goodieBag.deployed();

  console.log("GoodieBag deployed to:", goodieBag.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1
});
