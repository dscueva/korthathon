// WalletConnect.jsx

import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';

const WalletConnect = ({ onAddressChanged }) => {
  const [userAddress, setUserAddress] = useState('');

  useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', handleAccountsChanged);
    }
    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
      }
    };
  }, []);

  const handleAccountsChanged = (accounts) => {
    if (accounts.length === 0) {
      console.log('Please connect to MetaMask.');
    } else {
      setUserAddress(accounts[0]);
      onAddressChanged(accounts[0]);
    }
  };

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setUserAddress(accounts[0]);
        onAddressChanged(accounts[0]);
      } catch (error) {
        console.error(error);
      }
    } else {
      console.log('Please install MetaMask!');
    }
  };

  return (
    <div>
      <button onClick={connectWallet}>Connect Wallet</button>
      {userAddress && <p>Connected Address: {userAddress}</p>}
    </div>
  );
};

export default WalletConnect;
