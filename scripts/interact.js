const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0x1CBC9bccc786845651b89d198127CBa181E61314"; // Updated contract address
    const walletAddress = "0x5bEb07c71Da8ceD22A392847E775a245c4F431de"; // Your wallet address
    const [signer] = await ethers.getSigners();

    const GhoMultisig = await ethers.getContractFactory("ghomultisig");
    const ghoMultisig = await GhoMultisig.attach(contractAddress);

    // Query the token balance of your wallet address
    const tokenBalance = await ghoMultisig.balanceGHO();
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
