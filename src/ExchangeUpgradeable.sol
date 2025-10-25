// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./Coins.sol";
import "./Assets.sol";

/// @title Upgradeable Exchange Contract for swapping Coins with Assets
/// @notice Enables users to purchase ERC721 Assets using ERC20 Coins at the set price
contract ExchangeUpgradeable is Initializable, ReentrancyGuardUpgradeable {
    /// @dev Set once in the implementation constructor so token contracts are trusted callees
    Coins public immutable coins;
    Assets public immutable assets;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address coinsAddress, address assetsAddress) {
        coins = Coins(coinsAddress);
        assets = Assets(assetsAddress);
        _disableInitializers();
    }

    /// @notice Initializer for the proxy instance
    function initialize() public initializer {
        __ReentrancyGuard_init();
    }

    /// @notice Buy an Asset (ERC721) by paying in Coins
    /// @dev Requires prior approval for the Exchange contract to spend buyer's Coins
    /// @param tokenId The ID of the Asset to purchase
    function buyAsset(uint256 tokenId) external nonReentrant {
        _buyAsset(tokenId);
    }

    /// @dev External calls are isolated here; entry point is guarded by {nonReentrant}
    function _buyAsset(uint256 tokenId) private {
        uint256 price = assets.getAssetPrice(tokenId);
        require(price > 0, "Price not set");

        address seller = assets.ownerOf(tokenId);
        require(seller != address(0), "Invalid seller");
        require(seller != msg.sender, "Already the owner");

        address buyer = msg.sender;

        coins.transferByExchange(buyer, seller, price);
        assets.transferByExchange(seller, buyer, tokenId);
    }
}
