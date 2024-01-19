// multisigscript.js
require('dotenv').config();
const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0x6f0f025f9a53f66825Ea96370C60077f8b869bBd"; // Multisig Contract Address
    const ghoTokenAddress = "0xc4bF5CbDaBE595361438F8c6a187bDc330539c60"; // GHO Token Address
    const recipientAddress = "0xc977Fdb84F4ed2425f6afA5f47bd686291615451"; // Recipient Address
    const amountGho = ethers.parseUnits("69", 18); // 69 GHO Tokens

    // Get signer
    const [signer] = await ethers.getSigners();

    // Connect to GHO Token Contract
    const ghoTokenContract = await ethers.getContractAt("IERC20", ghoTokenAddress, signer);

    // Approve GHO Tokens
    console.log("Approving GHO tokens...");
    let tx = await ghoTokenContract.approve(contractAddress, amountGho);
    await tx.wait();
    console.log("GHO tokens approved.");

    // Connect to Multisig Contract
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);

    // Deposit GHO Tokens to Multisig
    console.log("Depositing GHO tokens to Multisig...");
    tx = await multisigContract.depositGHO(amountGho);
    await tx.wait();
    console.log("Deposited GHO tokens to Multisig.");

    // Print Multisig Contract's GHO Token Balance
    const contractGhoBalance = await ghoTokenContract.balanceOf(contractAddress);
    console.log(`Multisig Contract GHO Token Balance: ${ethers.formatUnits(contractGhoBalance, 18)} GHO`);

    // Submit Transaction
    console.log("Submitting transaction...");
    tx = await multisigContract.submitTransaction(recipientAddress, amountGho);
    await tx.wait();
    console.log("Transaction submitted.");

    // // Create and Sign Transaction Hash
    const txIndex = (await multisigContract.viewStagedTransactions()).length - 1;
    const txHash = await multisigContract.getTransactionHash(txIndex);
    // const ethSignedTxHash = ethers.hashMessage(txHash);
    const signature = await signer.signMessage(txHash);
    
    // Verify and Execute Transaction
    console.log("Verifying and executing transaction...");
    tx = await multisigContract.verifyTransaction(signer.address, txIndex, signature);
    await tx.wait();
    console.log("Transaction verified and executed.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
