// contract_functions.js
const ethers = require("ethers");

async function balanceGHO(ghoMultisig, walletAddress) {
    const tokenBalance = await ghoMultisig.balanceGHO();
    const tokenDecimals = 18; // Replace with the actual decimal value of your token

    // Convert the token balance to a string and then parse it as a decimal
    const adjustedTokenBalance = parseFloat(tokenBalance.toString()) / 10 ** tokenDecimals;

    console.log(`Token balance of address ${walletAddress}: ${adjustedTokenBalance} GHO`);
}

async function balanceETH(ghoMultisig, walletAddress) {
    const tokenBalance = await ghoMultisig.balanceETH();
    const tokenDecimals = 18; // Replace with the actual decimal value of your token

    // Convert the token balance to a string and then parse it as a decimal
    const adjustedTokenBalance = parseFloat(tokenBalance.toString()) / 10 ** tokenDecimals;

    console.log(`Ether balance of address ${walletAddress}: ${adjustedTokenBalance} ETH`);
}

// Function to deposit GHO into contract
//async function depositGHO(ghoMultisig, walletAddress, amount) {
//    const deposit = await ghoMultisig.depositGHO(amount);
//    console.log(`Deposited ${amount} GHO to ${walletAddress}`);
//}

module.exports = {
    balanceGHO,
    balanceETH,
    //depositGHO
    
};
