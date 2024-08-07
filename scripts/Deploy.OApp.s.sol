
/**
 *  forge script script/Deploy.s.sol --rpc-url https://avalanche.drpc.org --private-key private_key  --broadcast  --verify --chain-id 43114 --ffi --etherscan-api-key 

 */
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../contracts/VemoWalletOApp.sol";

// 0x96f0445246B19Fa098f8bb4dfA907eD38F6155d5
contract DeployOApp is Script {
    // a Prime
    uint256 salt = 0x8cb91e82a3386d28036d6f63d1e6efd90031d3e8a56e75da9f0b021f40b0bc4c;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        /**
         * prod configuration
         */
        address endpoint = 0x1a44076050125825900e736c501f859c50fE728c;
        address delegate = 0x308C6c08735c5cB323FC78b956Dcae19CC008608;

        vm.startBroadcast(deployerPrivateKey);
        VemoWalletOApp factory = new VemoWalletOApp{salt: bytes32(salt)}(endpoint, delegate);
        vm.stopBroadcast();

    }

}
