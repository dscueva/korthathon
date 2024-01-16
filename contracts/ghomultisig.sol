// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IGHO {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract ghomultisig {
    IGHO public ghoToken;
    address[] public signatories;
    mapping(address => bool) public isSignatory;
    uint public requiredConfirmations;

    struct Transaction {
        address to;
        uint256 amount;
        bool executed;
        mapping(address => bool) confirmations;
        uint confirmationsCount;
    }

    struct NewSignatory {
        address sigAddress;
        bool confirmed;
        mapping(address => bool) confirmations;
        uint confirmationsCount;
    }

    Transaction[] public transactions;
    
    NewSignatory[] public newSignatories;

    modifier onlySignatory() {
        require(isSignatory[msg.sender], "Not a signatory");
        _;
    }

    constructor(address _ghoTokenAddress, address[] memory _signatories, uint _requiredConfirmations) {
        ghoToken = IGHO(_ghoTokenAddress);
        require(_signatories.length >= _requiredConfirmations, "Not enough signatories");
        for (uint i = 0; i < _signatories.length; i++) {
            address signatory = _signatories[i];
            require(signatory != address(0), "Invalid signatory");
            require(!isSignatory[signatory], "Signatory not unique");

            isSignatory[signatory] = true;
            signatories.push(signatory);
        }
        requiredConfirmations = _requiredConfirmations;
    }

    function submitTransaction(address _to, uint256 _amount) public onlySignatory {
        uint txIndex = transactions.length;
        transactions.push();
        Transaction storage newTx = transactions[txIndex];
        newTx.to = _to;
        newTx.amount = _amount;

        emit SubmitTransaction(msg.sender, txIndex, _to, _amount);
    }

    function confirmTransaction(uint _txIndex) public onlySignatory {
        Transaction storage transaction = transactions[_txIndex];
        require(!transaction.executed, "Transaction already executed");
        require(!transaction.confirmations[msg.sender], "Transaction already confirmed");

        transaction.confirmations[msg.sender] = true;
        transaction.confirmationsCount += 1;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex) public onlySignatory {
        require(_txIndex < transactions.length);
        Transaction storage transaction = transactions[_txIndex];
        require(!transaction.executed, "Transaction already executed");
        require(transaction.confirmationsCount >= requiredConfirmations, "Insufficient confirmations");

        require(ghoToken.transfer(transaction.to, transaction.amount), "Transfer failed");
        transaction.executed = true;

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    // Add a new signatory to be a member of the wallet, and automatically sign off for confirmation as initiator
    function addSignatory(address _addedSignatory) public onlySignatory {
        require(!isSignatory[_addedSignatory], "Address is already a signatory");
        require(_addedSignatory != address(0), "Invalid signatory");

        if(signatories.length == 1){    //If there is only one wallet user, automatically add the new address as a signatory and increase required confirmations by 1
            isSignatory[_addedSignatory] = true;
            signatories.push(_addedSignatory);
            requiredConfirmations += 1;
            emit AddSignatory(_addedSignatory);
            emit IncreaseMinimumConfirmations(msg.sender, requiredConfirmations);
        }else{
            uint sigIndex = newSignatories.length;
            newSignatories.push();
            NewSignatory storage newSig = newSignatories[sigIndex];
            newSig.sigAddress = _addedSignatory;
            newSig.confirmations[msg.sender] = true;
            newSig.confirmationsCount = 1;
            newSig.confirmed = false;

            emit NewSignatoryInQueue(msg.sender, _addedSignatory, sigIndex);
        }
    }

    //New signatories require 100% of current signatories to be confirmed
    function confirmSignatory(uint sigIndex) public onlySignatory {
        require(sigIndex < signatories.length, "Not a valid signatory index");
        NewSignatory storage addedSig = newSignatories[sigIndex];
        require(!addedSig.confirmed, "Signatory addition has already been confirmed");
        require(!addedSig.confirmations[msg.sender], "New Signatory already confirmed by this address");

        addedSig.confirmations[msg.sender] = true;
        addedSig.confirmationsCount += 1;

        emit ConfirmSignatory(msg.sender, sigIndex);

        if(addedSig.confirmationsCount == signatories.length){
            addedSig.confirmed = true;
            isSignatory[addedSig.sigAddress] = true;
            signatories.push(addedSig.sigAddress);
            requiredConfirmations += 1;

            emit IncreaseMinimumConfirmations(msg.sender, requiredConfirmations);
            emit AddSignatory(addedSig.sigAddress);
        }
    }

    // function increaseMinimumConfirmations(uint _increase) public onlySignatory {
    //     require((requiredConfirmations + _increase) <= signatories.length, "Required Signatures exceeds total Signatories");
    //     requiredConfirmations = requiredConfirmations + _increase;

    //     emit IncreaseMinimumConfirmations(msg.sender, requiredConfirmations);
    // }

    // Events
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint amount);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    event NewSignatoryInQueue(address indexed owner, address indexed added, uint indexed signatoryIndex);
    event AddSignatory(address indexed added);
    event IncreaseMinimumConfirmations(address indexed owner, uint requiredConfirmations);
    event ConfirmSignatory(address indexed owner, uint indexed sigIndex);
}
