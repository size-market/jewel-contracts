// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

interface IERC20 {
    function balanceOf(address _holder) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
}

interface IJewelToken {
    function totalBalanceOf(address _holder) external view returns (uint256);

    function transferAll(address _to) external;

    function lockOf(address _holder) external view returns (uint256);
}

interface ILockedJewelOffer {
    function amountWanted() external view returns (uint256);

    function tokenWanted() external view returns (address);

    function seller() external view returns (address);
}

interface IOfferFactory {
    function offers() external view returns (ILockedJewelOffer[] memory);

    function getActiveOffers() external view returns (ILockedJewelOffer[] memory);

    function getActiveOffersByRange(uint256 start, uint256 end) external view returns (ILockedJewelOffer[] memory);
}

interface IOwnable {
    function owner() external view returns (address);
}
