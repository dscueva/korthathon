// ghoMultisigSDK.js
const { ethers } = require("hardhat");

async function getSigner() {
    const [signer] = await ethers.getSigners();
    return signer;
}

async function approveGhoTokens(signer, ghoTokenAddress, contractAddress, amountGho) {
    const ghoTokenContract = await ethers.getContractAt("IERC20", ghoTokenAddress, signer);
    console.log("Approving GHO tokens...");
    let tx = await ghoTokenContract.approve(contractAddress, amountGho);
    await tx.wait();
    console.log("GHO tokens approved.");
}

async function depositGhoTokens(signer, contractAddress, amountGho) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    console.log("Depositing GHO tokens to Multisig...");
    let tx = await multisigContract.depositGHO(amountGho);
    await tx.wait();
    console.log("Deposited GHO tokens to Multisig.");
}

async function submitTransaction(signer, contractAddress, recipientAddress, amountGho) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    console.log("Submitting transaction...");
    let tx = await multisigContract.submitTransaction(recipientAddress, amountGho);
    await tx.wait();
    console.log("Transaction submitted.");
}

async function verifyAndExecuteTransaction(signer, contractAddress, txIndex) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    const txHash = await multisigContract.getTransactionHash(txIndex);
    const signature = await signer.signMessage(txHash);
    console.log("Verifying and executing transaction...");
    let tx = await multisigContract.verifyTransaction(signer.address, txIndex, signature);
    await tx.wait();
    console.log("Transaction verified and executed.");
}

async function getMultisigGhoBalance(signer, ghoTokenAddress, contractAddress) {
    const ghoTokenContract = await ethers.getContractAt("IERC20", ghoTokenAddress, signer);
    const balance = await ghoTokenContract.balanceOf(contractAddress);
    console.log(`Multisig Contract GHO Token Balance: ${ethers.formatUnits(balance, 18)} GHO`);
    return balance;
}

module.exports = {
    getSigner,
    approveGhoTokens,
    depositGhoTokens,
    submitTransaction,
    verifyAndExecuteTransaction,
    getMultisigGhoBalance
};
