// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {MerkleAirdrop, IERC20Like} from "../../src/MerkleAirdrop/MerkleAirdrop.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}

contract MockToken is IERC20Like {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}
