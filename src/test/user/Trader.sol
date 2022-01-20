// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {IERC20} from "../../interfaces/Interfaces.sol";
import {LockedJewelOffer} from "../../LockedJewelOffer.sol";

contract Trader {
    function fillOffer(LockedJewelOffer offer) public {
        offer.fill();
    }

    function approve(address token, address user) public {
        IERC20(token).approve(user, type(uint256).max);
    }
}
