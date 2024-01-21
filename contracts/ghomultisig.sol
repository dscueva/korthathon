// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ghomultisig {
    
    IERC20 ghoToken;
    address[] public signatories;
    mapping(address => bool) isSignatory;
    uint public requiredConfirmations;
    uint public requiredRejections;
    uint nonce = 0;
    
    struct Transaction {
        address to;
        uint nonce;
        bytes32 txHash;
        uint256 amount;
        uint confirmationsCount;
        uint rejectCount;
    }

    struct NewSignatory {
        address sigAddress;
        uint nonce;
        bytes32 sigHash;
        uint confirmationsCount;
    }

    struct WalletChange {
        uint newRequiredConfirmations;
        uint nonce;
        bytes32 walletChangeHash;
        uint confirmationsCount;
    }

    Transaction[] internal transactions;
    mapping(bytes32 => mapping(address => bool)) txConfirmations;
    mapping(bytes32 => mapping(address => bool)) txRejections;
    mapping(bytes32 => uint) txIndices;
    
    NewSignatory[] internal newSignatories;
    mapping(bytes32 => mapping(address => bool)) sigConfirmations;
    mapping(bytes32 => uint) sigIndices;

    WalletChange[] internal walletChanges;
    mapping(bytes32 => mapping(address => bool)) walletChangeConfirmations;
    mapping(bytes32 => uint) walletChangeIndices;


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
        requiredRejections = 1 + (_signatories.length - _requiredConfirmations);
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

    // Submit a transaction to be executed by the wallet, and automatically sign off for confirmation as initiator. If the required confirmations is 1, the transaction is executed immediately and never added to the array.
    function submitTransaction(address _recipient, uint256 _amount) public onlySignatory {
        require(_recipient != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");

        //If there is only one required confirmation, automatically execute the transaction
        if(requiredConfirmations == 1){
            require(balanceGHO() >= _amount, "Insufficient amount of tokens in wallet");
            require(ghoToken.transfer(_recipient, _amount), "Transfer failed");
            emit ExecuteSoleTransaction(msg.sender, _recipient, _amount);
            return;
        }

        uint txIndex = transactions.length;
        transactions.push();
        Transaction storage transaction = transactions[txIndex];
        transaction.to = _recipient;
        transaction.amount = _amount;
        transaction.nonce = nonce;
        nonce += 1;
        transaction.confirmationsCount = 1;
        transaction.rejectCount = 0;
        transaction.txHash = keccak256(abi.encodePacked(_recipient, _amount, nonce));
        txConfirmations[transaction.txHash][msg.sender] = true;
        txIndices[transaction.txHash] = txIndex;

        emit SubmitTransaction(msg.sender, transaction.txHash, _recipient, _amount);
    }


    function executeTransaction(bytes32 _txHash) internal {
        Transaction storage transaction = transactions[txIndices[_txHash]];
        require(_txHash == transaction.txHash, "Invalid transaction hash");
        require(balanceGHO() >= transaction.amount, "Insufficient amount of tokens in wallet");

        require(ghoToken.transfer(transaction.to, transaction.amount), "Transfer failed");
        //Once transaction is executed, SAFELY remove it from the array
        if(txIndices[_txHash] != transactions.length - 1){
            uint txIndex = txIndices[_txHash];
            transactions[txIndex] = transactions[transactions.length - 1];
            txIndices[transactions[txIndex].txHash] = txIndex;
        }
        transactions.pop();

        emit ExecuteTransaction(msg.sender, _txHash);
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
            newSig.nonce = nonce;
            nonce += 1;
            newSig.sigHash = keccak256(abi.encodePacked(_addedSignatory, nonce));
            sigConfirmations[newSig.sigHash][msg.sender] = true;
            sigIndices[newSig.sigHash] = sigIndex;
            newSig.confirmationsCount = 1;

            emit NewSignatoryInQueue(msg.sender, _addedSignatory, newSig.sigHash);
        }
    }



    // Off-Chain Verification
    function verifyTransaction(bytes32 _txHash, bytes memory _sig) external onlySignatory returns (bool check) {
        address _sender = msg.sender;
        require(!(_txHash == bytes32(0)), "Invalid transaction hash");
        require(!(_sender == address(0)), "Invalid address");
        require(!(txConfirmations[_txHash][_sender]), "Already signed with this address");
        require(_txHash == transactions[txIndices[_txHash]].txHash, "Invalid transaction hash");
        bytes32 ethSignedTransactionHash = getEthSignedTransactionHash(_txHash);

        check = recover(ethSignedTransactionHash, _sig) == _sender;
        if(check){
            Transaction storage txAtInd = transactions[txIndices[_txHash]];
            txConfirmations[_txHash][_sender] = true;
            txAtInd.confirmationsCount += 1;

            emit SignedTransaction(_sender, _txHash);
            if(txAtInd.confirmationsCount == requiredConfirmations){
                executeTransaction(_txHash);
            }
        }
    }

    function verifySignatory(bytes32 _sigHash, bytes memory _sig) external onlySignatory returns (bool check) {
        address _sender = msg.sender;
        require(!(_sigHash == bytes32(0)), "Invalid signatory hash");
        require(!(_sender == address(0)), "Invalid address");
        require(!(sigConfirmations[_sigHash][_sender]), "Already signed with this address");
        require(_sigHash == newSignatories[sigIndices[_sigHash]].sigHash, "Invalid signatory hash");
        bytes32 ethSignedTransactionHash = getEthSignedTransactionHash(_sigHash);

        check = recover(ethSignedTransactionHash, _sig) == _sender;
        if(check){
            NewSignatory storage sigAtInd = newSignatories[sigIndices[_sigHash]];
            sigConfirmations[_sigHash][_sender] = true;
            sigAtInd.confirmationsCount += 1;

            emit ConfirmSignatory(_sender, _sigHash);
            if(sigAtInd.confirmationsCount == signatories.length){
                isSignatory[sigAtInd.sigAddress] = true;
                signatories.push(sigAtInd.sigAddress);
                requiredConfirmations += 1;

                emit IncreaseMinimumConfirmations(_sender, requiredConfirmations);
                emit AddSignatory(sigAtInd.sigAddress);
            }
        }
    }

    function revokeTransactionSignature(bytes32 _txHash) external onlySignatory {
        require(txIndices[_txHash] < transactions.length, "Transaction index out of bounds");
        Transaction storage atIndex = transactions[txIndices[_txHash]];
        require(txConfirmations[_txHash][msg.sender], "Transaction not signed by sender");
        atIndex.confirmationsCount -= 1;
        txConfirmations[_txHash][msg.sender] = false;

        emit RemovedSignatureFromTransaction(msg.sender, _txHash);
    }

    function revokeTransactionRejection(bytes32 _txHash) external onlySignatory {
        require(txIndices[_txHash] < transactions.length, "Transaction index out of bounds");
        Transaction storage atIndex = transactions[txIndices[_txHash]];
        require(txRejections[_txHash][msg.sender], "Transaction not rejected by sender");
        atIndex.rejectCount -= 1;
        txRejections[_txHash][msg.sender] = false;

        emit RemovedRejectionFromTransaction(msg.sender, _txHash);
    }


    function verifyWalletChange(bytes32 _walletChangeHash, bytes memory _sig) external onlySignatory returns (bool check) {
        address _sender = msg.sender;
        require(!(_walletChangeHash == bytes32(0)), "Invalid wallet change hash");
        require(!(_sender == address(0)), "Invalid address");
        require(!(walletChangeConfirmations[_walletChangeHash][_sender]), "Already signed with this address");
        require(_walletChangeHash == walletChanges[walletChangeIndices[_walletChangeHash]].walletChangeHash, "Invalid wallet change hash");
        bytes32 ethSignedTransactionHash = getEthSignedTransactionHash(_walletChangeHash);

        check = recover(ethSignedTransactionHash, _sig) == _sender;
        if(check){
            WalletChange storage wcAtInd = walletChanges[walletChangeIndices[_walletChangeHash]];
            walletChangeConfirmations[_walletChangeHash][_sender] = true;
            wcAtInd.confirmationsCount += 1;

            emit ConfirmWalletChange(_sender, _walletChangeHash);
            if(wcAtInd.confirmationsCount == signatories.length){
                bool emission = (requiredConfirmations < wcAtInd.newRequiredConfirmations);
                requiredConfirmations = wcAtInd.newRequiredConfirmations;
                if(emission){
                    emit IncreaseMinimumConfirmations(_sender, requiredConfirmations);
                }else{
                    emit DecreaseMinimumConfirmations(_sender, requiredConfirmations);
                }
            }
        }
    }


    //Reject a transaction using its hash, and if the required rejections is met, SAFELY remove the transaction from the array.
    function rejectTransaction(bytes32 _txHash) external onlySignatory {
        address _sender = msg.sender;
        require(!(_txHash == bytes32(0)), "Invalid transaction hash");
        require(!(_sender == address(0)), "Invalid address");
        require(!(txRejections[_txHash][_sender]), "Already rejected with this address");
        require(_txHash == transactions[txIndices[_txHash]].txHash, "Invalid transaction hash");

        txConfirmations[_txHash][_sender] = false; //Remove signature if it exists

        Transaction storage txAtInd = transactions[txIndices[_txHash]];
        txRejections[_txHash][_sender] = true;
        txAtInd.rejectCount += 1;

        emit RejectedTransaction(_sender, _txHash);
        if(txAtInd.rejectCount == requiredRejections){
            if(txIndices[_txHash] != transactions.length - 1){
                uint _transactionIndex = txIndices[_txHash];
                transactions[_transactionIndex] = transactions[transactions.length - 1];
                txIndices[transactions[_transactionIndex].txHash] = _transactionIndex;
            }
            transactions.pop();

            emit RemovedTransaction(_sender, _txHash);
        }

    }

    //Reject a signatory using its hash, and safely remove it from the array since it only requires 1 rejection.
    function rejectSignatory(bytes32 _sigHash) external onlySignatory {
        address _sender = msg.sender;
        require(!(_sigHash == bytes32(0)), "Invalid signatory hash");
        require(!(_sender == address(0)), "Invalid address");
        require(_sigHash == newSignatories[sigIndices[_sigHash]].sigHash, "Invalid signatory hash");

        sigConfirmations[_sigHash][_sender] = false; //Remove signature if it exists
        if(sigIndices[_sigHash] != newSignatories.length - 1){
            uint sigIndex = sigIndices[_sigHash];
            newSignatories[sigIndices[_sigHash]] = newSignatories[newSignatories.length - 1];
            sigIndices[newSignatories[sigIndices[_sigHash]].sigHash] = sigIndex;
        }
        newSignatories.pop();

        emit RemovedProposedSignatory(_sender, _sigHash);
    }

    //Reject a wallet change using its hash, and safely remove it from the array since it only requires 1 rejection.
    function rejectWalletChange(bytes32 _walletChangeHash) external onlySignatory {
        address _sender = msg.sender;
        require(!(_walletChangeHash == bytes32(0)), "Invalid wallet change hash");
        require(!(_sender == address(0)), "Invalid address");
        require(_walletChangeHash == walletChanges[walletChangeIndices[_walletChangeHash]].walletChangeHash, "Invalid wallet change hash");

        walletChangeConfirmations[_walletChangeHash][_sender] = false; //Remove signature if it exists
        if(walletChangeIndices[_walletChangeHash] != walletChanges.length - 1){
            uint wcindex = walletChangeIndices[_walletChangeHash];
            walletChanges[walletChangeIndices[_walletChangeHash]] = walletChanges[walletChanges.length - 1];
            walletChangeIndices[walletChanges[walletChangeIndices[_walletChangeHash]].walletChangeHash] = wcindex;
        }
        walletChanges.pop();

        emit RemovedProposedWalletChange(_sender, _walletChangeHash);
    }







    //Get the transaction hash for the staged transaction
    function getTransactionHash(uint _transactionIndex) public view onlySignatory returns (bytes32){
        require(_transactionIndex < transactions.length, "Transaction index out of bounds");
        Transaction storage atIndex = transactions[_transactionIndex];
        return atIndex.txHash;
    } 

    //Get the hash for staged signatory
    function getSignatoryHash(uint _signatoryIndex) public view returns (bytes32){
        require(_signatoryIndex < newSignatories.length, "Signatory index out of bounds");
        NewSignatory storage atIndex = newSignatories[_signatoryIndex];
        return atIndex.sigHash;
    }

    //Get the hash for staged wallet change
    function getWalletChangeHash(uint _walletChangeIndex) public view returns (bytes32){
        require(_walletChangeIndex < walletChanges.length, "Wallet change index out of bounds");
        WalletChange storage atIndex = walletChanges[_walletChangeIndex];
        return atIndex.walletChangeHash;
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

            if(txConfirmations[transactions[i].txHash][msg.sender]){
                transactions[i].confirmationsCount -= 1;
                txConfirmations[transactions[i].txHash][msg.sender] = false;

                emit RemovedSignatureFromTransaction(msg.sender, transactions[i].txHash);
            }
        }
        for(uint i = 0; i < newSignatories.length; i++){
            if(sigConfirmations[newSignatories[i].sigHash][msg.sender]){
                newSignatories[i].confirmationsCount -= 1;
                sigConfirmations[newSignatories[i].sigHash][msg.sender] = false;

                emit RemovedSignatureFromSignatory(msg.sender, newSignatories[i].sigHash);
            }
        }
        //Remove Wallet Change signatures
        
        //Remove transaction rejections
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

    //Function that allows an owner to change the minimum required confirmations, but requires 100% of the owners to agree. Adds a wallet change to the walletChange array, and automatically signs off for confirmation as initiator.
    function changeRequiredConfirmations(uint _newRequiredConfirmations) public onlySignatory {
        require(_newRequiredConfirmations > 0, "Must have at least 1 required confirmation");
        require(_newRequiredConfirmations <= signatories.length, "Cannot have more required confirmations than signatories");
        uint walletChangeIndex = walletChanges.length;
        walletChanges.push();
        WalletChange storage walletChange = walletChanges[walletChangeIndex];
        walletChange.newRequiredConfirmations = _newRequiredConfirmations;
        walletChange.nonce = nonce;
        nonce += 1;
        walletChange.walletChangeHash = keccak256(abi.encodePacked(_newRequiredConfirmations, nonce));
        walletChangeConfirmations[walletChange.walletChangeHash][msg.sender] = true;
        walletChange.confirmationsCount = 1;

        emit SubmitWalletChange(msg.sender, walletChange.walletChangeHash, _newRequiredConfirmations);
    }

    //Function that allows an owner to confirm a wallet change, but requires 100% of the owners to agree. If confirmed, the required confirmations is changed to the new value.



    // Events
    event SubmitTransaction(address indexed owner, bytes32 indexed transactionHash, address indexed to, uint amount);
    event ExecuteTransaction(address indexed owner, bytes32 indexed transactionHash);
    event ExecuteSoleTransaction(address indexed owner, address indexed recipient, uint indexed amount);
    event NewSignatoryInQueue(address indexed owner, address indexed added, bytes32 indexed sigHash);
    event AddSignatory(address indexed added);
    event IncreaseMinimumConfirmations(address indexed owner, uint requiredConfirmations);
    event ConfirmSignatory(address indexed owner, bytes32 indexed sigHash);
    event Deposit(address indexed sender, uint amount, uint balance);
    event SignedTransaction(address indexed owner, bytes32 indexed transactionHash);
    event RemovedSignatory(address indexed removed);
    event DecreaseMinimumConfirmations(address indexed owner, uint requiredConfirmations);
    event RemovedSignatureFromTransaction(address indexed owner, bytes32 indexed transactionHash);
    event RemovedSignatureFromSignatory(address indexed owner, bytes32 indexed sigHash);
    event SubmitWalletChange(address indexed owner, bytes32 indexed walletChangeHash, uint indexed newRequiredConfirmations);
    event ConfirmWalletChange(address indexed owner, bytes32 indexed walletChangeHash);
    event RemovedSignatureFromWalletChange(address indexed owner, bytes32 indexed walletChangeHash);
    event RejectedTransaction(address indexed owner, bytes32 indexed transactionHash);
    event RemovedTransaction(address indexed owner, bytes32 indexed transactionHash);
    event RemovedRejectionFromTransaction(address indexed owner, bytes32 indexed transactionHash);
    event RemovedProposedSignatory(address indexed owner, bytes32 indexed sigHash);
    event RemovedProposedWalletChange(address indexed owner, bytes32 indexed walletChangeHash);

}
