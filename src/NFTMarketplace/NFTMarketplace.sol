// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/NFTMarketplace/NFTMarketplace.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Educational fixed-price marketplace, using approved ERC721 delivery.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;


interface IMarketNFT {
    function ownerOf(uint256 id) external view returns(address);
    function getApproved(uint256 id) external view returns(address);
    function isApprovedForAll(address owner,address operator) external view returns(bool);
    function safeTransferFrom(address from,address to,uint256 id) external;
}
/// @notice Educational fixed-price marketplace, using approved ERC721 delivery.
contract NFTMarketplace {
    error NotSeller(address caller); error NotListed(); error PriceTooLow(uint256 price,uint256 paid);
    error TransferFailed(); error ZeroAddress(); error InvalidFee(); error InvalidNFT(); error Reentrancy();
    struct Listing { address seller;address nft;uint256 tokenId;uint256 price; }
    event Listed(address indexed nft,uint256 indexed tokenId,address seller,uint256 price);
    event Delisted(address indexed nft,uint256 indexed tokenId);
    event Bought(address indexed nft,uint256 indexed tokenId,address buyer,uint256 price);
    address public immutable feeRecipient;uint256 public immutable feeBps;
    mapping(address=>mapping(uint256=>Listing)) public listings;
    uint256 private lock=1;
    modifier guarded(){if(lock!=1)revert Reentrancy();lock=2;_;lock=1;}
    constructor(address recipient,uint256 fee){if(recipient==address(0))revert ZeroAddress();if(fee>10000)revert InvalidFee();feeRecipient=recipient;feeBps=fee;}
    function _authorized(address nft,uint256 id,address seller) internal view {
        if(nft.code.length==0)revert InvalidNFT();
        IMarketNFT token=IMarketNFT(nft);
        if(token.ownerOf(id)!=seller)revert NotSeller(seller);
        if(token.getApproved(id)!=address(this)&&!token.isApprovedForAll(seller,address(this)))revert InvalidNFT();
    }
    function list(address nft,uint256 id,uint256 price) external guarded {
        _authorized(nft,id,msg.sender);if(price==0)revert PriceTooLow(1,price);
        listings[nft][id]=Listing(msg.sender,nft,id,price);emit Listed(nft,id,msg.sender,price);
    }
    function delist(address nft,uint256 id) external guarded {
        Listing memory l=listings[nft][id];if(l.seller==address(0))revert NotListed();
        if(l.seller!=msg.sender)revert NotSeller(msg.sender);delete listings[nft][id];emit Delisted(nft,id);
    }
    function buy(address nft,uint256 id) external payable guarded {
        Listing memory l=listings[nft][id];if(l.seller==address(0))revert NotListed();
        if(msg.value!=l.price)revert PriceTooLow(l.price,msg.value);_authorized(nft,id,l.seller);
        uint256 fee=(l.price/10000)*feeBps+(l.price%10000)*feeBps/10000;
        delete listings[nft][id];
        IMarketNFT(nft).safeTransferFrom(l.seller,msg.sender,id);
        (bool sellerOK,)=payable(l.seller).call{value:l.price-fee}("");if(!sellerOK)revert TransferFailed();
        if(fee!=0){(bool feeOK,)=payable(feeRecipient).call{value:fee}("");if(!feeOK)revert TransferFailed();}
        emit Bought(nft,id,msg.sender,l.price);
    }
}
