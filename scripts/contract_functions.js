// contract_functions.js
const ethers = require("ethers");

async function balanceGHO(ghoMultisig, walletAddress) {
    const tokenBalance = await ghoMultisig.balanceGHO();
    const tokenDecimals = 18; // Replace with the actual decimal value of your token

    // Convert the token balance to a string and then parse it as a decimal
    const adjustedTokenBalance = parseFloat(tokenBalance.toString()) / 10 ** tokenDecimals;

    console.log(`Token balance of Contract: ${adjustedTokenBalance} GHO`);
}

async function balanceETH(ghoMultisig, walletAddress) {
    const tokenBalance = await ghoMultisig.balanceETH();
    const tokenDecimals = 18; // Replace with the actual decimal value of your token

    // Convert the token balance to a string and then parse it as a decimal
    const adjustedTokenBalance = parseFloat(tokenBalance.toString()) / 10 ** tokenDecimals;

    console.log(`Ether balance of Contract: ${adjustedTokenBalance} ETH`);
}

// Add a parameter for the wallet instance
async function submitTransaction(ghoMultisig, destinationAddress, amount, walletWithProvider) {
    try {
        // Create a transaction
        const unsignedTx = await ghoMultisig.populateTransaction.submitTransaction(destinationAddress, amount);

        // Sign the transaction with the existing wallet
        const signedTx = await walletWithProvider.signTransaction(unsignedTx);

        // Send the signed transaction
        const txResponse = await walletWithProvider.provider.sendTransaction(signedTx);

        console.log(`Transaction signed and sent: ${txResponse.hash}`);
        // Wait for the transaction to be mined
        await txResponse.wait(1);
        console.log(
            `Transaction has been mined at block number: ${txResponse.blockNumber}, transaction hash: ${txResponse.hash}`
        );
    } catch (error) {
        console.error("Error in submitTransaction:", error.message);
    }
}




module.exports = {
    balanceGHO,
    balanceETH,
    submitTransaction
    
};
