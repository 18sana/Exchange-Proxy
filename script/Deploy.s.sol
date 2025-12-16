// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/ExchangeUpgradeable.sol";
import "../src/Coins.sol";
import "../src/Assets.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        Coins coins = new Coins();
        Assets assets = new Assets();

        ExchangeUpgradeable exchangeImpl = new ExchangeUpgradeable(address(coins), address(assets));

        // Deploy ProxyAdmin
        address owner = msg.sender;
        ProxyAdmin proxyAdmin = new ProxyAdmin(owner);

        // Encode initializer call
        bytes memory data = abi.encodeWithSelector(ExchangeUpgradeable.initialize.selector);

        // Deploy Transparent Proxy
        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(address(exchangeImpl), address(proxyAdmin), data);

        coins.setExchange(address(proxy));
        assets.setExchange(address(proxy));

        vm.stopBroadcast();

        console.log("Exchange Proxy deployed at:", address(proxy));
    }
}
