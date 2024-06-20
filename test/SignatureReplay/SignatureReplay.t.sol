// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {SignatureReplay} from "../../src/SignatureReplay/SignatureReplay.sol";

interface Vm {
    function prank(address sender) external;
    function expectRevert() external;
    function addr(uint256 privateKey) external returns (address);
    function sign(uint256 privateKey, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);
}

contract SignatureReplayTest {
