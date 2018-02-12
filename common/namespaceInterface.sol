pragma solidity ^0.4.0;

interface namespaceResolver { 
    function getAddress(string _contractName) public constant returns (address _contractAddress); 
}
