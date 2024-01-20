import React from 'react';

const SignatoryAddressInput = ({ additionalData, handleAdditionalDataChange }) => {
  return (
    <div>
      <label htmlFor="signatoryAddressInput">Signatory Address: </label>
      <input
        type="text"
        id="signatoryAddressInput"
        value={additionalData}
        onChange={handleAdditionalDataChange}
      />
    </div>
  );
};

export default SignatoryAddressInput;
