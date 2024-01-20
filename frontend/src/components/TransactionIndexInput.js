import React from 'react';

const TransactionIndexInput = ({ additionalData, handleAdditionalDataChange }) => {
  return (
    <div>
      <label htmlFor="transactionIndexInput">Transaction Index: </label>
      <input
        type="text"
        id="transactionIndexInput"
        value={additionalData}
        onChange={handleAdditionalDataChange}
      />
    </div>
  );
};

export default TransactionIndexInput;
