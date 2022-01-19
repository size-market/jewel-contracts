// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);
}

interface IJewelToken {
    function totalBalanceOf(address _holder) external view returns (uint256);

    function transferAll(address _to) external;
}

interface ILockedJewelOffer {
    function amountWanted() external view returns (uint256);

    function tokenWanted() external view returns (address);
}

interface IOfferFactory {
    function offers() external view returns (ILockedJewelOffer[] memory);

    function getActiveOffers() external view returns (ILockedJewelOffer[] memory);
}

interface IOwnable {
    function owner() external view returns (address);
}
