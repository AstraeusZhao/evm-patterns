// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {MerkleAirdrop, IERC20Like} from "../../src/MerkleAirdrop/MerkleAirdrop.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
}

contract MockToken is IERC20Like {
    mapping(address => uint256) public balanceOf;
