// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {DSTest} from "@ds-test/test.sol";

import {OfferFactory} from "../OfferFactory.sol";
import {LockedJewelOffer} from "../LockedJewelOffer.sol";
import {IERC20, IJewelToken} from "../interfaces/Interfaces.sol";

import {OfferUser} from "./user/OfferUser.sol";
import {FactoryDeployer} from "./user/FactoryDeployer.sol";
import {Vm} from "./util/Vm.sol";

contract LockedJewelOfferTest is DSTest {
    OfferFactory factory;

    FactoryDeployer factoryDeployer;
    OfferUser offerUser;

    address public USDC = 0x985458E523dB3d53125813eD68c274899e9DfAb4;
    IJewelToken JEWEL = IJewelToken(0x72Cb10C6bfA5624dD07Ef608027E366bd690048F);
    Vm constant VM = Vm(HEVM_ADDRESS);

    function setUp() public {
        factoryDeployer = new FactoryDeployer();
        factory = factoryDeployer.factory();

        offerUser = new OfferUser();

        //Give us 100k locked jewel to work with
        VM.store(address(JEWEL), keccak256(abi.encode(address(this), 15)), bytes32(uint256(100000 * 1e18)));

        //Fund the offer user with 1m usdc
        VM.store(address(USDC), keccak256(abi.encode(address(offerUser), 0)), bytes32(uint256(1000000 * 1e6)));
    }

    function testFailFillNoApproval() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 5 * 1e6);
        // fund the contract
        JEWEL.transferAll(address(offer));

        offerUser.fillOffer(offer);
    }

    function testFailFillCantAfford() public {
        //Would cost 1.1m USDC
        LockedJewelOffer offer = factory.createOffer(USDC, 11 * 1e6);
        // fund the contract
        JEWEL.transferAll(address(offer));

        offerUser.fillOffer(offer);
    }

    function testFill() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 5 * 1e6);
        // fund the contract
        JEWEL.transferAll(address(offer));
        //approve USDC spending
        offerUser.approve(USDC, address(offer));

        uint256 prevBal = JEWEL.totalBalanceOf(address(offer));

        offerUser.fillOffer(offer);

        uint256 txFee = (5 * 1e6 * offer.fee()) / 10_000;
        uint256 maxFee = 25_000 * 1e6;
        txFee = txFee > maxFee ? maxFee : txFee;

        //Offer Filler gets JEWEl
        assertEq(JEWEL.totalBalanceOf(address(offerUser)), prevBal);
        //Offer seller gets USDC
        assertEq(IERC20(USDC).balanceOf(address(this)), 5 * 1e6 - txFee);
        //Factory Deployer gets fee
        assertEq(IERC20(USDC).balanceOf(address(factoryDeployer)), txFee);
    }

    function testWithdraw() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 5 * 1e6);

        offerUser.approve(USDC, address(this));
        //transfer 1000 USDC to offer
        IERC20(USDC).transferFrom(address(offerUser), address(offer), 1000 * 1e6);

        //withdraw the lost USDC to the deployer
        factoryDeployer.withdraw(offer, USDC);

        assertEq(IERC20(USDC).balanceOf(address(factoryDeployer)), 1000 * 1e6);
    }

    function testFailCancel() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 5 * 1e6);
        offer.cancel();
    }

    function testCancel() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 5 * 1e6);

        uint256 preBal = JEWEL.totalBalanceOf(address(this));
        //Transfer all of our locked Jewel
        JEWEL.transferAll(address(offer));
        //sanity check
        assertEq(JEWEL.totalBalanceOf(address(this)), 0);
        //Get our locked jewel back by cancelling
        offer.cancel();

        assertEq(preBal, JEWEL.totalBalanceOf(address(this)));
    }
}
