// App.js

import React, { useState } from 'react';
import TransactionForm from './components/transactionForm.js';
import WalletConnect from './components/WalletConnect.js';
import TransactionDropdown from './components/TransactionDropdown'; // Import your TransactionDropdown component

const App = () => {
  const [userAddress, setUserAddress] = useState('');

  return (
    <div>
      <h1>MultiKor</h1>
      <h2>GHO Multi-Signature Wallet</h2>
      <WalletConnect onAddressChanged={setUserAddress} />
      <TransactionDropdown /> {TransactionDropdown}
      
    </div>
  );
};

export default App;
