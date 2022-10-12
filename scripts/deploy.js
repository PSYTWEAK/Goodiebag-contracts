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
/*   const [owner, feeCollector, operator] = await ethers.getSigners();
  console.log(owner.address);
  const tx = await owner.sendTransaction({
    data: "0x5ae401dc0000000000000000000000000000000000000000000000000000000062ea9d4f00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e404e45aaf00000000000000000000000082af49447d8a07e3bd95bd0d56f35241523fbab1000000000000000000000000fa7f8980b0f1e64a2062791cc3b0871572f1f7f00000000000000000000000000000000000000000000000000000000000002710000000000000000000000000ee4076e241a03aa624a2049312c0ec3a25c69227000000000000000000000000000000000000000000000000000000e8d4a51000000000000000000000000000000000000000000000000000000088ba71541682000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
    to: "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
    value: ethers.utils.parseEther("0"),
    gasLimit: "0x989680", // Sends exactly 1.0 ether
  });
} */

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
