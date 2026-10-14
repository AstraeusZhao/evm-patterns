// SPDX-License-Identifier: AGPL-3.0
/*
 * File: test/AuditRegression.t.sol
 * Studio: Smart Dolphin Studio
 * Author: AstraeusZhao
 * Email: AstraeusZhao@gmail.com
 * Description: Cross-contract audit regression tests.
 * Solidity: ^0.8.24
 * Updated: 2026-10-14
 * License: AGPL-3.0
 */
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {NFTMarketplace} from "../src/NFTMarketplace/NFTMarketplace.sol";
import {ERC721NFT} from "../src/ERC721NFT/ERC721NFT.sol";
import {ERC1155} from "../src/ERC1155/ERC1155.sol";
import {MultiSigWallet} from "../src/MultiSigWallet/MultiSigWallet.sol";
import {FlashLoanReceiver} from "../src/FlashLoanReceiver/FlashLoanReceiver.sol";
import {IERC20Minimal,SafeTransfer} from "../src/SafeERC20Wrapper/SafeERC20Wrapper.sol";
import {StakingVault} from "../src/StakingVault/StakingVault.sol";
import {EnglishAuction} from "../src/EnglishAuction/EnglishAuction.sol";
import {TimelockController} from "../src/TimelockController/TimelockController.sol";
import {ERC20Permit} from "../src/ERC20Permit/ERC20Permit.sol";
import {EIP712} from "../src/EIP712/EIP712.sol";
import {GovernanceToken} from "../src/GovernanceToken/GovernanceToken.sol";
import {VestingWallet} from "../src/VestingWallet/VestingWallet.sol";
import {FactoryClone} from "../src/FactoryClone/FactoryClone.sol";
import {SimpleProxy} from "../src/UUPSProxy/UUPSProxy.sol";
import {BondingCurve} from "../src/BondingCurve/BondingCurve.sol";
import {FrontRunning} from "../src/FrontRunning/FrontRunning.sol";
import {Royalty} from "../src/Royalty/Royalty.sol";
import {AMM} from "../src/AMM/AMM.sol";
import {PriceOracle} from "../src/PriceOracle/PriceOracle.sol";
import {BatchMint} from "../src/BatchMint/BatchMint.sol";
import {ERC20Token} from "../src/ERC20Token/ERC20Token.sol";
import {Multicall} from "../src/Multicall/Multicall.sol";
contract FalseToken {function balanceOf(address) external pure returns(uint256){return 100;}function transfer(address,uint256) external pure returns(bool){return false;}}
contract SafeHarness {function transfer(address token) external {SafeTransfer.safeTransfer(IERC20Minimal(token),msg.sender,1);}}
contract RejectBidder {function bid(EnglishAuction a) external payable {a.bid{value:msg.value}();}receive() external payable {revert("reject");}}
contract MockLender {function flashLoan(address,address,uint256,bytes calldata) external pure returns(bool){return true;}}
contract AuditRegression is Test {
 address constant A=address(0xa11ce);address constant B=address(0xb0b);address constant F=address(0xfee);
 receive() external payable {}
 function testMarketplaceDeliversNFTAndPaysSellerFromMemory() public {
  ERC721NFT nft=new ERC721NFT("N","N");NFTMarketplace m=new NFTMarketplace(F,250);
  nft.mint(A,1);vm.prank(A);nft.approve(address(m),1);vm.prank(A);m.list(address(nft),1,1 ether);
  vm.deal(B,2 ether);vm.prank(B);m.buy{value:1 ether}(address(nft),1);
  assertEq(nft.ownerOf(1),B);assertEq(A.balance,0.975 ether);assertEq(F.balance,0.025 ether);assertEq(address(m).balance,0);
 }
 function testMarketplaceRejectsUnauthorizedListingStaleApprovalAndOverpayment() public {
  ERC721NFT nft=new ERC721NFT("N","N");NFTMarketplace m=new NFTMarketplace(F,0);nft.mint(A,1);
  vm.prank(B);vm.expectRevert();m.list(address(nft),1,1 ether);
  vm.prank(A);nft.approve(address(m),1);vm.prank(A);m.list(address(nft),1,1 ether);
  vm.deal(B,2 ether);vm.prank(B);vm.expectRevert();m.buy{value:2 ether}(address(nft),1);
  vm.prank(A);nft.approve(address(0),1);vm.prank(B);vm.expectRevert();m.buy{value:1 ether}(address(nft),1);
  vm.expectRevert();new NFTMarketplace(F,10001);
 }
 function testMultisigRejectsSingleOwnerAdminAndZeroConstructorOwner() public {
  address[] memory owners=new address[](2);owners[0]=A;owners[1]=B;MultiSigWallet w=new MultiSigWallet(owners,2);
  vm.prank(A);vm.expectRevert();w.changeRequired(1);
  vm.prank(A);uint256 pending=w.submitTransaction(B,0,"");vm.prank(B);w.confirmTransaction(pending);
  vm.prank(A);uint256 admin=w.submitTransaction(address(w),0,abi.encodeCall(MultiSigWallet.removeOwner,(B)));
  vm.prank(B);w.confirmTransaction(admin);vm.prank(A);w.executeTransaction(admin);
  vm.prank(A);vm.expectRevert();w.executeTransaction(pending);assertEq(w.required(),1);
  owners[1]=address(0);vm.expectRevert();new MultiSigWallet(owners,2);
 }
 function testFlashCallbackCannotGrantAnAttackerAllowance() public {
  FlashLoanReceiver r=new FlashLoanReceiver(address(new MockLender()));
  FalseToken token=new FalseToken();vm.prank(A);vm.expectRevert();r.onFlashLoan(address(r),address(token),10,0,"");
 }
 function testStakingUnfundedRewardsNeverSpendPrincipalAndRestakeIsConstantWork() public {
  StakingVault v=new StakingVault();v.setRewardRate(1e18);vm.deal(A,2 ether);vm.prank(A);v.stake{value:1 ether}();
  vm.warp(block.timestamp+100);vm.prank(A);vm.expectRevert();v.claimRewards();
  vm.prank(A);v.unstake(1 ether);assertEq(A.balance,2 ether);
  vm.deal(address(this),1 ether);v.fundRewards{value:1 ether}();
  vm.prank(A);v.stake{value:1 ether}();vm.warp(block.timestamp+10);vm.prank(A);v.claimRewards();
  assertEq(v.totalStaked(),1 ether);assertEq(address(v).balance,1 ether);vm.prank(A);v.unstake(1 ether);
 }
 function testRejectingOutbidderCannotBlockAuction() public {
  EnglishAuction a=new EnglishAuction(1 days);RejectBidder r=new RejectBidder();vm.deal(address(this),3 ether);
  r.bid{value:1 ether}(a);a.bid{value:2 ether}();assertEq(a.highestBidder(),address(this));assertEq(a.refunds(address(r)),1 ether);
 }
 function testTimelockNeverSetAndCancelledPredecessorsAreNotDone() public {
  address[] memory accounts=new address[](0);TimelockController t=new TimelockController(1 hours,accounts,accounts,address(this));
  bytes32 salt=bytes32("a");bytes memory data="";bytes32 id=t.hashOperation(A,0,data,0,salt);
  vm.expectRevert();t.schedule(B,0,data,id,bytes32("b"));t.schedule(A,0,data,0,salt);t.cancel(A,0,data,0,salt);
  vm.expectRevert();t.schedule(B,0,data,id,bytes32("b"));vm.expectRevert();t.updateDelay(0);
 }
 function testSafeNFTAndMultiTokenRejectNonReceiversAndEnforceMintRole() public {
  ERC721NFT nft=new ERC721NFT("N","N");nft.mint(A,1);vm.prank(A);vm.expectRevert();nft.safeTransferFrom(A,address(this),1);assertEq(nft.ownerOf(1),A);
  ERC1155 multi=new ERC1155();multi.mint(A,1,2);vm.prank(B);vm.expectRevert();multi.mint(B,1,1);
  vm.prank(A);vm.expectRevert();multi.safeTransferFrom(A,address(this),1,1);vm.prank(A);multi.safeTransferFrom(A,B,1,0);
  assertEq(multi.balanceOf(A,1),2);vm.prank(A);vm.expectRevert();multi.safeTransferFrom(A,address(0),1,1);
 }
 function testZeroSignerInvalidPermitAndTypedSignatureRejected() public {
  ERC20Permit p=new ERC20Permit("N","N");vm.expectRevert();p.permit(address(0),A,1,block.timestamp,27,0,0);
  EIP712 e=new EIP712("N","1");EIP712.Transfer memory data=EIP712.Transfer(A,1,0,block.timestamp);
  vm.expectRevert();e.executeTransfer(address(0),data,27,0,0);
 }
 function testVotesCannotTruncateAndTokenFalseCannotReleaseVesting() public {
  GovernanceToken g=new GovernanceToken("N","N");vm.expectRevert();g.mint(A,uint256(type(uint224).max)+1);
  FalseToken token=new FalseToken();VestingWallet v=new VestingWallet(A,0,1);vm.warp(2);
  vm.expectRevert();v.release(address(token));assertEq(v.released(address(token)),0);
 }
 function testTokenAndImplementationMustContainCode() public {
  SafeHarness h=new SafeHarness();vm.expectRevert();h.transfer(A);vm.expectRevert();new FactoryClone(A);vm.expectRevert();new SimpleProxy(A);
 }
 function testCurveRejectsZeroOutputAndHonorsMinOutDeadline() public {
  BondingCurve c=new BondingCurve();vm.deal(address(this),10000);c.buy{value:5000}();
  vm.expectRevert();c.buy{value:1}();vm.expectRevert();c.buy{value:100}(1000,block.timestamp);
  vm.expectRevert();c.buy{value:100}(1,block.timestamp-1);
 }
 function testCommitmentsAreIndependentDomainBoundAndExpire() public {
  FrontRunning c=new FrontRunning();bytes32 salt=bytes32("s");
  bytes32 ha=c.commitmentHash(A,1,salt);bytes32 hb=c.commitmentHash(B,2,salt);vm.prank(A);c.commit(ha);vm.prank(B);c.commit(hb);
  vm.roll(block.number+1);vm.prank(A);c.reveal(1,salt);vm.warp(block.timestamp+1 days+1);c.clearExpired(B);
  bytes32 hc=c.commitmentHash(B,3,salt);vm.prank(B);c.commit(hc);
 }
 function testRoyaltyERC165OracleInitializationAndZeroTransfers() public {
  Royalty r=new Royalty(A,500);assertTrue(r.supportsInterface(0x01ffc9a7));assertFalse(r.supportsInterface(0xffffffff));
  PriceOracle o=new PriceOracle();vm.warp(1);vm.expectRevert();o.getPrice(A);
  ERC20Token token=new ERC20Token("N","N");assertTrue(token.transfer(A,0));assertTrue(token.transferFrom(A,B,0));
 }
 function testSimulationsRejectUnsettledEtherAndBatchRejectsZeroAddress() public {
  AMM a=new AMM();Multicall m=new Multicall();vm.deal(address(this),2);
  (bool ok,)=address(a).call{value:1}(abi.encodeCall(AMM.addLiquidity,(1,1)));assertFalse(ok);
  Multicall.Call[] memory calls=new Multicall.Call[](0);(ok,)=address(m).call{value:1}(abi.encodeCall(Multicall.multicall,(calls)));assertFalse(ok);
  BatchMint b=new BatchMint();address[] memory recipients=new address[](1);uint256[] memory amounts=new uint256[](1);amounts[0]=1;
  vm.expectRevert();b.batchMint(recipients,amounts);vm.expectRevert();b.batchTransfer(recipients,amounts);
 }
}
