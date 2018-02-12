pragma solidity ^0.4.0;

interface tokenECR20{ 
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice)  public;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);  
}
