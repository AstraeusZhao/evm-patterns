// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {EnglishAuction} from "../../src/EnglishAuction/EnglishAuction.sol";


contract EnglishAuctionTest is Test {

    address private constant SELLER = address(0xB055);
    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);

    function _auction() internal returns (EnglishAuction) {
        vm.deal(ALICE, 10 ether);
        vm.deal(BOB, 10 ether);
        vm.prank(SELLER);
        return new EnglishAuction(1 days);
    }

    function testBidAndOutbid() external {
        EnglishAuction a = _auction();
        vm.prank(ALICE);
        a.bid{value: 1 ether}();
        require(a.highestBidder() == ALICE, "first bidder not recorded");

        vm.prank(BOB);
        a.bid{value: 2 ether}();
        require(a.highestBidder() == BOB, "second bidder not recorded");
        require(a.refunds(ALICE) == 1 ether, "missing refund credit");
        vm.prank(ALICE);a.withdrawRefund();
        require(ALICE.balance == 10 ether, "outbid bidder not refunded");
        require(a.highestBid() == 2 ether, "highest bid wrong");
    }

    function testLowBidRejected() external {
        EnglishAuction a = _auction();
        vm.prank(ALICE);
        a.bid{value: 2 ether}();
        vm.expectRevert();
        vm.prank(BOB);
        a.bid{value: 1 ether}();
    }

    function testCannotBidAfterEnd() external {
        EnglishAuction a = _auction();
        vm.warp(block.timestamp + 1 days + 1);
        vm.expectRevert();
        vm.prank(ALICE);
        a.bid{value: 1 ether}();
    }

    function testEndAndWithdraw() external {
        EnglishAuction a = _auction();
        vm.prank(ALICE);
        a.bid{value: 3 ether}();
        vm.warp(block.timestamp + 1 days);
        a.end();
        vm.prank(SELLER);
        a.withdraw();
        require(SELLER.balance == 3 ether, "seller not paid");
    }

    function testCannotWithdrawBeforeEnd() external {
        EnglishAuction a = _auction();
        vm.prank(ALICE);
        a.bid{value: 1 ether}();
        vm.expectRevert();
        vm.prank(SELLER);
        a.withdraw();
    }

    function testReentrantBidderCannotCorruptState() external {
        EnglishAuction a = _auction();

        // A malicious bidder contract re-enters bid() from its receive()
        // while being refunded. With checks-effects-interactions the
        // re-entering bid competes against the already-updated state and
        // the auction ends with a single consistent winner and balance.
        ReentrantBidder attacker = new ReentrantBidder();
        vm.deal(address(attacker), 10 ether);

        vm.prank(ALICE);
        a.bid{value: 1 ether}();
        attacker.attack{value: 2 ether}(a);

        vm.prank(BOB);
        a.bid{value: 3 ether}();
        require(!attacker.reentered(), "bid must not call previous bidder");

        require(a.highestBidder() == BOB, "outbidder must win");
        require(a.highestBid() == 3 ether, "winning bid not recorded");
        require(address(a).balance == 6 ether, "contract balance inconsistent");

        vm.warp(block.timestamp + 1 days);
        a.end();
        vm.prank(SELLER);
        a.withdraw();
        require(SELLER.balance == 3 ether, "seller underpaid");
        require(address(a).balance == a.refunds(ALICE) + a.refunds(address(attacker)), "refund liabilities mismatch");
    }
}

/// @notice Malicious bidder that re-enters bid() on every refund.
contract ReentrantBidder {
    EnglishAuction public auction;
    bool public reentered;

    receive() external payable {
        if (!reentered) {
            reentered = true;
            auction.bid{value: 4 ether}();
        }
    }

    function attack(EnglishAuction a) external payable {
        auction = a;
        a.bid{value: msg.value}();
    }
}
