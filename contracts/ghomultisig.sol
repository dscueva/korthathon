// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

// Nate PubKey ["0xc977Fdb84F4ed2425f6afA5f47bd686291615451"]
contract ghomultisig {
    
    IERC20 ghoToken;
    address[] public signatories;
    mapping(address => bool) isSignatory;
    uint public requiredConfirmations;

    

    struct Transaction {
        address to;
        uint256 amount;
        bool executed;
        uint confirmationsCount;
    }

    struct NewSignatory {
        address sigAddress;
        bool confirmed;
        uint confirmationsCount;
    }

    Transaction[] internal transactions;
    mapping(uint => mapping(address => bool)) txConfirmations;
    
    NewSignatory[] internal newSignatories;
    mapping(uint => mapping(address => bool)) sigConfirmations;


    modifier onlySignatory() {
        require(isSignatory[msg.sender], "Not a signatory");
        _;
    }

    constructor(address[] memory _signatories, uint _requiredConfirmations) {
        ghoToken = IERC20(address(0xc4bF5CbDaBE595361438F8c6a187bDc330539c60));
        require(_signatories.length >= _requiredConfirmations, "Not enough signatories");
        require(_requiredConfirmations > 0, "Must have at least 1 required confirmation");
        for (uint i = 0; i < _signatories.length; i++) {
            address signatory = _signatories[i];
            require(signatory != address(0), "Invalid signatory");
            require(!isSignatory[signatory], "Signatory not unique");

            isSignatory[signatory] = true;
            signatories.push(signatory);
        }
        requiredConfirmations = _requiredConfirmations;
    }

    function viewStagedTransactions() external view onlySignatory returns(Transaction[] memory){
        return transactions;
    }

    function viewStagedSignatories() external view onlySignatory returns(NewSignatory[] memory){
        return newSignatories;
    }

    function balanceGHO() public view returns (uint256 _balance) {
        _balance = ghoToken.balanceOf(address(this));
    }

    function submitTransaction(address _to, uint256 _amount) public onlySignatory {
        require(balanceGHO() >= _amount, "Insufficient amount of Tokens");
        uint txIndex = transactions.length;
        transactions.push();
        Transaction storage newTx = transactions[txIndex];
        newTx.to = _to;
        newTx.amount = _amount;

        emit SubmitTransaction(msg.sender, txIndex, _to, _amount);
    }

    function executeTransaction(uint _txIndex) internal {
        require(_txIndex < transactions.length);
        Transaction storage transaction = transactions[_txIndex];
        require(balanceGHO() >= transaction.amount, "Insufficient amount of tokens in wallet");
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
            sigConfirmations[sigIndex][msg.sender] = true;
            newSig.confirmationsCount = 1;
            newSig.confirmed = false;

            emit NewSignatoryInQueue(msg.sender, _addedSignatory, sigIndex);
        }
    }


    receive() external payable {
        emit Deposit(msg.sender, msg.value, ghoToken.balanceOf(address(this)));
    }


    // Off-Chain Verification
    function verifyTransaction(address _sender, uint _transactionIndex, bytes memory _sig) external onlySignatory returns (bool check) {
        require(!(_sender == address(0)), "Invalid address");
        bytes32 txHash = getTransactionHash(_transactionIndex);
        bytes32 ethSignedTransactionHash = getEthSignedTransactionHash(txHash);

        check = recover(ethSignedTransactionHash, _sig) == _sender;
        if(check){
            Transaction storage txAtInd = transactions[_transactionIndex];
            txConfirmations[_transactionIndex][_sender] = true;
            txAtInd.confirmationsCount += 1;

            emit SignedTransaction(_sender, _transactionIndex);
            if(txAtInd.confirmationsCount == requiredConfirmations){
                executeTransaction(_transactionIndex);
            }
        }
    }

    function verifySignatory(address _sender, uint _signatoryIndex, bytes memory _sig) external onlySignatory returns (bool check) {
        require(!(_sender == address(0)), "Invalid address");
        bytes32 txHash = getSignatoryHash(_signatoryIndex);
        bytes32 ethSignedTransactionHash = getEthSignedTransactionHash(txHash);

        check = recover(ethSignedTransactionHash, _sig) == _sender;
        if(check){
            NewSignatory storage sigAtInd = newSignatories[_signatoryIndex];
            sigConfirmations[_signatoryIndex][_sender] = true;
            sigAtInd.confirmationsCount += 1;

            emit ConfirmSignatory(_sender, _signatoryIndex);
            if(sigAtInd.confirmationsCount == signatories.length){
                sigAtInd.confirmed = true;
                isSignatory[sigAtInd.sigAddress] = true;
                signatories.push(sigAtInd.sigAddress);
                requiredConfirmations += 1;

                emit IncreaseMinimumConfirmations(_sender, requiredConfirmations);
                emit AddSignatory(sigAtInd.sigAddress);
            }
        }
    }



    //Get the transaction hash for the staged transaction
    function getTransactionHash(uint _transactionIndex) public view returns (bytes32){
        require(_transactionIndex < transactions.length, "Transaction index out of bounds");
        Transaction storage atIndex = transactions[_transactionIndex];
        return keccak256(abi.encodePacked(atIndex.to, atIndex.amount, _transactionIndex));
    } 

    //Get the hash for staged signatory
    function getSignatoryHash(uint _signatoryIndex) public view returns (bytes32){
        require(_signatoryIndex < newSignatories.length, "Signatory index out of bounds");
        NewSignatory storage atIndex = newSignatories[_signatoryIndex];
        return keccak256(abi.encodePacked(atIndex.sigAddress));
    }


    //Get the EthSigned Transaction Hash for the staged tx
    function getEthSignedTransactionHash(bytes32 _transactionHash) internal pure returns (bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _transactionHash));
    }


    //Recover the address of the of the signer
    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) internal pure returns (address){
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    //Split signature into necessary bytes
    function splitSignature(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v){
        require(_sig.length == 65, "Invalid Signature Length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }




    // Events
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint amount);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    event NewSignatoryInQueue(address indexed owner, address indexed added, uint indexed signatoryIndex);
    event AddSignatory(address indexed added);
    event IncreaseMinimumConfirmations(address indexed owner, uint requiredConfirmations);
    event ConfirmSignatory(address indexed owner, uint indexed sigIndex);
    event Deposit(address indexed sender, uint amount, uint balance);
    event SignedTransaction(address indexed owner, uint indexed txIndex);
}
