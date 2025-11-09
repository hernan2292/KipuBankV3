// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MockUniswapV2Router
 * @notice Mock Uniswap V2 Router for testing
 * @dev Simulates token swaps with a simple 1:1 exchange rate for testing
 */
contract MockUniswapV2Router {
    using SafeERC20 for IERC20;

    address public immutable WETH;
    uint256 public exchangeRate; // In basis points (10000 = 1:1)

    constructor(address _weth) {
        WETH = _weth;
        exchangeRate = 10000; // Default 1:1
    }

    function factory() external pure returns (address) {
        return address(0);
    }

    /**
     * @notice Set exchange rate for testing
     * @param _rate Exchange rate in basis points (10000 = 1:1, 20000 = 2:1, etc)
     */
    function setExchangeRate(uint256 _rate) external {
        exchangeRate = _rate;
    }

    /**
     * @notice Swap exact tokens for tokens
     * @dev Simplified mock that transfers tokens based on exchange rate
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 /* deadline */
    ) external returns (uint256[] memory amounts) {
        require(path.length == 2, "Invalid path");
        require(amountIn > 0, "Invalid amount");

        address tokenIn = path[0];
        address tokenOut = path[1];

        // Transfer tokens from sender to router
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        // Calculate output amount based on exchange rate
        uint256 amountOut = (amountIn * exchangeRate) / 10000;

        require(amountOut >= amountOutMin, "Insufficient output amount");

        // Mint or transfer output tokens to recipient
        // In a real router, this would come from liquidity pools
        IERC20(tokenOut).safeTransfer(to, amountOut);

        amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

    /**
     * @notice Swap exact ETH for tokens
     * @dev Simplified mock that transfers tokens based on exchange rate
     */
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 /* deadline */
    ) external payable returns (uint256[] memory amounts) {
        require(path.length == 2, "Invalid path");
        require(path[0] == WETH, "First token must be WETH");
        require(msg.value > 0, "Invalid ETH amount");

        address tokenOut = path[1];

        // Calculate output amount based on exchange rate
        // For ETH swaps, we simulate the conversion
        uint256 amountOut = (msg.value * exchangeRate) / 10000;

        require(amountOut >= amountOutMin, "Insufficient output amount");

        // Transfer output tokens to recipient
        IERC20(tokenOut).safeTransfer(to, amountOut);

        amounts = new uint256[](2);
        amounts[0] = msg.value;
        amounts[1] = amountOut;
    }

    /**
     * @notice Get amounts out for a given input amount
     * @dev Simplified calculation using exchange rate
     */
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts) {
        require(path.length == 2, "Invalid path");

        amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = (amountIn * exchangeRate) / 10000;
    }

    /**
     * @notice Get amount out for reserves
     * @dev Simplified calculation
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 /* reserveIn */,
        uint256 /* reserveOut */
    ) external view returns (uint256 amountOut) {
        amountOut = (amountIn * exchangeRate) / 10000;
    }

    /**
     * @notice Fund router with tokens for testing
     */
    function fundRouter(address token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    // Allow contract to receive ETH
    receive() external payable {}
}
