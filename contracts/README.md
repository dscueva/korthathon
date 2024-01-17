# GHO Multisig Contract

This contract, named `ghomultisig.sol`, is a multisignature wallet designed specifically for the GHO token.

## Overview

The GHO Multi-Sig Contract allows multiple parties to jointly manage and control the GHO tokens held within the wallet. It provides an extra layer of security by requiring multiple signatures to authorize any token transfers or other operations.

## Features

- Multisignature functionality for managing GHO tokens
- Secure and decentralized control over token transfers
- Flexible configuration for the number of required signatures
- Support for ERC20 token standards

## Getting Started

To use the GHO Multi-Sig Contract, follow these steps:

1. Clone this repository to your local machine.
2. Install the necessary dependencies.
3. Deploy the `ghomultisig.sol` contract to the Ethereum network.
4. Configure the required number of signatures for each operation.
5. Start managing your GHO tokens using the multisignature wallet.

## Usage

The GHO Multi-Sig Contract provides the following functions:

- `constructor(_signatories, _requiredSignatures)`: Create a new multisig wallet.
    - `_signatories`: Array of addresses of the signatories for the multisig wallet.
    - `_requiredSignatures`: The number of signatures required to authorize a transaction.

- `depositGHO(_amount)`: Deposit GHO tokens into the multisig wallet.
    - `_amount`: The amount of GHO tokens to deposit.

- `viewStagedTransactions()` : View all staged transactions. Requires caller to be a wallet signatory.

- `viewStagedSignatories()`: View all signatories for a staged transaction. Requires caller to be a wallet signatory.

- `balanceGHO()`: View the GHO token balance of the wallet.

- `balanceETH()`: View the ETH balance of the wallet.

- `submitTransaction(_to, _amount)`: Submit a transaction for the multisig wallet. Will automatically sign as the caller, and execute if only 1 signature is required. Requires caller to be a wallet signatory. 
    - `_to`: The address to send the transaction to.
    - `_amount`: The amount of GHO to send in the transaction.

- `addSignatory(_signatory)`: Add a signatory to the multisig wallet. Requires caller to be a wallet signatory.
    - `_signatory`: The address of the signatory to add.

- `removeSignatory()`: Remove yourself as signatory from the multisig wallet. Requires caller to be a wallet signatory.

- `verifyTransaction(_sender, _transactionIndex, _sig)`: Verify a transaction for the multisig wallet. Requires caller to be a wallet signatory.
    - `_sender`: The address of the signer of the transaction.
    - `_transactionIndex`: The index of the transaction to verify.
    - `_signature`: The signature of the sender.

- `verifySignatory(_sender, _signatoryIndex, _sig)`: Verify a signatory for the multisig wallet. Requires caller to be a wallet signatory.
    - `_sender`: The address of the signer of the transaction.
    - `_signatoryIndex`: The index of the signatory to verify.
    - `_signature`: The signature of the sender.

- `revokeTransactionSignature(_transactionIndex)`: Revoke a transaction signature for the multisig wallet. Requires caller to be a wallet signatory.
    - `_transactionIndex`: The index of the transaction to revoke the signature of.

- `revokeSignatorySignature(_signatoryIndex)`: Revoke a signatory signature for the multisig wallet. Requires caller to be a wallet signatory.
    - `_signatoryIndex`: The index of the signatory to revoke the signature of.

- `getTransactionHash(_transactionIndex)`: Get the hash of a transaction, used to sign off on it. Requires caller to be a wallet signatory.
    - `_transactionIndex`: The index of the transaction to get the hash of.

- `getSignatoryHash(_signatoryIndex)`: Get the hash of a signatory, used to sign off on it. Requires caller to be a wallet signatory.
    - `_signatoryIndex`: The index of the signatory to get the hash of.


## Signing a Transaction or Signatory Confirmation

To sign a transaction or signatory confirmation, you must call the `getTransactionHash` or `getSignatoryHash` functions, and sign the returned hash using your wallet's private key. The signature must then be passed to the `verifyTransaction` or `verifySignatory` functions, along with the index of the transaction/signatory and the address of the signer. After this is completed, the transaction/signatory will be verified and the operation will be executed if the required number of signatures has been reached.

