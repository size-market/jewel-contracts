// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import "./LockedJewelOffer.sol";
import "./OfferFactory.sol";

interface ILockedJewelOffer{
    function amountWanted() external view returns (uint256);
    function tokenWanted() external view returns (address);
}

interface IOfferFactory {
    function offers() external view returns (ILockedJewelOffer[] memory);
}

contract JewelLens {

    IJewelToken JEWEL = IJewelToken(0x72Cb10C6bfA5624dD07Ef608027E366bd690048F);
    function getOfferInfo(ILockedJewelOffer otcSell) public view returns (uint jewelBalance, address tokenWanted, uint amountWanted) {
        return (JEWEL.totalBalanceOf(address(otcSell)), otcSell.tokenWanted(), otcSell.amountWanted());
    }

    function getAllActiveOfferInfo(IOfferFactory factory) public view returns (uint[] memory jewelBalances, address[] memory tokenWanted, uint[] memory amountWanted) {
        uint offersLength = factory.offers().length;
        jewelBalances = new uint[](offersLength);
        tokenWanted = new address[](offersLength);
        amountWanted = new uint[](offersLength);
        uint count;
        for (uint i; i < offersLength; i++) {
            uint bal = JEWEL.totalBalanceOf(address(factory.offers()[i]));
            if (bal > 0) {
                jewelBalances[count] = bal;
            }
            tokenWanted[count] = factory.offers()[i].tokenWanted();
            amountWanted[count] = factory.offers()[i].amountWanted();
            count++;
        }
        return (jewelBalances, tokenWanted, amountWanted);
    }

}