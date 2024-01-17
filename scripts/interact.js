const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0x162B8271d22a75Ef7564aB7869E35b29789BB2A3"; // Updated contract address
    const walletAddress = "0x5bEb07c71Da8ceD22A392847E775a245c4F431de"; // Your wallet address
    const [signer] = await ethers.getSigners();

    const GhoMultisig = await ethers.getContractFactory("ghomultisig");
    const ghoMultisig = await GhoMultisig.attach(contractAddress);

    // Query the token balance of your wallet address
    const tokenBalance = await ghoMultisig.getTokenBalance(walletAddress);
    const tokenDecimals = 18; // Replace with the actual decimal value of your token

    // Convert the token balance to a string and then parse it as a decimal
    const adjustedTokenBalance = parseFloat(tokenBalance.toString()) / 10 ** tokenDecimals;

    console.log(`Token balance of address ${walletAddress}: ${adjustedTokenBalance} GHO`);

    // Continue with other operations if needed
    // ...
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
