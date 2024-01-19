// interact.js
const ContractFunc = require('./contract_functions.js');
const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0xC3d2F35230364f1B8631543B892b29253F5C09B0";
    const walletAddress = "";
    const privateKey = ""; // Replace with your actual private key

    // Create a wallet instance using the private key
    const walletWithProvider = new ethers.Wallet(privateKey, ethers.provider);

    const GhoMultisig = await ethers.getContractFactory("ghomultisig");
    const ghoMultisig = await GhoMultisig.attach(contractAddress).connect(walletWithProvider);

    // Call other functions or tasks if needed
    await ContractFunc.balanceGHO(ghoMultisig, walletAddress);
    await ContractFunc.balanceETH(ghoMultisig, walletAddress);

    // Call the modified submitTransaction function with walletWithProvider
    await ContractFunc.submitTransaction(ghoMultisig, walletAddress, 1, walletWithProvider);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
