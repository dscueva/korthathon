// main.js
const { ethers } = require("hardhat");
const sdk = require("./ghoMultiSigSDK.js");

async function main() {
    const contractAddress = "0x6f0f025f9a53f66825Ea96370C60077f8b869bBd";
    const ghoTokenAddress = "0xc4bF5CbDaBE595361438F8c6a187bDc330539c60";
    const recipientAddress = "0xc977Fdb84F4ed2425f6afA5f47bd686291615451";
    const amountGho = ethers.parseUnits("69", 18);

    const signer = await sdk.getSigner();
    await sdk.approveGhoTokens(signer, ghoTokenAddress, contractAddress, amountGho);
    await sdk.depositGhoTokens(signer, contractAddress, amountGho);
    await sdk.getMultisigGhoBalance(signer, ghoTokenAddress, contractAddress);
    await sdk.submitTransaction(signer, contractAddress, recipientAddress, amountGho);

    // Assuming you want the last transaction
    const txIndex = 0; // Replace with actual index if needed
    await sdk.verifyAndExecuteTransaction(signer, contractAddress, txIndex);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
