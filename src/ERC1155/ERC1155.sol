// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;


interface IERC1155Receiver {
    function onERC1155Received(address,address,uint256,uint256,bytes calldata) external returns(bytes4);
    function onERC1155BatchReceived(address,address,uint256[] calldata,uint256[] calldata,bytes calldata) external returns(bytes4);
}
/// @notice Educational ERC1155 core transfers; optional URI metadata is not implemented.
contract ERC1155 {
    error NotOwnerOrApproved(address caller);error UnsafeReceiver(address receiver);error InvalidAmount();error ZeroAddress();
    address public immutable owner;
    mapping(address=>mapping(uint256=>uint256)) private balances;
    mapping(address=>mapping(address=>bool)) public isApprovedForAll;
    event TransferSingle(address indexed operator,address indexed from,address indexed to,uint256 id,uint256 amount);
    event TransferBatch(address indexed operator,address indexed from,address indexed to,uint256[] ids,uint256[] amounts);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);
    constructor(){owner=msg.sender;}
    function supportsInterface(bytes4 id) external pure returns(bool){return id==0x01ffc9a7||id==0xd9b67a26;}
    function balanceOf(address account,uint256 id) public view returns(uint256){if(account==address(0))revert ZeroAddress();return balances[account][id];}
    function balanceOfBatch(address[] calldata accounts,uint256[] calldata ids) external view returns(uint256[] memory result){require(accounts.length==ids.length,"length mismatch");result=new uint256[](ids.length);for(uint256 i;i<ids.length;i++)result[i]=balanceOf(accounts[i],ids[i]);}
    function setApprovalForAll(address operator,bool approved) external {require(operator!=msg.sender,"self approval");isApprovedForAll[msg.sender][operator]=approved;emit ApprovalForAll(msg.sender,operator,approved);}
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount) external {_single(from,to,id,amount,"");}
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external {_single(from,to,id,amount,data);}
    function _single(address from,address to,uint256 id,uint256 amount,bytes memory data) internal {
        if(msg.sender!=from&&!isApprovedForAll[from][msg.sender])revert NotOwnerOrApproved(msg.sender);
        _transfer(from,to,id,amount);emit TransferSingle(msg.sender,from,to,id,amount);
        if(to.code.length>0&&IERC1155Receiver(to).onERC1155Received(msg.sender,from,id,amount,data)!=IERC1155Receiver.onERC1155Received.selector)revert UnsafeReceiver(to);
    }
    function safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts) external {_batch(from,to,ids,amounts,"");}
    function safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external {_batch(from,to,ids,amounts,data);}
    function _batch(address from,address to,uint256[] memory ids,uint256[] memory amounts,bytes memory data) internal {
        if(msg.sender!=from&&!isApprovedForAll[from][msg.sender])revert NotOwnerOrApproved(msg.sender);require(ids.length==amounts.length,"length mismatch");
        for(uint256 i;i<ids.length;i++)_transfer(from,to,ids[i],amounts[i]);emit TransferBatch(msg.sender,from,to,ids,amounts);
        if(to.code.length>0&&IERC1155Receiver(to).onERC1155BatchReceived(msg.sender,from,ids,amounts,data)!=IERC1155Receiver.onERC1155BatchReceived.selector)revert UnsafeReceiver(to);
    }
    function _transfer(address from,address to,uint256 id,uint256 amount) internal {
        if(from==address(0)||to==address(0))revert ZeroAddress();require(balances[from][id]>=amount,"insufficient balance");balances[from][id]-=amount;balances[to][id]+=amount;
    }
    function mint(address to,uint256 id,uint256 amount) external {
        if(msg.sender!=owner)revert NotOwnerOrApproved(msg.sender);if(to==address(0))revert ZeroAddress();balances[to][id]+=amount;emit TransferSingle(msg.sender,address(0),to,id,amount);
        if(to.code.length>0&&IERC1155Receiver(to).onERC1155Received(msg.sender,address(0),id,amount,"")!=IERC1155Receiver.onERC1155Received.selector)revert UnsafeReceiver(to);
    }
}
