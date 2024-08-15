
/**
 *  forge script script/Deploy.s.sol --rpc-url https://avalanche.drpc.org --private-key private_key  --broadcast  --verify --chain-id 43114 --ffi --etherscan-api-key 

 */
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../contracts/VemoWalletOApp.sol";

// mainnet:  0x96f0445246B19Fa098f8bb4dfA907eD38F6155d5
// testnet: 0x823b6CeA760716F40D6CA720a11f7459Fa361e9e
contract DeployOApp is Script {
    // a Prime
    uint256 salt = 0x8cb91e82a3386d28036d6f63d1e6efd90031d3e8a56e75da9f0b021f40b0bc4c;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        /**
         * prod configuration
         */
        address endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        address delegate = 0xaA6Fb5C8C0978532AaA46f99592cB0b71F11d94E;

        vm.startBroadcast(deployerPrivateKey);
        VemoWalletOApp factory = new VemoWalletOApp{salt: bytes32(salt)}(endpoint, delegate);
        vm.stopBroadcast();

    }

}
