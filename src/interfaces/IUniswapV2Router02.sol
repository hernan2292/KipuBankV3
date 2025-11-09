// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title IUniswapV2Router02
 * @notice Interface for Uniswap V2 Router for token swaps
 * @dev This interface defines the functions needed to interact with Uniswap V2 for swapping tokens
 */
interface IUniswapV2Router02 {
    /**
     * @notice Returns the factory address
     * @return The address of the Uniswap V2 Factory
     */
    function factory() external pure returns (address);

    /**
     * @notice Returns the WETH address
     * @return The address of Wrapped Ether
     */
    function WETH() external pure returns (address);

    /**
     * @notice Swaps an exact amount of input tokens for as many output tokens as possible
     * @param amountIn The amount of input tokens to send
     * @param amountOutMin The minimum amount of output tokens that must be received
     * @param path An array of token addresses representing the swap path
     * @param to Recipient of the output tokens
     * @param deadline Unix timestamp after which the transaction will revert
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /**
     * @notice Swaps an exact amount of ETH for as many output tokens as possible
     * @param amountOutMin The minimum amount of output tokens that must be received
     * @param path An array of token addresses representing the swap path (WETH -> token)
     * @param to Recipient of the output tokens
     * @param deadline Unix timestamp after which the transaction will revert
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    /**
     * @notice Given an input amount of an asset and pair reserves, returns the maximum output amount
     * @param amountIn The amount of input tokens
     * @param reserveIn The reserve of input tokens
     * @param reserveOut The reserve of output tokens
     * @return amountOut The amount of output tokens
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    /**
     * @notice Performs chained getAmountOut calculations on any number of pairs
     * @param amountIn The amount of input tokens
     * @param path An array of token addresses representing the swap path
     * @return amounts The output amounts for each pair in the path
     */
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}
