// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {LockedJewelOffer} from "../../LockedJewelOffer.sol";
import {IERC20} from "../../interfaces/Interfaces.sol";

contract OfferUser {
    function fillOffer(LockedJewelOffer offer) public {
        offer.fill();
    }

    function approve(address token, address user) public {
        IERC20(token).approve(user, type(uint256).max);
    }
}
