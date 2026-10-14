// SPDX-License-Identifier: AGPL-3.0
/*
 * File: src/FlashLoanReceiver/FlashLoanReceiver.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: ERC-3156 educational receiver. Only owner-initiated loans from one lender.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;


import {IERC20Minimal,SafeTransfer} from "../SafeERC20Wrapper/SafeERC20Wrapper.sol";
interface IFlashLender { function flashLoan(address receiver,address token,uint256 amount,bytes calldata data) external returns(bool); }
/// @notice ERC-3156 educational receiver. Only owner-initiated loans from one lender.
contract FlashLoanReceiver {
    error UntrustedLender(address lender);error InvalidLoan();
    event Received(address indexed lender,address indexed token,uint256 amount,uint256 fee);
    address public immutable owner;address public immutable lender;
    bool private active;address private loanToken;uint256 private loanAmount;uint256 private maxFee;
    modifier onlyOwner(){require(msg.sender==owner,"not owner");_;}
    constructor(address lender_){require(lender_.code.length>0,"empty lender");owner=msg.sender;lender=lender_;}
    function borrow(address token,uint256 amount,uint256 maximumFee,bytes calldata data) external onlyOwner {
        if(active||token.code.length==0)revert InvalidLoan();
        active=true;loanToken=token;loanAmount=amount;maxFee=maximumFee;
        require(IFlashLender(lender).flashLoan(address(this),token,amount,data),"loan failed");
        active=false;loanToken=address(0);loanAmount=0;maxFee=0;
        SafeTransfer.safeApprove(IERC20Minimal(token),lender,0);
    }
    function onFlashLoan(address initiator,address token,uint256 amount,uint256 fee,bytes calldata) external returns(bytes32){
        if(msg.sender!=lender)revert UntrustedLender(msg.sender);
        if(!active||initiator!=address(this)||token!=loanToken||amount!=loanAmount||fee>maxFee)revert InvalidLoan();
        uint256 repayment=amount+fee;require(IERC20Minimal(token).balanceOf(address(this))>=repayment,"insufficient repayment");
        SafeTransfer.safeApprove(IERC20Minimal(token),lender,0);
        SafeTransfer.safeApprove(IERC20Minimal(token),lender,repayment);
        emit Received(lender,token,amount,fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
    function rescueTokens(address token,uint256 amount) external onlyOwner {if(active)revert InvalidLoan();SafeTransfer.safeTransfer(IERC20Minimal(token),owner,amount);}
}
