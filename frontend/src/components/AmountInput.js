import React from 'react';

const AmountInput = ({ additionalData, handleAdditionalDataChange }) => {
  return (
    <div>
      <label htmlFor="amountInput">Token Amount: </label>
      <input
        type="text"
        id="amountInput"
        value={additionalData}
        onChange={handleAdditionalDataChange}
      />
    </div>
  );
};

export default AmountInput;
