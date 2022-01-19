// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import "@ds-test/test.sol";
import {OfferFactory} from "../OfferFactory.sol";
import {LockedJewelOffer} from "../LockedJewelOffer.sol";

interface IJewelToken {
    function totalBalanceOf(address _holder) external view returns (uint256);
    function transferAll(address _to) external;
}

contract LockedJewelMarketTest is DSTest {
    OfferFactory factory;
    address public USDC = 0x985458E523dB3d53125813eD68c274899e9DfAb4;
    IJewelToken JEWEL = IJewelToken(0x72Cb10C6bfA5624dD07Ef608027E366bd690048F);

    function setUp() public {
        factory = new OfferFactory(); // 250 bps, 2.5%
    }

    function testSetFee() public {
        assertEq(factory.fee(), 250);
        factory.setFee(350);
        assertEq(factory.fee(), 350);
    }

    function testFill() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 1000);
        // fund the contract
        JEWEL.transferAll(address(offer));
    }

    function testCreateOffer() public {
        factory.createOffer(USDC, 1);
    }
}
