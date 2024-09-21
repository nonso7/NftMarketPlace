const { ethers } = require("hardhat");

async function main() {
    // Get the deployer account
    const [deployer] = await ethers.getSigners(); // Make sure ethers is used from hardhat

    console.log("Deploying contracts with the account:", deployer.address);

    // Check the balance of the deployer
    const balance = await deployer.getBalance();
    console.log("Account balance:", ethers.utils.formatEther(balance), "ETH");

    // Deploy the contract
    const NFTMarketPlace = await ethers.getContractFactory("NFTMarketPlace");
    const nftMarket = await NFTMarketPlace.deploy({ value: ethers.utils.parseEther("0.05") });

    // Wait for the deployment to finish
    await nftMarket.deployed();

    // Log the contract address
    console.log("NFTMarket deployed to:", nftMarket.address);
}

// Run the deployment script
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
