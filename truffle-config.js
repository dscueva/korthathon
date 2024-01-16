require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = process.env.MNEMONIC;
const sepoliaRPC = process.env.SEPOLIA_RPC_URL;

module.exports = {
  networks: {
    sepolia: {
      provider: () => new HDWalletProvider(mnemonic, "https://eth-sepolia.g.alchemy.com/v2/kg1W_wKisQhhOrUVa6878Mv51A749CiJ"),
      network_id: 11155111,
      confirmations: 0,
      timeoutBlocks: 200,
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
