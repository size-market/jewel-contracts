// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {IERC20, IJewelToken, ILockedJewelOffer, IOfferFactory, IOwnable} from "./interfaces/Interfaces.sol";

contract JewelLens {
    // supported stablecoins
    address public constant USDC = 0x985458E523dB3d53125813eD68c274899e9DfAb4;
    address public constant USDT = 0x3C2B8Be99c50593081EAA2A724F0B8285F5aba8f;
    address public constant DAI = 0xEf977d2f931C1978Db5F6747666fa1eACB0d0339;
    address public constant UST = 0x224e64ec1BDce3870a6a6c777eDd450454068FEC;
    address public constant BUSD = 0xE176EBE47d621b984a73036B9DA5d834411ef734;

    IJewelToken JEWEL = IJewelToken(0xEa589E93Ff18b1a1F1e9BaC7EF3E86Ab62addc79);

    function getVolume(IOfferFactory factory) public view returns (uint256 sum) {
        address[5] memory stables = [USDC, USDT, DAI, UST, BUSD];
        address factoryOwner = IOwnable(address(factory)).owner();

        uint256 volume;
        for (uint256 i; i < stables.length; i++) {
            volume += IERC20(stables[i]).balanceOf(factoryOwner) * (10**(18 - IERC20(stables[i]).decimals()));
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

    function getActiveOffersPruned(IOfferFactory factory) public view returns (ILockedJewelOffer[] memory) {
        ILockedJewelOffer[] memory activeOffers = factory.getActiveOffers();
        // determine size of memory array
        uint count;
        for (uint i; i < activeOffers.length; i++) {
            if (address(activeOffers[i]) != address(0)) {
                count++;
            }
        }
        ILockedJewelOffer[] memory pruned = new ILockedJewelOffer[](count);
        for (uint j; j < count; j++) {
            pruned[j] = activeOffers[j];
        }
        return pruned;
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
        ILockedJewelOffer[] memory activeOffers = getActiveOffersPruned(factory);
        uint256 offersLength = activeOffers.length;
        offerAddresses = new address[](offersLength);
        jewelBalances = new uint256[](offersLength);
        tokenWanted = new address[](offersLength);
        amountWanted = new uint256[](offersLength);
        for (uint256 i; i < activeOffers.length; i++) {
            jewelBalances[i] = JEWEL.totalBalanceOf(address(activeOffers[i]));
            offerAddresses[i] = address(activeOffers[i]);
            tokenWanted[i] = activeOffers[i].tokenWanted();
            amountWanted[i] = activeOffers[i].amountWanted();
        }
    }
}
