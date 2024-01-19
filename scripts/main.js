const { ethers } = require("hardhat");
const readlineSync = require('readline-sync');
const sdk = require("./ghoMultiSigSDK.js");

async function main() {
    const contractAddress = readlineSync.question('Enter contract address: ');
    const recipientAddress = readlineSync.question('Enter recipient address: ');
    const amountGhoInput = readlineSync.question('Enter amount of GHO tokens: ');
    const amountGho = ethers.parseUnits(amountGhoInput, 18);

    const signer = await sdk.getSigner();
    await sdk.approveGhoTokens(signer, "0xc4bF5CbDaBE595361438F8c6a187bDc330539c60", contractAddress, amountGho);
    await sdk.depositGhoTokens(signer, contractAddress, amountGho);
    await sdk.getMultisigGhoBalance(signer, "0xc4bF5CbDaBE595361438F8c6a187bDc330539c60", contractAddress);
    await sdk.submitTransaction(signer, contractAddress, recipientAddress, amountGho);

    // Assuming you want the last transaction
    const txIndex = 0; // Replace with actual index if needed
    await sdk.verifyAndExecuteTransaction(signer, contractAddress, txIndex);
}


// Create a menu with the following options:
/*
- Select contract address: this will allow the user to switch between active wallets
- View Staged Transactions: this will allow the user to view all staged transactions
- View Staged Signatories: this will allow the user to view all staged signatories
- View Contract GHO balance
- Deposit GHO tokens
- Submit Transaction
- Verify and Execute Transaction
- Remove myself as signatory
- Add signatory
- Revoke signature for transaction
- Revoke signature for signatory
*/

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
