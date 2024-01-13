## Notes about Building Applications with GHO video ##

# GHO

**Stablecoin with a Twist:**

- GHO is pegged to the US dollar, maintaining stability like other stablecoins. 
- It lives within the Aave protocol, leveraging its governance and minting/burning mechanisms.

**Dynamic Interest Rates:**

- GHO's interest rate fluctuates based on:
    - **Aave Utilization Rate:** Higher utilization (more borrowing) leads to higher interest rates, incentivizing lending and maintaining GHO's peg.
    - **Governance Parameters:** The Aave DAO sets the base rate and utilization rate sensitivity, fine-tuning GHO's interest dynamics.

**Collaterization and Peg Stability Facilitators:**

- GHO uses a unique "Facilitator" system for minting and managing its peg stability.
- Facilitators are smart contracts allowing various minting mechanisms, like:
    - **Over-collateralized Loans:** Deposit other Aave assets as collateral to mint GHO.
    - **Algorithmic Minting:** Utilize on-chain oracles and algorithms to adjust GHO supply based on market conditions and peg stability.
    - **Off-chain Collateral:** Explore mechanisms for using off-chain assets as collateral for GHO minting.

**GHO and Aave Intertwined:**

- Minting and borrowing GHO occur within Aave, using its infrastructure and collateral assets.
- Borrowed GHO incurs interest rates determined by Aave's utilization rate and governance parameters.

**GHO Applications: Beyond Payments:**

- GHO's potential extends beyond payments due to its stability and Aave integration:
    - **Payments:** Send and receive GHO across networks, facilitated by Aave's on-chain capabilities.
    - **Vaults:** Create smart contracts like ERC-4626 vaults to manage and earn on GHO holdings.
    - **Facilitator Integration:** Build custom facilitators for novel GHO use cases, like integration with other DeFi protocols or enabling off-chain collateralization.

