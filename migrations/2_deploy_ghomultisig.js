const GhoMultisig = artifacts.require("ghomultisig");

module.exports = function (deployer, network, accounts) {
    const ghoTokenAddress = '0xc4bF5CbDaBE595361438F8c6a187bDc330539c60'; // GHO Token Address
    const requiredConfirmations = 0; // Or any number you prefer

    // Example signatory addresses - replace with actual signatory addresses
    const signatories = [
        '0x5bEb07c71Da8ceD22A392847E775a245c4F431de', // Your wallet address
        accounts[1], // Using second account from Truffle's provided accounts
        accounts[2], // Using third account from Truffle's provided accounts
    ];

    deployer.deploy(GhoMultisig, ghoTokenAddress, signatories, requiredConfirmations);
};
