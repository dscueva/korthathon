import React from 'react';

const RecipientAddressInput = ({ additionalData, handleAdditionalDataChange }) => {
  return (
    <div>
      <label htmlFor="recipientAddressInput">Recipient Address: </label>
      <input
        type="text"
        id="recipientAddressInput"
        value={additionalData}
        onChange={handleAdditionalDataChange}
      />
    </div>
  );
};

export default RecipientAddressInput;