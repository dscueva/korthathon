// main.js
const { ethers } = require("hardhat");
const ContractFunc = require('./contract_functions.js'); // Use require

async function main() {
    const contractAddress = "0x1CBC9bccc786845651b89d198127CBa181E61314"; // Updated contract address
    const walletAddress = "0xb9aaa8B7D238b4C28B77faA107F617F97Ca44e28"; // Your wallet address
    const [signer] = await ethers.getSigners();

    const GhoMultisig = await ethers.getContractFactory("ghomultisig");
    const ghoMultisig = await GhoMultisig.attach(contractAddress);

    // Call functions here
    await ContractFunc.balanceGHO(ghoMultisig, walletAddress);
    await ContractFunc.balanceETH(ghoMultisig, walletAddress);
   // await ContractFunc.depositGHO(ghoMultisig, walletAddress, 8000000000000000000);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
