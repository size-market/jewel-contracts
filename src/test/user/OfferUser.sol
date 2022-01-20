// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {LockedJewelOffer} from "../../LockedJewelOffer.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}


contract OfferUser {

    function fillOffer(LockedJewelOffer offer) public {
        offer.fill();
    }

    function approve(address token, address user) public {
        IERC20(token).approve(user, type(uint).max);
    }
}
