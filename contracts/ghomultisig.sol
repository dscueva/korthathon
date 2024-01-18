// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

// Nate PubKey ["0xc977Fdb84F4ed2425f6afA5f47bd686291615451", "0x5bEb07c71Da8ceD22A392847E775a245c4F431de"]
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

    function balanceETH() public view returns (uint256 _balance) {
        _balance = address(this).balance;
    }

    // Submit a transaction to be executed by the wallet, and automatically sign off for confirmation as initiator
    function submitTransaction(address _to, uint256 _amount) public onlySignatory {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");

        uint txIndex = transactions.length;
        transactions.push();
        Transaction storage transaction = transactions[txIndex];
        transaction.to = _to;
        transaction.amount = _amount;
        transaction.executed = false;
        transaction.confirmationsCount = 1;
        txConfirmations[txIndex][msg.sender] = true;

        emit SubmitTransaction(msg.sender, txIndex, _to, _amount);
        if(transaction.confirmationsCount == requiredConfirmations){
            executeTransaction(txIndex);
        }
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



    // Off-Chain Verification
    function verifyTransaction(address _sender, uint _transactionIndex, bytes memory _sig) external onlySignatory returns (bool check) {
        require(!(_sender == address(0)), "Invalid address");
        require(!(txConfirmations[_transactionIndex][_sender]), "Already signed with this address");
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
        require(!(sigConfirmations[_signatoryIndex][_sender]), "Already signed with this address");
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

    function revokeTransactionSignature(uint _transactionIndex) external onlySignatory {
        require(_transactionIndex < transactions.length, "Transaction index out of bounds");
        Transaction storage atIndex = transactions[_transactionIndex];
        require(txConfirmations[_transactionIndex][msg.sender], "Transaction not signed by sender");
        atIndex.confirmationsCount -= 1;
        txConfirmations[_transactionIndex][msg.sender] = false;

        emit RemovedSignatureFromTransaction(msg.sender, _transactionIndex);
    }

    function revokeSignatorySignature(uint _signatoryIndex) external onlySignatory {
        require(_signatoryIndex < newSignatories.length, "Signatory index out of bounds");
        NewSignatory storage atIndex = newSignatories[_signatoryIndex];
        require(sigConfirmations[_signatoryIndex][msg.sender], "Signatory not signed by sender");
        atIndex.confirmationsCount -= 1;
        sigConfirmations[_signatoryIndex][msg.sender] = false;

        emit RemovedSignatureFromSignatory(msg.sender, _signatoryIndex);
    }



    //Get the transaction hash for the staged transaction
    function getTransactionHash(uint _transactionIndex) public view onlySignatory returns (bytes32){
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

    //Add function to allow a signatory to remove themselves from the wallet, and decrease required confirmations by 1. Also removes their signature from any staged transactions and any staged signatories that were not yet executed
    function removeSignatory() public onlySignatory {
        require(signatories.length > 1, "Cannot remove last signatory");
        isSignatory[msg.sender] = false;
        for(uint i = 0; i < signatories.length; i++){
            if(signatories[i] == msg.sender){
                signatories[i] = signatories[signatories.length - 1];
                signatories.pop();
                break;
            }
        }
        requiredConfirmations -= 1;
        emit DecreaseMinimumConfirmations(msg.sender, requiredConfirmations);
        emit RemovedSignatory(msg.sender);
        for(uint i = 0; i < transactions.length; i++){
            if(txConfirmations[i][msg.sender]){
                transactions[i].confirmationsCount -= 1;
                txConfirmations[i][msg.sender] = false;

                emit RemovedSignatureFromTransaction(msg.sender, i);
            }
        }
        for(uint i = 0; i < newSignatories.length; i++){
            if(sigConfirmations[i][msg.sender]){
                newSignatories[i].confirmationsCount -= 1;
                sigConfirmations[i][msg.sender] = false;

                emit RemovedSignatureFromSignatory(msg.sender, i);
            }
        }
    }

    //Fucntion to emit an event when the contract receives GHO tokens
    function depositGHO(uint _amount) public {
        require(ghoToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        emit Deposit(msg.sender, _amount, ghoToken.balanceOf(address(this)));
    }

    //Fucntion to emit an event when the contract receives ETH
    function depositETH() public payable {
        emit Deposit(msg.sender, msg.value, ghoToken.balanceOf(address(this)));
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
    event RemovedSignatory(address indexed removed);
    event DecreaseMinimumConfirmations(address indexed owner, uint requiredConfirmations);
    event RemovedSignatureFromTransaction(address indexed owner, uint indexed txIndex);
    event RemovedSignatureFromSignatory(address indexed owner, uint indexed sigIndex);
}
