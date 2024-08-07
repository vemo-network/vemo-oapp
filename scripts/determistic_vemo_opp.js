// scripts/deploy_with_create2.js
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    
    console.log("Deploying contracts with the account:", deployer.address);

    // Define the contract factory
    const VemoWalletOApp = await ethers.getContractFactory("VemoWalletOApp");
    
    // layerzero endpoint, reference here https://docs.layerzero.network/v2/developers/evm/technical-reference/deployed-contracts
    const endpoint = "0x1a44076050125825900e736c501f859c50fE728c";
    const delegate = deployer.address;

    // CREATE2 parameters
    const salt = "0x8cb91e82a3386d28036d6f63d1e6efd90031d3e8a56e75da9f0b021f40b0bc4c";
    console.log(salt);
    const initCode = VemoWalletOApp.bytecode + ethers.utils.defaultAbiCoder.encode(["address", "address"], [endpoint, delegate]).slice(2);
    const create2FactoryAddress = "0x4e59b44847b379578588920cA78FbF26c0B4956C";
    const create2Address = ethers.utils.getCreate2Address(
        create2FactoryAddress,
        salt,
        ethers.utils.keccak256(initCode)
    );

    console.log("Contract will be deployed at:", create2Address);

    // Deploy the contract using CREATE2 factory
    const create2Factory = await ethers.getContractAt(
        [
            "function deploy(bytes memory code, uint256 salt) public returns (address)",
        ],
        create2FactoryAddress
    );

    const tx = await create2Factory.deploy(initCode, salt, { gasLimit: 5000000 }); // adjust gas limit as necessary
    await tx.wait();

    console.log("VemoWalletOApp deployed at:", create2Address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
