// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title IKipuBankV3
 * @notice Interface for KipuBankV3 - Advanced DeFi banking system with Uniswap V2 integration
 * @dev Extends KipuBankV2 functionality with automatic token swapping to USDC
 */
interface IKipuBankV3 {
    /* ========== ENUMS ========== */

    /**
     * @notice Status of a token in the system
     * @param Inactive Token is not supported
     * @param Active Token is active and can be deposited
     * @param Paused Token is temporarily paused, no new deposits allowed
     */
    enum TokenStatus {
        Inactive,
        Active,
        Paused
    }

    /* ========== STRUCTS ========== */

    /**
     * @notice Information about a supported token
     * @param totalDeposits Total deposits in USD (6 decimals)
     * @param depositCount Number of deposits made
     * @param withdrawalCount Number of withdrawals made
     * @param isSupported Whether the token is supported
     * @param decimals Token decimals (1-18)
     * @param status Current status of the token
     */
    struct TokenInfo {
        uint128 totalDeposits;
        uint64 depositCount;
        uint64 withdrawalCount;
        bool isSupported;
        uint8 decimals;
        TokenStatus status;
    }

    /* ========== EVENTS ========== */

    /**
     * @notice Emitted when a user deposits tokens
     * @param user The address of the user
     * @param token The address of the deposited token (address(0) for ETH)
     * @param amount The amount of tokens deposited (in token's native decimals)
     * @param usdValue The USD value of the deposit (6 decimals)
     */
    event Deposit(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 usdValue
    );

    /**
     * @notice Emitted when a user withdraws tokens
     * @param user The address of the user
     * @param token The address of the withdrawn token (address(0) for ETH)
     * @param amount The amount of tokens withdrawn (in token's native decimals)
     * @param usdValue The USD value of the withdrawal (6 decimals)
     */
    event Withdrawal(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 usdValue
    );

    /**
     * @notice Emitted when a token is swapped via Uniswap V2
     * @param user The address of the user
     * @param tokenIn The address of the input token
     * @param tokenOut The address of the output token (USDC)
     * @param amountIn The amount of input tokens
     * @param amountOut The amount of output tokens received
     */
    event TokenSwapped(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @notice Emitted when a new token is added to the system
     * @param token The address of the added token
     * @param decimals The decimals of the token
     */
    event TokenAdded(address indexed token, uint8 decimals);

    /**
     * @notice Emitted when a token's status is changed
     * @param token The address of the token
     * @param newStatus The new status of the token
     */
    event TokenStatusChanged(address indexed token, TokenStatus newStatus);

    /**
     * @notice Emitted when the bank cap is updated
     * @param oldCap The old bank cap in USD (6 decimals)
     * @param newCap The new bank cap in USD (6 decimals)
     */
    event BankCapUpdated(uint256 oldCap, uint256 newCap);

    /**
     * @notice Emitted when the withdrawal limit is updated
     * @param oldLimit The old withdrawal limit in USD (6 decimals)
     * @param newLimit The new withdrawal limit in USD (6 decimals)
     */
    event WithdrawalLimitUpdated(uint256 oldLimit, uint256 newLimit);

    /**
     * @notice Emitted when slippage tolerance is updated
     * @param oldSlippage The old slippage tolerance (basis points)
     * @param newSlippage The new slippage tolerance (basis points)
     */
    event SlippageToleranceUpdated(uint256 oldSlippage, uint256 newSlippage);

    /* ========== CUSTOM ERRORS ========== */

    error ZeroAmount();
    error ZeroAddress();
    error TokenNotSupported();
    error TokenAlreadySupported();
    error TokenPaused();
    error BankCapExceeded();
    error WithdrawalLimitExceeded();
    error InsufficientBalance();
    error InvalidDecimals();
    error MaxTokensReached();
    error InvalidBankCap();
    error InvalidWithdrawalLimit();
    error InvalidPrice();
    error StalePrice();
    error SwapFailed();
    error SlippageTooHigh();
    error InvalidSlippage();
    error NoSwapPath();
    error AmountTooSmall();

    /* ========== DEPOSIT FUNCTIONS ========== */

    /**
     * @notice Deposit ETH into the bank
     * @dev ETH is swapped to USDC via Uniswap V2 and credited to user's balance
     */
    function depositETH() external payable;

    /**
     * @notice Deposit ERC20 tokens into the bank
     * @dev If token is not USDC, it's swapped to USDC via Uniswap V2
     * @param token The address of the token to deposit
     * @param amount The amount of tokens to deposit (in token's native decimals)
     */
    function depositToken(address token, uint256 amount) external;

    /* ========== WITHDRAWAL FUNCTIONS ========== */

    /**
     * @notice Withdraw USDC from the bank
     * @param amount The amount of USDC to withdraw (6 decimals)
     */
    function withdraw(uint256 amount) external;

    /* ========== MANAGER FUNCTIONS ========== */

    /**
     * @notice Add a new token to the supported tokens list
     * @param token The address of the token to add
     */
    function addToken(address token) external;

    /**
     * @notice Set the status of a token
     * @param token The address of the token
     * @param newStatus The new status for the token
     */
    function setTokenStatus(address token, TokenStatus newStatus) external;

    /**
     * @notice Set the bank capacity in USD
     * @param newCapUSD The new bank capacity (6 decimals)
     */
    function setBankCap(uint256 newCapUSD) external;

    /**
     * @notice Set the withdrawal limit in USD
     * @param newLimitUSD The new withdrawal limit (6 decimals)
     */
    function setWithdrawalLimit(uint256 newLimitUSD) external;

    /**
     * @notice Set the slippage tolerance for swaps
     * @param newSlippageBps The new slippage tolerance in basis points (e.g., 100 = 1%)
     */
    function setSlippageTolerance(uint256 newSlippageBps) external;

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Pause all deposits and withdrawals
     */
    function pause() external;

    /**
     * @notice Unpause all deposits and withdrawals
     */
    function unpause() external;

    /**
     * @notice Emergency withdraw function to recover tokens
     * @param token The address of the token to withdraw (address(0) for ETH)
     * @param amount The amount to withdraw
     * @param recipient The address to send the tokens to
     */
    function emergencyWithdraw(
        address token,
        uint256 amount,
        address recipient
    ) external;

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Get the USDC balance of a user
     * @param user The address of the user
     * @return The USDC balance (6 decimals)
     */
    function getBalance(address user) external view returns (uint256);

    /**
     * @notice Get the total bank value in USD
     * @return The total value in USD (6 decimals)
     */
    function getTotalBankValueUSD() external view returns (uint256);

    /**
     * @notice Get the list of all supported tokens
     * @return An array of supported token addresses
     */
    function getSupportedTokens() external view returns (address[] memory);

    /**
     * @notice Get information about a specific token
     * @param token The address of the token
     * @return TokenInfo struct with token details
     */
    function getTokenInfo(address token) external view returns (TokenInfo memory);

    /**
     * @notice Get the current ETH/USD price from Chainlink
     * @return The ETH price in USD (8 decimals)
     */
    function getETHPriceUSD() external view returns (uint256);

    /**
     * @notice Get the expected USDC amount for a token swap
     * @param tokenIn The input token address
     * @param amountIn The input amount
     * @return expectedUSDC The expected USDC amount after swap (6 decimals)
     */
    function getExpectedUSDC(
        address tokenIn,
        uint256 amountIn
    ) external view returns (uint256 expectedUSDC);
}
