// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {LockedJewelOffer} from "../../LockedJewelOffer.sol";
import {OfferFactory} from "../../OfferFactory.sol";

contract FactoryDeployer {
    OfferFactory public factory;

    constructor() {
        factory = new OfferFactory();
    }

    function setFee(uint256 f) public {
        factory.setFee(f);
    }

    function withdraw(LockedJewelOffer offer, address token) public {
        offer.withdrawTokens(token);
    }
}
