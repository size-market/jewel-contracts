// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {LockedJewelOffer} from "./LockedJewelOffer.sol";

contract OfferFactory is Ownable {
    uint256 public fee = 250; // in bps
    LockedJewelOffer[] public offers;

    event OfferCreated(address offerAddress, address tokenWanted, uint256 amountWanted);

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function createOffer(address _tokenWanted, uint256 _amountWanted) public returns (LockedJewelOffer) {
        LockedJewelOffer offer = new LockedJewelOffer(msg.sender, _tokenWanted, _amountWanted, fee);
        offers.push(offer);
        emit OfferCreated(address(offer), _tokenWanted, _amountWanted);
        return offer;
    }

    function getActiveOffersByOwner() public view returns (LockedJewelOffer[] memory, LockedJewelOffer[] memory) {
        uint256 offersLength = offers.length;

        LockedJewelOffer[] memory myBids = new LockedJewelOffer[](offersLength);
        LockedJewelOffer[] memory otherBids = new LockedJewelOffer[](offersLength);

        uint256 myBidsCount;
        uint256 otherBidsCount;

        for (uint256 i; i < offers.length; i++) {
            LockedJewelOffer offer = LockedJewelOffer(offers[i]);
            if (offer.hasJewel() && !offer.hasEnded()) {
                if (offer.seller() == msg.sender) {
                    myBids[myBidsCount++] = offers[i];
                } else {
                    otherBids[otherBidsCount++] = offers[i];
                }
            }
        }

        return (myBids, otherBids);
    }

    function getActiveOffers() public view returns (LockedJewelOffer[] memory) {

        LockedJewelOffer[] memory activeOffers = new LockedJewelOffer[](offers.length);
        uint256 count;
        for (uint256 i; i < offers.length; i++) {
            LockedJewelOffer offer = LockedJewelOffer(offers[i]);
            if (offer.hasJewel() && !offer.hasEnded()) {
                activeOffers[count++] = offer;
            }
        }

        return activeOffers;
    }

    function getActiveOffersByRange(uint256 start, uint256 end) public view returns (LockedJewelOffer[] memory) {
        LockedJewelOffer[] memory activeOffers = new LockedJewelOffer[](end - start);

        uint256 count;

        for (uint256 i = start; i < end; i++) {

            if (offers[i].hasJewel() && !offers[i].hasEnded()) {
                activeOffers[count++] = offers[i];
            }
        }

        return activeOffers;
    }
}
