const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const requiredConfirmations = 1; // Or any number you prefer
  const initialSignatories = [deployer.address]; // Add initial signatories as needed

  // Deploy the contract
  const GhoMultisig = await ethers.getContractFactory("ghomultisig");
  const ghoMultisig = await GhoMultisig.deploy(initialSignatories, requiredConfirmations);

  console.log("GhoMultisig deployed to:", ghoMultisig.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

