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

interface IOwnable {
    function owner() external view returns (address);
}

contract LockedJewelOffer {
    address immutable public factory;
    address immutable public seller;
    address immutable public tokenWanted;
    uint256 immutable public amountWanted;
    uint256 immutable public fee; // in bps

    IJewelToken JEWEL = IJewelToken(0x72Cb10C6bfA5624dD07Ef608027E366bd690048F);

    event OfferFilled(address buyer, uint256 jewelAmount, address token, uint256 tokenAmount);
    event OfferCanceled(uint256 jewelAmount);

    constructor(
        address _seller,
        address _tokenWanted,
        uint256 _amountWanted,
        uint256 _fee
    ) {
        factory = msg.sender;
        seller = _seller;
        tokenWanted = _tokenWanted;
        amountWanted = _amountWanted;
        fee = _fee;
    }

    // release trapped funds
    function withdrawTokens(address token) public {
        require(msg.sender == IOwnable(factory).owner());
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(IOwnable(factory).owner()).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            safeTransfer(token, IOwnable(factory).owner(), balance);
        }
    }

    function fill() public {
        require(hasJewel(), "no JEWEL balance");
        uint256 balance = JEWEL.totalBalanceOf(address(this));
        // cap txFee at 25k
        uint256 txFee = mulDiv(amountWanted, fee, 10_000);
        uint256 maxFee = 25_000 * 10 ** IERC20(tokenWanted).decimals();
        txFee = txFee > maxFee ? maxFee : txFee;

        uint256 amountAfterFee = amountWanted - txFee;
        // collect fee
        safeTransferFrom(tokenWanted, msg.sender, IOwnable(factory).owner(), txFee);
        // exchange assets
        safeTransferFrom(tokenWanted, msg.sender, seller, amountAfterFee);
        JEWEL.transferAll(msg.sender);
        emit OfferFilled(msg.sender, balance, tokenWanted, amountWanted);
    }

    function cancel() public {
        require(hasJewel(), "no JEWEL balance");
        require(msg.sender == seller);
        uint256 balance = JEWEL.totalBalanceOf(address(this));
        JEWEL.transferAll(seller);
        emit OfferCanceled(balance);
    }

    function hasJewel() public view returns (bool) {
        return JEWEL.totalBalanceOf(address(this)) > 0;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        return (x * y) / z;
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransfer: failed");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransferFrom: failed");
    }
}
