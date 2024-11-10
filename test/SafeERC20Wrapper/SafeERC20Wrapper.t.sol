// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IERC20Minimal, SafeTransfer, TokenSweeper} from "../../src/SafeERC20Wrapper/SafeERC20Wrapper.sol";

interface Vm {
    function prank(address sender) external;
}

/// A token that returns empty data on transfer (USDT-style quirk).
contract SilentToken is IERC20Minimal {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        assembly {
            mstore(0, 0)
            return(0, 0)
        } // return empty
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        assembly {
            mstore(0, 0)
            return(0, 0)
        }
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        assembly {
            mstore(0, 0)
            return(0, 0)
        }
    }
}

contract SafeERC20WrapperTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    address private constant OWNER = address(0xB055);
    address private constant RECIPIENT = address(0xEC1);

    function testSafeTransferHandlesSilentToken() external {
        SilentToken t = new SilentToken();
        vm.prank(OWNER);
        t.mint(address(this), 100 ether);
        require(t.balanceOf(address(this)) == 100 ether, "mint failed");

        // Direct library use.
        SafeTransfer.safeTransfer(IERC20Minimal(address(t)), RECIPIENT, 40 ether);
        require(t.balanceOf(RECIPIENT) == 40 ether, "safe transfer failed");
    }

    function testSweeperUsesSafeTransfer() external {
        SilentToken t = new SilentToken();
