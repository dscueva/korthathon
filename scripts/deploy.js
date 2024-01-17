const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Update the contract name and constructor arguments
  const GhoMultisig = await ethers.getContractFactory("ghomultisig");
  const ghoTokenAddress = '0xc4bF5CbDaBE595361438F8c6a187bDc330539c60'; // GHO Token Address
  const requiredConfirmations = 1; // Or any number you prefer

  // Example signatory addresses - replace with actual signatory addresses
  const signatories = [
    deployer.address, // Deployer's address
    // Add other signatories if needed
  ];

  // Deploy the contract directly from the factory
  const ghoMultisig = await GhoMultisig.deploy(ghoTokenAddress, signatories, requiredConfirmations);

  // The contract is deployed, no need for additional steps

  console.log("GhoMultisig deployed to:", ghoMultisig.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
