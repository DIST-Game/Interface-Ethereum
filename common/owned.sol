pragma solidity ^0.4.0;

contract owned {
    address public platformOwner;
    mapping(address=>bool) public gameOwners;

    function owned() public {
        platformOwner = msg.sender;
    }

    modifier onlyPlatformOwner {
        require(msg.sender == platformOwner);
        _;
    }

    modifier onlyOwners {
        require(gameOwners[msg.sender]||msg.sender==platformOwner);
        _;
    }

    function transferOwnership(address newOwner) onlyPlatformOwner public {
        platformOwner = newOwner;
    }

    function addGameOwnership(address newGameOwner) onlyPlatformOwner public{
        gameOwners[newGameOwner]=true;
    }

    function delGameOwnership(address gameOwner) onlyPlatformOwner public{
        gameOwners[gameOwner]=false;
    }
}
