const { ethers } = require("hardhat");
const readline = require("readline");
async function main() {
    // Connect to the deployed contract
    const Contract = await ethers.getContractFactory("ghomultisig");
    const contract = Contract.attach("0x62Cac812D7ac50eD3c71d9a9BD3821eeE2e97448");

    // Create a readline interface for user input
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    // Continuously repeat the menu
    while (true) {
        console.log("=== Contract CLI Menu ===");
        console.log("1. Call a contract function");
        console.log("2. Send a transaction to a contract function");
        console.log("3. Read contract state");
        console.log("4. Update contract state");
        console.log("5. Exit");

        // Prompt user for menu option
        const option = await prompt("Select an option: ");

        switch (option) {
            case "1":
                await callContractFunction(contract);
                break;
            case "2":
                await sendTransaction(contract);
                break;
            case "3":
                await readContractState(contract);
                break;
            case "4":
                await updateContractState(contract);
                break;
            case "5":
                rl.close();
                return;
            default:
                console.log("Invalid option. Please try again.");
        }
    }
}

async function callContractFunction(contract) {
    // Example: Call a contract function
    const result = await contract.someFunction();
    console.log("Result:", result);
}

async function sendTransaction(contract) {
    // Example: Send a transaction to a contract function
    const param1 = await prompt("Enter param1: ");
    const param2 = await prompt("Enter param2: ");

    const tx = await contract.someFunctionWithParams(param1, param2);
    await tx.wait();
    console.log("Transaction successful!");
}

async function readContractState(contract) {
    // Example: Read contract state
    const state = await contract.someStateVariable();
    console.log("State:", state);
}

async function updateContractState(contract) {
    // Example: Update contract state
    const newValue = await prompt("Enter new value: ");

    const updateTx = await contract.updateState(newValue);
    await updateTx.wait();
    console.log("State updated!");
}

function prompt(question) {
    return new Promise((resolve) => {
        rl.question(question, (answer) => {
            resolve(answer);
        });
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
