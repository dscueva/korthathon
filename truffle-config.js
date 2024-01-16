require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = process.env.MNEMONIC;
const sepoliaRPC = process.env.SEPOLIA_RPC_URL;

module.exports = {
  networks: {
    sepolia: {
      provider: () => new HDWalletProvider(mnemonic, sepoliaRPC),
      network_id: 11155111,
      gas: 25000000, // Increased gas limit
      gasPrice: 20000000000, // Adjust gas price if necessary
      confirmations: 0,
      timeoutBlocks: 200,
      skipDryRun: true
    }
  },
  mocha: {
    // timeout: 100000
  },
  compilers: {
    solc: {
      version: "0.8.21",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  },
  db: {
    enabled: false,
    host: "127.0.0.1",
    adapter: {
      name: "indexeddb",
      settings: {
        directory: ".db"
      }
    }
  }
};
