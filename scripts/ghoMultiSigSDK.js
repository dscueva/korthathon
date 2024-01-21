// ghoMultisigSDK.js
// backend/server.js
const express = require('express');
const { ethers } = require('hardhat');
const cors = require('cors');


const app = express();
const port = process.env.PORT || 3001;

// Middleware to parse JSON requests
app.use(express.json());

// Enable CORS
app.use(cors());

// Example API route for approving GHO tokens
app.post('/scripts/approveGhoTokens', async (req, res) => {
  try {
    const { ghoTokenAddress, contractAddress, amountGhoInTokens } = req.body;
    const [signer] = await ethers.getSigners();


    // Call your approveGhoTokens function
    await approveGhoTokens(signer, ghoTokenAddress, contractAddress, amountGhoInTokens);

    res.status(200).json({ message: 'GHO tokens approved successfully' });
  } catch (error) {
    console.error('Error approving GHO tokens:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Other API routes for additional functions

// Start the Express server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
async function getSigner() {
    const [signer] = await ethers.getSigners();
    return signer;
}

async function approveGhoTokens(signer, ghoTokenAddress, contractAddress, amountGhoInTokens) {
    const amountGho = ethers.parseUnits(amountGhoInTokens.toString(), 18);
    const ghoTokenContract = await ethers.getContractAt("IERC20", ghoTokenAddress, signer);

    try {
        console.log("Approving GHO tokens...");
        let tx = await ghoTokenContract.approve(contractAddress, amountGho);
        await tx.wait();
        console.log("GHO tokens approved.");
    } catch (error) {
        console.error("Failed to approve GHO tokens:", error);
    }
}

async function depositGhoTokens(signer, contractAddress, amountGhoInTokens) {
    const amountGho = ethers.parseUnits(amountGhoInTokens.toString(), 18);
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);

    try {
        console.log(`Depositing ${amountGhoInTokens} GHO tokens to Multisig...`);
        let tx = await multisigContract.depositGHO(amountGho);
        await tx.wait();
        console.log(`Deposited ${amountGhoInTokens} GHO tokens to Multisig.`);
    } catch (error) {
        console.error("Failed to deposit GHO tokens:", error);
    }
}

async function submitTransaction(signer, contractAddress, recipientAddress, amountGhoInTokens) {
    const amountGho = ethers.parseUnits(amountGhoInTokens.toString(), 18); // Converts token amount to wei
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    console.log(`Submitting transaction of ${amountGhoInTokens} GHO tokens...`);
    let tx = await multisigContract.submitTransaction(recipientAddress, amountGho);
    await tx.wait();
    console.log(`Transaction of ${amountGhoInTokens} GHO tokens submitted.`);
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
async function viewStagedTransactions(signer, contractAddress) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    const transactions = await multisigContract.viewStagedTransactions();
    console.log("Staged Transactions: ", transactions);
    return transactions;
}

async function viewStagedSignatories(signer, contractAddress) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    const signatories = await multisigContract.viewStagedSignatories();
    console.log("Staged Signatories: ", signatories);
    return signatories;
}

async function balanceETH(signer, contractAddress) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    const balance = await multisigContract.balanceETH();
    console.log(`Multisig Contract ETH Balance: ${ethers.utils.formatEther(balance)} ETH`);
    return balance;
}

async function addSignatory(signer, contractAddress, newSignatoryAddress) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    console.log("Adding new signatory...");
    let tx = await multisigContract.addSignatory(newSignatoryAddress);
    await tx.wait();
    console.log("New signatory added.");
}

async function revokeTransactionSignature(signer, contractAddress, txIndex) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    console.log("Revoking signature for transaction...");
    let tx = await multisigContract.revokeTransactionSignature(txIndex);
    await tx.wait();
    console.log("Signature revoked for transaction.");
}

async function revokeSignatorySignature(signer, contractAddress, sigIndex) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    console.log("Revoking signature for signatory...");
    let tx = await multisigContract.revokeSignatorySignature(sigIndex);
    await tx.wait();
    console.log("Signature revoked for signatory.");
}

async function removeSignatory(signer, contractAddress) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    console.log("Removing self as signatory...");
    let tx = await multisigContract.removeSignatory();
    await tx.wait();
    console.log("Removed self as signatory.");
}

async function getTransactionHash(signer, contractAddress, txIndex) {
    const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
    try {
        const txHash = await multisigContract.getTransactionHash(txIndex);
        console.log(`Transaction Hash for index ${txIndex}: ${txHash}`);
        return txHash;
    } catch (error) {
        console.error(`Failed to get transaction hash for index ${txIndex}:`, error);
    }
}

async function signTransaction(signer, contractAddress, txIndex) {
    try {
        const multisigContract = await ethers.getContractAt("ghomultisig", contractAddress, signer);
        const txHash = await multisigContract.getTransactionHash(txIndex);

        const signature = await signer.signMessage(txHash);

        console.log(`Signed transaction at index ${txIndex}: ${signature}`);
    } catch (error) {
        console.error(`Failed to sign transaction at index ${txIndex}:`, error);
    }
}

module.exports = {
    getSigner,
    approveGhoTokens,
    depositGhoTokens,
    submitTransaction,
    verifyAndExecuteTransaction,
    getMultisigGhoBalance,
    viewStagedTransactions,
    viewStagedSignatories,
    balanceETH,
    addSignatory,
    revokeTransactionSignature,
    revokeSignatorySignature,
    removeSignatory,
    signTransaction,
    getTransactionHash
};