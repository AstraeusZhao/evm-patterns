// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {EnglishAuction} from "../../src/EnglishAuction/EnglishAuction.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
    function prank(address sender) external;
    function warp(uint256 newTimestamp) external;
    function expectRevert() external;
}

contract EnglishAuctionTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

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
        require(attacker.reentered(), "attacker never re-entered");

        require(a.highestBidder() == address(attacker), "re-entering bid lost");
        require(a.highestBid() == 4 ether, "re-entering bid not recorded");
        require(address(a).balance == 4 ether, "contract balance inconsistent");

        vm.warp(block.timestamp + 1 days);
        a.end();
        vm.prank(SELLER);
        a.withdraw();
        require(SELLER.balance == 4 ether, "seller underpaid");
        require(address(a).balance == 0, "funds stuck in contract");
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
