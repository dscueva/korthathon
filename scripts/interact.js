const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0xcFa550545c042b83Bd7eF29273b64E8A265af93a"; // Replace with your contract's address
    const [signer] = await ethers.getSigners(); // Get the signer
    
    // Connect to the deployed contract
    const GhoMultisig = await ethers.getContractFactory("ghomultisig");
    const ghoMultisig = GhoMultisig.attach(contractAddress);
  
    // Now you can call the contract's functions, for example:
    // Check balance
    const balance = await ghoMultisig.balanceGHO();
    console.log("Contract balance:", balance.toString());
  
    // Submit a transaction
    // Replace '_to' and '_amount' with appropriate values
    const tx = await ghoMultisig.submitTransaction("0xAddress", ethers.utils.parseEther("1.0"));
    await tx.wait();
  
    // Add other function calls as needed
  }
  