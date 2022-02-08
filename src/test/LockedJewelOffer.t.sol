// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {DSTest} from "@ds-test/test.sol";

import {IERC20, IJewelToken} from "../interfaces/Interfaces.sol";
import {OfferFactory} from "../OfferFactory.sol";
import {LockedJewelOffer} from "../LockedJewelOffer.sol";

import {FactoryDeployer} from "./user/FactoryDeployer.sol";
import {Trader} from "./user/Trader.sol";
import {Vm} from "./util/Vm.sol";

contract LockedJewelOfferTest is DSTest {
    OfferFactory factory;

    FactoryDeployer factoryDeployer;
    Trader trader;

    Vm constant VM = Vm(HEVM_ADDRESS);

    address public constant USDC = 0x985458E523dB3d53125813eD68c274899e9DfAb4;
    IJewelToken JEWEL = IJewelToken(0xEa589E93Ff18b1a1F1e9BaC7EF3E86Ab62addc79);

    function setUp() public {
        factoryDeployer = new FactoryDeployer();
        trader = new Trader();

        factory = factoryDeployer.factory();

        // give us 100k locked JEWEL to work with
        VM.store(address(JEWEL), keccak256(abi.encode(address(this), 13)), bytes32(uint256(100_000 * 1e18)));
        emit log_uint(JEWEL.totalBalanceOf(address(this)));

        // fund the offer user with 1m usdc
        VM.store(address(USDC), keccak256(abi.encode(address(trader), 0)), bytes32(uint256(1_000_000 * 1e6)));
    }

    function testFailFillNoApproval() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 5 * 1e6);

        // fund the contract
        JEWEL.transferAll(address(offer));

        trader.fillOffer(offer);
    }

    function testFailFillCantAfford() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 11 * 1e6);

        // fund the contract
        JEWEL.transferAll(address(offer));

        // would cost 1.1m USDC but we only have 1.0m
        trader.fillOffer(offer);
    }

    function testFill() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 5 * 1e6);

        // fund the contract
        JEWEL.transferAll(address(offer));
        // approve USDC spending
        trader.approve(USDC, address(offer));

        uint256 prevBal = JEWEL.totalBalanceOf(address(offer));

        trader.fillOffer(offer);

        uint256 txFee = (5 * 1e6 * offer.fee()) / 10_000;
        uint256 maxFee = 25_000 * 1e6;
        txFee = txFee > maxFee ? maxFee : txFee;

        // buyer gets JEWEL
        assertEq(JEWEL.totalBalanceOf(address(trader)), prevBal);
        // trader gets USDC
        assertEq(IERC20(USDC).balanceOf(address(this)), 5 * 1e6 - txFee);
        // factory deployer gets fee
        assertEq(IERC20(USDC).balanceOf(address(factoryDeployer)), txFee);
    }

    function testWithdraw() public {
        LockedJewelOffer offer = factory.createOffer(USDC, 5 * 1e6);

        trader.approve(USDC, address(this));
        // transfer 1000 USDC to offer
        IERC20(USDC).transferFrom(address(trader), address(offer), 1000 * 1e6);

        // withdraw the lost USDC to the deployer
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
        // transfer all of our locked JEWEL
        JEWEL.transferAll(address(offer));
        // sanity check
        assertEq(JEWEL.totalBalanceOf(address(this)), 0);
        // get our locked JEWEL back by cancelling
        offer.cancel();

        assertEq(preBal, JEWEL.totalBalanceOf(address(this)));
    }
}
