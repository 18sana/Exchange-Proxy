// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/Coins.sol";
import "../src/Assets.sol";
import "../src/ExchangeUpgradeable.sol";

contract ExchangeTest is Test {
    Coins coins;
    Assets assets;
    ExchangeUpgradeable exchange; // <-- Fixed
    address owner;
    address seller;
    address buyer;

    function setUp() public {
        owner = address(this);
        seller = makeAddr("seller");
        buyer = makeAddr("buyer");

        // Deploy contracts
        coins = new Coins();
        assets = new Assets();

        ExchangeUpgradeable impl = new ExchangeUpgradeable(address(coins), address(assets));
        bytes memory initData = abi.encodeWithSelector(ExchangeUpgradeable.initialize.selector);
        exchange = ExchangeUpgradeable(address(new ERC1967Proxy(address(impl), initData)));

        coins.setExchange(address(exchange));
        assets.setExchange(address(exchange));

        // Mint coins to buyer
        coins.mint(buyer, 100 ether);

        // Mint NFT (asset) to seller
        vm.prank(seller);
        assets.mint(seller, 1);
    }

    function testSetAssetPrice() public {
        vm.prank(seller);
        assets.setAssetPrice(1, 10 ether);

        // Check price set
        assertEq(assets.getAssetPrice(1), 10 ether);
    }

    function testBuyAsset() public {
        // Seller sets price
        vm.prank(seller);
        assets.setAssetPrice(1, 10 ether);

        // Seller approves Exchange contract to transfer NFT
        vm.prank(seller);
        assets.approve(address(exchange), 1);

        // Buyer approves Exchange contract to spend Coins
        vm.prank(buyer);
        coins.approve(address(exchange), 10 ether);

        // Buyer buys asset
        vm.prank(buyer);
        exchange.buyAsset(1);

        // Buyer should now own NFT
        assertEq(assets.ownerOf(1), buyer);

        // Seller should receive coins
        assertEq(coins.balanceOf(seller), 10 ether);

        // Buyer balance should decrease
        assertEq(coins.balanceOf(buyer), 100 ether - 10 ether);
    }

    function testBuyAssetRevertsIfPriceNotSet() public {
        // Buyer approves Exchange contract to spend Coins
        vm.prank(buyer);
        coins.approve(address(exchange), 10 ether);

        // Attempt to buy NFT with price not set
        vm.prank(buyer);
        vm.expectRevert("Price not set");
        exchange.buyAsset(1);
    }
}
