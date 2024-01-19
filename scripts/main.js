const { ethers } = require("hardhat");
const readlineSync = require('readline-sync');
const sdk = require("./ghoMultiSigSDK.js");

async function main() {
    let contractAddress = '';
    const signer = await sdk.getSigner();
    const ghoTokenAddress = "0xc4bF5CbDaBE595361438F8c6a187bDc330539c60"; // GHO Token Address

    const menu = `
    1. Select Contract Address
    2. View Staged Transactions
    3. View Staged Signatories
    4. View Contract GHO Balance
    5. Approve and Deposit GHO Tokens
    6. Submit Transaction
    7. Verify and Execute Transaction
    8. Sign Transaction
    9. Get Transaction Hash
    10. Remove Myself as Signatory
    11. Add Signatory
    12. Revoke Signature for Transaction
    13. Revoke Signature for Signatory
    14. Exit
    `;

    while (true) {
        console.log(menu);
        const choice = readlineSync.question('Enter your choice: ');

        switch (choice) {
            case '1':
                contractAddress = readlineSync.question('Enter contract address: ');
                break;
            case '2':
                await sdk.viewStagedTransactions(signer, contractAddress);
                break;
            case '3':
                await sdk.viewStagedSignatories(signer, contractAddress);
                break;
            case '4':
                await sdk.getMultisigGhoBalance(signer, ghoTokenAddress, contractAddress);
                break;
            case '5':
                const depositAmount = readlineSync.question('Enter amount of GHO tokens to deposit: ');
                await sdk.approveGhoTokens(signer, ghoTokenAddress, contractAddress, depositAmount);
                await sdk.depositGhoTokens(signer, contractAddress, depositAmount);
                break;
            case '6':
                const recipientAddress = readlineSync.question('Enter recipient address: ');
                const submitAmountInput = readlineSync.question('Enter amount of GHO tokens: ');
                await sdk.approveGhoTokens(signer, ghoTokenAddress, contractAddress, submitAmountInput);
                await sdk.submitTransaction(signer, contractAddress, recipientAddress, submitAmountInput);
                break;
            case '7':
                const txIndex = readlineSync.question('Enter transaction index: ');
                await sdk.verifyAndExecuteTransaction(signer, contractAddress, parseInt(txIndex, 10));
                break;
            case '8':
                const txIndexToSign = readlineSync.question('Enter transaction index to sign: ');
                await sdk.signTransaction(signer, contractAddress, parseInt(txIndexToSign, 10));
                break;
            case '9':
                const txIndexToGetHash = readlineSync.question('Enter transaction index to get hash: ');
                await sdk.getTransactionHash(signer, contractAddress, parseInt(txIndexToGetHash, 10));
                break;
            case '10':
                await sdk.removeSignatory(signer, contractAddress);
                break;
            case '11':
                const newSignatoryAddress = readlineSync.question('Enter new signatory address: ');
                await sdk.addSignatory(signer, contractAddress, newSignatoryAddress);
                break;
            case '12':
                const revokeTxIndex = readlineSync.question('Enter transaction index to revoke: ');
                await sdk.revokeTransactionSignature(signer, contractAddress, parseInt(revokeTxIndex, 10));
                break;
            case '13':
                const revokeSigIndex = readlineSync.question('Enter signatory index to revoke: ');
                await sdk.revokeSignatorySignature(signer, contractAddress, parseInt(revokeSigIndex, 10));
                break;
            case '14':
                console.log('Exiting...');
                return;
            default:
                console.log('Invalid choice. Please try again.');
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
