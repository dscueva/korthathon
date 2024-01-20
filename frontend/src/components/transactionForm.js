// TransactionForm.jsx

import React, { useState } from 'react';

const TransactionForm = () => {
  const [contractAddress, setContractAddress] = useState('');
  const [recipientAddress, setRecipientAddress] = useState('');
  const [tokenAmount, setTokenAmount] = useState('');

  const submitTransaction = () => {
    // Perform your transaction submission logic here
    // You can use contractAddress, recipientAddress, and tokenAmount state values

    // For demonstration purposes, let's log the values to the console
    console.log('Contract Address:', contractAddress);
    console.log('Recipient Address:', recipientAddress);
    console.log('Token Amount:', tokenAmount);

    // You can replace the above console.log statements with your actual transaction logic
  };

  return (
    <div>
      <h1>Transaction Form</h1>
      <form>
        <label htmlFor="contractAddress">Contract Address:</label>
        <input
          type="text"
          id="contractAddress"
          value={contractAddress}
          onChange={(e) => setContractAddress(e.target.value)}
          required
        />

        <label htmlFor="recipientAddress">Recipient Address:</label>
        <input
          type="text"
          id="recipientAddress"
          value={recipientAddress}
          onChange={(e) => setRecipientAddress(e.target.value)}
          required
        />

        <label htmlFor="tokenAmount">Token Amount:</label>
        <input
          type="number"
          id="tokenAmount"
          value={tokenAmount}
          onChange={(e) => setTokenAmount(e.target.value)}
          required
        />

        <button type="button" onClick={submitTransaction}>
          Submit Transaction
        </button>
      </form>
    </div>
  );
};

export default TransactionForm;
