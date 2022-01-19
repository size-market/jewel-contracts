// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {IJewelToken, ILockedJewelOffer, IOfferFactory} from "./interfaces/Interfaces.sol";

contract JewelLens {
    IJewelToken JEWEL = IJewelToken(0x72Cb10C6bfA5624dD07Ef608027E366bd690048F);

    function getOfferInfo(ILockedJewelOffer offer)
        public
        view
        returns (
            uint256 jewelBalance,
            address tokenWanted,
            uint256 amountWanted
        )
    {
        return (JEWEL.totalBalanceOf(address(offer)), offer.tokenWanted(), offer.amountWanted());
    }

    function getAllActiveOfferInfo(IOfferFactory factory)
        public
        view
        returns (
            address[] memory offerAddresses,
            uint256[] memory jewelBalances,
            address[] memory tokenWanted,
            uint256[] memory amountWanted
        )
    {
        ILockedJewelOffer[] memory activeOffers = factory.getActiveOffers();
        uint256 offersLength = activeOffers.length;
        offerAddresses = new address[](offersLength);
        jewelBalances = new uint256[](offersLength);
        tokenWanted = new address[](offersLength);
        amountWanted = new uint256[](offersLength);
        uint256 count;
        for (uint256 i; i < activeOffers.length; i++) {
            uint256 bal = JEWEL.totalBalanceOf(address(activeOffers[i]));
            if (bal > 0) {
                jewelBalances[count] = bal;
                offerAddresses[count] = address(activeOffers[i]);
                tokenWanted[count] = activeOffers[i].tokenWanted();
                amountWanted[count] = activeOffers[i].amountWanted();
                count++;
            }
        }
    }
}
