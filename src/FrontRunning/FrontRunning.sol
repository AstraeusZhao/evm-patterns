// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;


/// @notice Per-sender commit/reveal teaching pattern with sender/chain/domain binding.
contract FrontRunning {
    error AlreadyCommitted();error NoCommit();error WrongReveal();error RevealWindow();
    struct Commitment {bytes32 hash;uint256 blockNumber;uint256 expires;}
    mapping(address=>Commitment) public commitments;
    event Revealed(address indexed sender,uint256 number);
    function commitmentHash(address sender,uint256 number,bytes32 salt) public view returns(bytes32){return keccak256(abi.encode(number,salt,sender,address(this),block.chainid));}
    function commit(bytes32 hash) external {
        if(commitments[msg.sender].expires>=block.timestamp&&commitments[msg.sender].hash!=bytes32(0))revert AlreadyCommitted();
        require(hash!=bytes32(0),"empty commitment");commitments[msg.sender]=Commitment(hash,block.number,block.timestamp+1 days);
    }
    function reveal(uint256 number,bytes32 salt) external {
        Commitment memory c=commitments[msg.sender];if(c.hash==bytes32(0))revert NoCommit();
        if(block.number<=c.blockNumber||block.timestamp>c.expires)revert RevealWindow();
        if(commitmentHash(msg.sender,number,salt)!=c.hash)revert WrongReveal();delete commitments[msg.sender];emit Revealed(msg.sender,number);
    }
    function clearExpired(address account) external {require(commitments[account].expires<block.timestamp,"not expired");delete commitments[account];}
}
