// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

interface IJewelToken {
    function totalBalanceOf(address _holder) external view returns (uint256);
    function transferAll(address _to) external;
}

interface ILockedJewelOffer{
    function amountWanted() external view returns (uint256);
    function tokenWanted() external view returns (address);
}

interface IOfferFactory {
    function offers() external view returns (ILockedJewelOffer[] memory);
    function getActiveOffers() external view returns (ILockedJewelOffer[] memory);
}

contract JewelLens {

    IJewelToken JEWEL = IJewelToken(0x72Cb10C6bfA5624dD07Ef608027E366bd690048F);
    function getOfferInfo(ILockedJewelOffer otcSell) public view returns (uint jewelBalance, address tokenWanted, uint amountWanted) {
        return (JEWEL.totalBalanceOf(address(otcSell)), otcSell.tokenWanted(), otcSell.amountWanted());
    }

    function getAllActiveOfferInfo(IOfferFactory factory) public view returns (address[] memory offerAddresses, uint[] memory jewelBalances, address[] memory tokenWanted, uint[] memory amountWanted) {
        ILockedJewelOffer[] memory activeOffers = factory.getActiveOffers();
        uint offersLength = activeOffers.length;
        offerAddresses = new address[](offersLength);
        jewelBalances = new uint[](offersLength);
        tokenWanted = new address[](offersLength);
        amountWanted = new uint[](offersLength);
        uint count;
        for (uint i; i < activeOffers.length; i++) {
            uint bal = JEWEL.totalBalanceOf(address(activeOffers[i]));
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