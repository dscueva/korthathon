const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const ghoTokenAddress = '0xc4bF5CbDaBE595361438F8c6a187bDc330539c60'; // Replace with your GHO token address
  const requiredConfirmations = 1; // Or any number you prefer
  const initialSignatories = [deployer.address]; // Add initial signatories as needed

  // Deploy the contract
  const GhoMultisig = await ethers.getContractFactory("ghomultisig");
  const ghoMultisig = await GhoMultisig.deploy(ghoTokenAddress, initialSignatories, requiredConfirmations);

  console.log("GhoMultisig deployed to:", ghoMultisig.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

