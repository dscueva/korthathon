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

    Transaction[] public transactions;

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
        Transaction storage transaction = transactions[_txIndex];
        require(!transaction.executed, "Transaction already executed");
        require(transaction.confirmationsCount >= requiredConfirmations, "Insufficient confirmations");

        transaction.executed = true;
        require(ghoToken.transfer(transaction.to, transaction.amount), "Transfer failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    // Add function to add and remove signatories if needed

    // Events
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint amount);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
}
