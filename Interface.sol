pragma solidity ^0.4.0;

import "./common/owned.sol";
import "./common/assetControllerInterface.sol";
import "./common/marketplaceControllerInterface.sol";
import "./common/namespaceInterface.sol";
import "./common/token.sol";
//定义其他个Contract的Interface
//interface tokenECR20{ function setPrices(uint256 newSellPrice, uint256 newBuyPrice)  public;  }

//这个合约直接面对Dapp，类似架构中的PaaS层
contract ProxyContract is owned{
    //namespace的地址
    address internal namespaceResolverAddress;

    //游戏Server需要关心的各种event，以便与上层应用异步同步信息
    event eventLaunch(uint256 hashIndex,uint256 prices);
    event eventWithdraw(uint256 itemHash);
    event eventAssetOwnerUpdated(address newowner,uint256 hashIndex);
    event eventAssetGenerate(uint256 baseGenese,uint256 startIndex, uint256 endIndex);
    //event eventDebug(address value);

    function ProxyContract(address _namespaceResolver) public {
        namespaceResolverAddress = _namespaceResolver;
    }

    //和钱包相关的操作
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyPlatformOwner public {
        //通过nameSpaceContract查找Token合约，并设置Token合约中的设置价格的接口
        address tokenAddress=namespaceResolver(namespaceResolverAddress).getAddress("Token");
        tokenECR20(tokenAddress).setPrices(newSellPrice,newBuyPrice);
        //todo add event
    }

    //...

    //和市场相关的操作

    //将道具挂入交易市场
    //@itemHash 道具对应的在链上的index
    //@prices 道具价格，单位是我们的token(Dist?)
    function launch(uint256 itemHash, uint256 prices) public{
        //通过namespaceContract查找AssetController合约
        address marketplaceAddress=namespaceResolver(namespaceResolverAddress).getAddress("MarketplaceController");
        marketplaceController(marketplaceAddress).pendingOrder(msg.sender,itemHash,prices);
        //todo add event
        eventLaunch(itemHash,prices);
    }

    //将道具从交易市场撤出
    //@itemHash 道具对应的在链上的index
    function withdraw(uint256 itemHash) public{
        //通过namespaceContract查找AssetController合约
        address marketplaceAddress=namespaceResolver(namespaceResolverAddress).getAddress("MarketplaceController");
        marketplaceController(marketplaceAddress).soldOut(msg.sender,itemHash);
        //todo add event
        eventWithdraw(itemHash);

    }

    //购买
    //@itemHash 道具对应的在链上的index
    //@tokenNum 支付的钱
    function receiveApproval(address buyer, uint256 tokenNum, address tokenAddress, bytes assetIndex) public{
        require(tokenAddress == namespaceResolver(namespaceResolverAddress).getAddress("Token"));
        address assetControllerAddress=namespaceResolver(namespaceResolverAddress).getAddress("AssetController");
        uint256 payloadSize;
        uint256 payload;
        assembly {
            payloadSize := mload(assetIndex)
            payload := mload(add(assetIndex, 0x20))
        }
        payload = payload >> 8*(32 - payloadSize);

        address seller = assetController(assetControllerAddress).queryAssetOwner(payload);
        //eventDebug(seller);
        if(tokenECR20(tokenAddress).transferFrom(buyer, seller, tokenNum)){
            assetController(assetControllerAddress).switchOwner(buyer,payload);
        }
        eventAssetOwnerUpdated(buyer,payload);
    }

    //上市商品列表
    //@gameIndex 16比特表示游戏的索引；
    //@showStartIndex 本次索引的起始位置，默认为0；
    //@goodsList 返回值，每次最多返回100个商品的index；
    function listGoods(uint256 gameIndex, uint256 showStartIndex) public constant returns(uint256[100] goodsList, uint8 number){
        //通过namespaceContract查找marketplaceController合约
        address marketplaceAddress=namespaceResolver(namespaceResolverAddress).getAddress("MarketplaceController");
        return marketplaceController(marketplaceAddress).listGoods(gameIndex,showStartIndex);
    }

    //和资产管理相关的操作

    //查询资产详细信息
    //@assetIndex 道具在链上的index
    //@genes 返回值，道具链上的基因
    //@status 返回值，道具链上的状态
    function queryAsset(uint256 assetIndex) public constant returns(uint256 genes,uint16 status){
        //通过namespaceContract查找marketplaceController合约
        address assetControllerAddress=namespaceResolver(namespaceResolverAddress).getAddress("AssetController");
        return assetController(assetControllerAddress).queryAsset(assetIndex);
    }

    //赠送资产
    //@itemHash 道具在链上的index
    //@newOwnerAddress 道具的新拥有者
    function approvalAsset(uint256 itemHash,address newOwnerAddress) public{
        //通过namespaceContract查找marketplaceController合约
        address assetControllerAddress=namespaceResolver(namespaceResolverAddress).getAddress("AssetController");
        assetController(assetControllerAddress).approvalAsset(msg.sender,itemHash,newOwnerAddress);
        eventAssetOwnerUpdated(msg.sender,itemHash);
    }

    //创造道具
    //@baseGenes 基础基因，即一个236位的基本基因序列
    //@number 个数，此类道具创建个数（1～2^20）
    //@newStartIndex,@newEndIndex 新道具的index的起始值，到结束值，[newStartIndex,newEndIndex]
    function generateAssetN(uint256 baseGenes,uint256 number) onlyOwners public returns(uint256 newStartIndex,uint256 newEndIndex){
        address assetControllerAddress=namespaceResolver(namespaceResolverAddress).getAddress("AssetController");
        (newStartIndex,newEndIndex) = assetController(assetControllerAddress).generateAssetN(msg.sender,baseGenes,number);
        eventAssetGenerate(baseGenes,newStartIndex,newEndIndex);
        return (newStartIndex,newEndIndex);
    }

    //获取自己的道具
    //@queryStartIndex 从自己第几个道具开始查
    function querySelfAssets(uint256 queryStartIndex) public constant returns (uint256[100],uint8) {
        address assetControllerAddress=namespaceResolver(namespaceResolverAddress).getAddress("AssetController");
        return assetController(assetControllerAddress).querySelfAsset(msg.sender,queryStartIndex);
    }
    
    //获取道具owner
    function queryAssetOwner(uint256 index) public constant returns(address){
        
        address assetControllerAddress=namespaceResolver(namespaceResolverAddress).getAddress("AssetController");
        return assetController(assetControllerAddress).queryAssetOwner(index);
    }
    
    //获取各级的msg sender
    function queryMsgSender() public constant returns(address address1, address address2){
        
        address assetControllerAddress=namespaceResolver(namespaceResolverAddress).getAddress("AssetController");
        return (msg.sender,assetController(assetControllerAddress).queryMsgSender());
    }

    //获取道具价格
    function queryAssetPrice(uint256 index) public constant returns(uint256){
        address assetControllerAddress=namespaceResolver(namespaceResolverAddress).getAddress("AssetController");
        return assetController(assetControllerAddress).queryAssetPrice(index);
    }
}
