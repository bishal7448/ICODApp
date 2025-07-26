const hre = require("hardhat");

async function main() {
    // Load Deployer account and log details
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    // Network information
    const network = hre.ethers.provider.getNetwork();
    console.log("Network:", network.name);

    // Deploy the TokenICO contract
    console.log("\nDeploying TokenICO contract...");
    const TokenICO = await hre.ethers.getContractFactory("TokenICO");
    const tokenICO = await TokenICO.deploy();
    await tokenICO.deployed();
    console.log("\nDeployment successful!");
    console.log("------------------------");
    console.log("TokenICO contract address:", tokenICO.address);
    console.log("\nPublic owner address:", deployer.address);

    // Deploy Token contract
    console.log("\nDeploying LINKTUM contract...");
    const LINKTUM = await hre.ethers.getContractFactory("LINKTUM");
    const linktum = await LINKTUM.deploy();
    await linktum.deployed();
    console.log("\nDeployment successful!");
    console.log("------------------------");
    console.log("LINKTUM contract address:", linktum.address);
    console.log("\nPublic owner address:", deployer.address);
}

main().then(() => process.exit(0)).catch((error) => {
    console.error(error);
    process.exit(1);
});
