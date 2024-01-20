import React, { useState } from 'react';
import ContractAddressInput from './ContractAddressInput';
import TransactionIndexInput from './TransactionIndexInput';
import SignatoryAddressInput from './SignatoryAddressInput';
import AmountInput from './AmountInput';
import RecipientAddressInput from './RecipientAddressInput';
import SignatoryIndexInput from './SignatoryIndexInput';


const TransactionDropdown = () => {
  const [selectedMethod, setSelectedMethod] = useState('');
  const [additionalData, setAdditionalData] = useState('');

  const handleMethodChange = (event) => {
    setSelectedMethod(event.target.value);
  };

  const handleAdditionalDataChange = (event) => {
    setAdditionalData(event.target.value);
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    // Handle the selected method and additional data
    console.log('Selected Method:', selectedMethod);
    console.log('Additional Data:', additionalData);
    // You can perform actions based on the chosen method and additional data
  };

  return (
    <div>
      <h2>Select Transaction Method:</h2>
      <form onSubmit={handleSubmit}>
        <label htmlFor="transactionMethods">Choose a method:</label>
        <select
          id="transactionMethods"
          name="transactionMethods"
          onChange={handleMethodChange}
          value={selectedMethod}
        >
          <option value="">Select Transaction Method</option>
          <option value="selectContractAddress">Select Contract Address</option>
          <option value="viewStagedTransactions">View Staged Transactions</option>
          <option value="viewStagedSignatories">View Staged Signatories</option>
          <option value="viewContractGHOBalance">View Contract GHO Balance</option>
          <option value="approveAndDepositGHOTokens">Approve and Deposit GHO Tokens</option>
          <option value="submitTransaction">Submit Transaction</option>
          <option value="verifyAndExecuteTransaction">Verify and Execute Transaction</option>
          <option value="signTransaction">Sign Transaction</option>
          <option value="getTransactionHash">Get Transaction Hash</option>
          <option value="removeMyselfasSignatory">Remove Myself as Signatory</option>
          <option value="addSignatory">Add Signatory</option>
          <option value="revokeSignatureforTransaction">Revoke Signature for Transaction</option>
          <option value="revokeSignatureforSignatory">Revoke Signature for Signatory</option>
          {/* Add more options as needed */}
        </select>

        {/* Conditionally render additional input fields based on the selected method */}
        {selectedMethod === 'selectContractAddress' && (
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
        )}

        {selectedMethod === 'viewStagedTransactions' && (
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />

        )}

        {selectedMethod === 'viewStagedSignatories' && (
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />

        )} 

        {selectedMethod === 'viewContractGHOBalance' && (
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />

        )}

        {selectedMethod === 'approveAndDepositGHOTokens' && (
          <>
            <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
            <AmountInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          </>
        )}

        {selectedMethod === 'submitTransaction' && (
         <>
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          <AmountInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          <RecipientAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
         </>
        )}

        {selectedMethod === 'verifyAndExecuteTransaction' && (
          <>
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          <TransactionIndexInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          </>
        )}

        {selectedMethod === 'signTransaction' && (
          <>
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          <TransactionIndexInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          </>
        )}

        {selectedMethod === 'getTransactionHash' && (
          <>
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          <TransactionIndexInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          </>
        )}

        {selectedMethod === 'removeMyselfasSignatory' && (
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
        )}

        {selectedMethod === 'addSignatory' && (
          <>
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          <SignatoryAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          </>
        )}

        {selectedMethod === 'revokeSignatureforTransaction' && (
          <>
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          <TransactionIndexInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          </>
        )}

        {selectedMethod === 'revokeSignatureforSignatory' && (
          <>
          <ContractAddressInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          <SignatoryIndexInput additionalData={additionalData} handleAdditionalDataChange={handleAdditionalDataChange} />
          </>
        )}









        {/* Add more conditions for other methods as needed */}

        <br />

        <input type="submit" value="Submit" />
      </form>
    </div>
  );
};

export default TransactionDropdown;
