// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {Test} from "forge-std/Test.sol";

import {IOfferFactory} from "../interfaces/Interfaces.sol";
import {OfferFactory} from "../OfferFactory.sol";
import {LockedJewelOffer} from "../LockedJewelOffer.sol";
import {JewelLens} from "../JewelLens.sol";

contract OfferFactoryTest is Test {
    OfferFactory factory;

    address public USDC = 0x985458E523dB3d53125813eD68c274899e9DfAb4;

    function setUp() public {
        factory = new OfferFactory();
    }

    function testLens() public {
        JewelLens lens = new JewelLens();
        lens.getAllActiveOfferPruneAndInfoRanged(IOfferFactory(0x35E5f6A5Fe9Bf288b72F469AD17DB5C772C96c96), 0, 100);
        // vm.etch(0x35E5f6A5Fe9Bf288b72F469AD17DB5C772C96c96, type(OfferFactory).runtimeCode);
        // emit log_uint(OfferFactory(0x35E5f6A5Fe9Bf288b72F469AD17DB5C772C96c96).getLen());
    }

    function testSetFee() public {
        assertEq(factory.fee(), 250);
        factory.setFee(350);
        assertEq(factory.fee(), 350);
    }

    function testSetFeeDoesntPropagate() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 1000);

        uint256 oldFee = offer.fee();
        factory.setFee(oldFee + 100);
        assertEq(oldFee, offer.fee());
        assertTrue(oldFee != factory.fee());
    }

    function testCreateOffer() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 10);

        assertEq(address(factory.offers(0)), address(offer));
        assertEq(offer.factory(), address(factory));
        assertEq(offer.seller(), address(this));
        assertEq(offer.tokenWanted(), USDC);
        assertEq(offer.amountWanted(), 10);
    }
}
