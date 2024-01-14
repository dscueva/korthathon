# ETHGlobal Hackathon
# GHO Token Payment Simplifaction Toolkit
## Project Overview
This project aims to simplify the payment experience using GHO tokens, an ERC-20 token with signature-based approvals. The toolkit leverages on-chain facilitators such as the Aave Ethereum Market and Flashmint facilitators to enhance liquidity access. The goal is to provide an easy-to-use application or SDK that abstracts complex processes, making GHO more accessible and user-friendly.

## Features
* Signature Method Implementation: Utilizing permit and creditDelegationWithSignature for streamlined approvals and credit delegation.
* Account Abstraction: Incorporation of alternative signing schemes like multi-signature and passkey, along with smart contract wallet support (EIP 4337).

## Usage
Use the SDK functions to integrate GHO payment functionalities into your application.
Examples and documentation are provided for standard operations like token transfer, credit delegation, and multi-signature transactions.

## Next Steps
* Choose language for SDK (Rust v Go)
* Write smart contracts (multi-sig support)
* Develop functionality in the SDK to provide a standardized way of implementing multi-sig functionality. An SDK dedicated to multisig can incorporate best practices and security measures, making it safer to execute transactions, especially those involving significant value or critical operations.


