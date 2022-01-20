// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {IERC20, IJewelToken, ILockedJewelOffer, IOfferFactory, IOwnable} from "./interfaces/Interfaces.sol";

contract JewelLens {
    IJewelToken JEWEL = IJewelToken(0x72Cb10C6bfA5624dD07Ef608027E366bd690048F);

    function getVolume(IOfferFactory factory) public view returns (uint sum){
        uint volume;
        address[5] memory stables = [0x224e64ec1BDce3870a6a6c777eDd450454068FEC, 0x3C2B8Be99c50593081EAA2A724F0B8285F5aba8f,
                                    0x985458E523dB3d53125813eD68c274899e9DfAb4, 0xEf977d2f931C1978Db5F6747666fa1eACB0d0339,
                                    0xE176EBE47d621b984a73036B9DA5d834411ef734];
        for(uint i; i < stables.length; i++) {
            volume += IERC20(stables[i]).balanceOf(IOwnable(address(factory)).owner()) * (10**(18 - IERC20(stables[i]).decimals()));
        }
        sum = volume * 40;
    }

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
