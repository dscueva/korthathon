import React from 'react';

const ContractAddressInput = ({ additionalData, handleAdditionalDataChange }) => {
  return (
    <div>
      <label htmlFor="contractAddress">Contract Address: </label>
      <input
        type="text"
        id="contractAddress"
        value={additionalData}
        onChange={handleAdditionalDataChange}
      />
    </div>
  );
};

export default ContractAddressInput;
