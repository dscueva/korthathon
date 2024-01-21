// App.js

import React, { useState } from 'react';
import WalletConnect from './components/WalletConnect.js';
import TransactionDropdown from './components/TransactionDropdown'; // Import your TransactionDropdown component

const App = () => {
  const [userAddress, setUserAddress] = useState('');
  const [approvalResult, setApprovalResult] = useState(null); // State to store approval result

  // Function to make API request for approving GHO tokens
  const approveGhoTokens = async () => {
    const ghoTokenAddress = '0xb9aaa8B7D238b4C28B77faA107F617F97Ca44e28'; // Replace with actual token address
    const contractAddress = '0x5ec21fbd4485cff62980e8d1809c52cc1be4290b'; // Replace with actual contract address
    const amountGhoInTokens = 10; // Replace with actual amount

    try {
      const response = await fetch('http://localhost:3001/scripts/approveGhoTokens', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ghoTokenAddress,
          contractAddress,
          amountGhoInTokens,
        }),
      });


      if (response.ok) {
        const result = await response.json();
        setApprovalResult(result.message);
      } else {
        console.error('Failed to approve GHO tokens:', response.statusText);
      }
    } catch (error) {
      console.error('Error approving GHO tokens:', error);
    }
  };

  return (
    <div>
      <h1>MultiKor</h1>
      <h2>GHO Multi-Signature Wallet</h2>
      <WalletConnect onAddressChanged={setUserAddress} />
      <TransactionDropdown />
      <button onClick={approveGhoTokens}>Approve GHO Tokens</button>
      {approvalResult && <p>{approvalResult}</p>}
    </div>
  );
};

export default App;
