// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {KipuBankV3} from "../src/KipuBankV3.sol";

/**
 * @title DeployKipuBankV3
 * @notice Deployment script for KipuBankV3
 * @dev Run with: forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 --rpc-url <network> --broadcast --verify
 */
contract DeployKipuBankV3 is Script {
    // Sepolia addresses
    address constant SEPOLIA_ETH_USD_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address constant SEPOLIA_UNISWAP_ROUTER = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
    address constant SEPOLIA_USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    // Mainnet addresses
    address constant MAINNET_ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address constant MAINNET_UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant MAINNET_USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // Initial configuration
    uint256 constant INITIAL_BANK_CAP = 1_000_000e6; // $1M
    uint256 constant INITIAL_WITHDRAWAL_LIMIT = 100_000e6; // $100K
    uint256 constant INITIAL_SLIPPAGE = 100; // 1%

    function run() external returns (KipuBankV3) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 chainId = block.chainid;

        address ethUsdFeed;
        address uniswapRouter;
        address usdc;

        // Select addresses based on chain
        if (chainId == 11155111) {
            // Sepolia
            ethUsdFeed = SEPOLIA_ETH_USD_FEED;
            uniswapRouter = SEPOLIA_UNISWAP_ROUTER;
            usdc = SEPOLIA_USDC;
            console.log("Deploying to Sepolia...");
        } else if (chainId == 1) {
            // Mainnet
            ethUsdFeed = MAINNET_ETH_USD_FEED;
            uniswapRouter = MAINNET_UNISWAP_ROUTER;
            usdc = MAINNET_USDC;
            console.log("Deploying to Mainnet...");
        } else {
            revert("Unsupported network");
        }

        vm.startBroadcast(deployerPrivateKey);

        KipuBankV3 bank = new KipuBankV3(
            ethUsdFeed,
            uniswapRouter,
            usdc,
            INITIAL_BANK_CAP,
            INITIAL_WITHDRAWAL_LIMIT,
            INITIAL_SLIPPAGE
        );

        vm.stopBroadcast();

        console.log("KipuBankV3 deployed to:", address(bank));
        console.log("Bank Cap:", INITIAL_BANK_CAP);
        console.log("Withdrawal Limit:", INITIAL_WITHDRAWAL_LIMIT);
        console.log("Slippage Tolerance:", INITIAL_SLIPPAGE, "bps");

        return bank;
    }
}
