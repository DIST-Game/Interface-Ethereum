pragma solidity ^0.4.0;

interface marketplaceController{
    function pendingOrder(address callerContractAddress,uint256 itemHash, uint256 prices) public;
    function soldOut(address callerContractAddress,uint256 itemHash) public;
    function buy(address callerContractAddress,uint256 itemHash,uint256 tokenNum) public;
    function listGoods(uint256 gameIndex, uint256 showStartIndex) public constant returns(uint256[100] goodsList,uint8 len);
}
