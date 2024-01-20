import React from 'react';

const SignatoryIndexInput = ({ additionalData, handleAdditionalDataChange }) => {
  return (
    <div>
      <label htmlFor="signatoryIndexInput">Signatory Index: </label>
      <input
        type="text"
        id="signatoryIndexInput"
        value={additionalData}
        onChange={handleAdditionalDataChange}
      />
    </div>
  );
};

export default SignatoryIndexInput;
