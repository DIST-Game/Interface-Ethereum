pragma solidity ^0.4.0;

interface assetController{
    //function changeAttribute(uint256 itemHash, string[] attributeNames, uint256[] values) public;
    function listGoods(uint256 gameIndex, uint256 showStartIndex) public constant returns(uint256[100] goodsList,uint8 len);
    function generateAssetN(address caller,uint256 baseGenes,uint256 number) public returns(uint256 newStartIndex,uint256 newEndIndex);
    function approvalAsset(address call,uint256 hashIndex,address newOwnerAddress) public;
    function queryAssetPrice(uint256 hashIndex) public constant returns(uint256 prices);
    function queryAsset(uint256 hashIndex) public constant returns(uint256 genes,uint16 status);
    function querySelfAsset(address caller,uint256 queryStartIndex) public constant returns(uint256[100] assetIndexList,uint8 len);
    function queryAssetOwner(uint256 hashIndex) public constant returns(address owner);
    function launch(address caller,uint256 hashIndex, uint256 prices) public;
    function withdraw(address caller,uint256 hashIndex) public;
    function switchOwner(address caller,uint256 hashIndex) public;
    
    function queryMsgSender() public constant returns(address address1);
}
