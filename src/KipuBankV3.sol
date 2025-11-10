// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {IUniswapV2Router02} from "./interfaces/IUniswapV2Router02.sol";
import {IKipuBankV3} from "./interfaces/IKipuBankV3.sol";

/**
 * @title KipuBankV3
 * @author Kipu Team
 * @notice Advanced DeFi banking system that accepts any Uniswap V2 supported token and converts to USDC
 * @dev Integrates with Uniswap V2 for automatic token swapping and Chainlink for price feeds
 *
 * KEY FEATURES:
 * - Accepts ETH, USDC, and any ERC20 token with a direct Uniswap V2 pair to USDC
 * - Automatically swaps deposited tokens to USDC
 * - All user balances stored in USDC (6 decimals)
 * - Bank cap enforcement post-swap
 * - Configurable slippage tolerance for swaps
 * - Role-based access control (Admin, Manager)
 * - Emergency pause functionality
 * - Withdrawal limits for risk management
 *
 * SECURITY:
 * - ReentrancyGuard on all state-changing functions
 * - CEI (Checks-Effects-Interactions) pattern
 * - SafeERC20 for token transfers
 * - Price staleness checks via Chainlink
 * - Slippage protection on swaps
 */
contract KipuBankV3 is
    IKipuBankV3,
    AccessControl,
    ReentrancyGuard,
    Pausable
{
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    /// @notice Role identifier for manager role
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice Address representing native ETH
    address public constant NATIVE_TOKEN = address(0);

    /// @notice Maximum number of tokens that can be supported
    uint8 public constant MAX_SUPPORTED_TOKENS = 50;

    /// @notice Number of decimals for ETH
    uint8 public constant ETH_DECIMALS = 18;

    /// @notice Number of decimals for USD values
    uint8 public constant USD_DECIMALS = 6;

    /// @notice Maximum age of price feed data (1 hour)
    uint256 public constant MAX_PRICE_STALENESS = 3600;

    /// @notice Minimum valid price ($1)
    uint256 public constant MIN_VALID_PRICE = 1e6;

    /// @notice Maximum basis points (100%)
    uint256 public constant MAX_BPS = 10000;

    /// @notice Chainlink ETH/USD price feed
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    AggregatorV3Interface public immutable ethUsdPriceFeed;

    /// @notice Uniswap V2 Router for token swaps
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IUniswapV2Router02 public immutable uniswapRouter;

    /// @notice USDC token address
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable usdc;

    /// @notice Maximum total value the bank can hold (6 decimals)
    uint256 public bankCapUSD;

    /// @notice Maximum withdrawal amount per transaction (6 decimals)
    uint256 public withdrawalLimitUSD;

    /// @notice Total value held in the bank (6 decimals)
    uint256 public totalBankValueUSD;

    /// @notice Slippage tolerance for swaps in basis points (e.g., 100 = 1%)
    uint256 public slippageToleranceBps;

    /// @notice Mapping of user address to USDC balance (6 decimals)
    mapping(address => uint256) public balances;

    /// @notice Mapping of token address to token information
    mapping(address => TokenInfo) public tokenInfo;

    /// @notice Array of all supported token addresses
    address[] public supportedTokens;

    /* ========== MODIFIERS ========== */

    /**
     * @notice Ensures the amount is not zero
     * @param amount The amount to check
     */
    modifier nonZeroAmount(uint256 amount) {
        _nonZeroAmount(amount);
        _;
    }

    /**
     * @notice Ensures the address is not zero
     * @param addr The address to check
     */
    modifier nonZeroAddress(address addr) {
        _nonZeroAddress(addr);
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the KipuBankV3 contract
     * @param _ethUsdPriceFeed Address of the Chainlink ETH/USD price feed
     * @param _uniswapRouter Address of the Uniswap V2 Router
     * @param _usdc Address of the USDC token
     * @param _bankCapUSD Initial bank capacity in USD (6 decimals)
     * @param _withdrawalLimitUSD Initial withdrawal limit in USD (6 decimals)
     * @param _slippageToleranceBps Initial slippage tolerance in basis points
     */
    constructor(
        address _ethUsdPriceFeed,
        address _uniswapRouter,
        address _usdc,
        uint256 _bankCapUSD,
        uint256 _withdrawalLimitUSD,
        uint256 _slippageToleranceBps
    )
        nonZeroAddress(_ethUsdPriceFeed)
        nonZeroAddress(_uniswapRouter)
        nonZeroAddress(_usdc)
    {
        if (_bankCapUSD == 0) revert InvalidBankCap();
        if (_withdrawalLimitUSD == 0 || _withdrawalLimitUSD > _bankCapUSD)
            revert InvalidWithdrawalLimit();
        if (_slippageToleranceBps > MAX_BPS) revert InvalidSlippage();

        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        usdc = _usdc;
        bankCapUSD = _bankCapUSD;
        withdrawalLimitUSD = _withdrawalLimitUSD;
        slippageToleranceBps = _slippageToleranceBps;

        // Grant roles to deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);

        // Add native ETH as supported token
        _addToken(NATIVE_TOKEN, ETH_DECIMALS);

        // Add USDC as supported token
        _addToken(_usdc, USD_DECIMALS);
    }

    /* ========== RECEIVE/FALLBACK ========== */

    /**
     * @notice Reject direct ETH transfers
     * @dev Users must use depositETH() function
     */
    receive() external payable {
        revert("Use depositETH()");
    }

    /**
     * @notice Reject fallback calls
     */
    fallback() external payable {
        revert("Invalid function call");
    }

    /* ========== DEPOSIT FUNCTIONS ========== */

    /**
     * @notice Deposit ETH and swap to USDC
     * @dev ETH is swapped to USDC via Uniswap V2 and credited to user's balance
     *
     * PROCESS:
     * 1. Validate amount and contract state
     * 2. Get expected USDC amount from swap
     * 3. Validate bank cap won't be exceeded
     * 4. Execute swap via Uniswap V2
     * 5. Update user balance and total bank value
     *
     * SECURITY:
     * - nonReentrant: Prevents reentrancy attacks
     * - whenNotPaused: Only works when contract is not paused
     * - nonZeroAmount: Rejects zero deposits
     */
    function depositETH()
        external
        payable
        override
        nonReentrant
        whenNotPaused
        nonZeroAmount(msg.value)
    {
        // Cache state variables for gas optimization (single read)
        uint256 cachedBankCap = bankCapUSD;
        uint256 cachedTotalValue = totalBankValueUSD;
        uint256 cachedSlippageTolerance = slippageToleranceBps;
        address cachedUsdc = usdc; // Cache immutable for stack use

        // Cache token info (single read of storage struct)
        TokenInfo memory nativeTokenInfo = tokenInfo[NATIVE_TOKEN];

        // Validate ETH token is active
        if (nativeTokenInfo.status != TokenStatus.Active) revert TokenPaused();

        // Get expected USDC amount from swap
        uint256 expectedUSDC = getExpectedUSDC(NATIVE_TOKEN, msg.value);

        // Validate deposit doesn't exceed bank cap
        if (cachedTotalValue + expectedUSDC > cachedBankCap)
            revert BankCapExceeded();

        // Calculate minimum USDC amount with slippage protection
        uint256 minUSDC;
        unchecked {
            // Safe: MAX_BPS is 10000, slippageTolerance <= MAX_BPS (validated in setter)
            // Therefore (MAX_BPS - slippageTolerance) cannot underflow
            minUSDC = (expectedUSDC * (MAX_BPS - cachedSlippageTolerance)) / MAX_BPS;
        }

        // Execute swap: ETH -> USDC via Uniswap V2
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = cachedUsdc;

        uint256[] memory amounts = uniswapRouter.swapExactETHForTokens{
            value: msg.value
        }(
            minUSDC, // Minimum USDC to receive
            path, // ETH -> USDC
            address(this), // Receive USDC to contract
            block.timestamp + 300 // 5 minute deadline
        );

        uint256 usdcReceived = amounts[1];

        // Validate swap was successful
        if (usdcReceived == 0) revert SwapFailed();
        if (usdcReceived < minUSDC) revert SlippageTooHigh();

        // Update user balance (single write)
        balances[msg.sender] += usdcReceived;

        // Update total bank value (single write)
        totalBankValueUSD = cachedTotalValue + usdcReceived;

        // Update token statistics (single write to storage)
        unchecked {
            // Safe: totalDeposits can't realistically overflow uint128
            // Casting to uint128 is safe because USDC has 6 decimals, max bank cap is ~1e12,
            // which fits comfortably in uint128 (max ~3.4e38)
            // forge-lint: disable-next-line(unsafe-typecast)
            tokenInfo[NATIVE_TOKEN].totalDeposits = nativeTokenInfo.totalDeposits + uint128(usdcReceived);
            // depositCount won't overflow uint64 in any realistic scenario
            tokenInfo[NATIVE_TOKEN].depositCount = nativeTokenInfo.depositCount + 1;
        }

        // Emit events (NO emitir immutables - usar NATIVE_TOKEN constant)
        emit TokenSwapped(
            msg.sender,
            NATIVE_TOKEN,
            usdc, // Usar immutable directamente, no la cache
            msg.value,
            usdcReceived
        );
        emit Deposit(msg.sender, NATIVE_TOKEN, msg.value, usdcReceived);
    }

    /**
     * @notice Deposit ERC20 tokens and swap to USDC if needed
     * @param token Address of the token to deposit
     * @param amount Amount of tokens to deposit (in token's native decimals)
     *
     * @dev If token is USDC, it's stored directly. Otherwise, swapped via Uniswap V2
     *
     * PROCESS:
     * 1. Validate token is supported and active
     * 2. Transfer tokens from user to contract
     * 3. If token is USDC, credit directly
     * 4. If token is not USDC, swap to USDC
     * 5. Validate bank cap won't be exceeded
     * 6. Update user balance and total bank value
     *
     * SECURITY:
     * - nonReentrant: Prevents reentrancy attacks
     * - whenNotPaused: Only works when contract is not paused
     * - nonZeroAmount: Rejects zero deposits
     * - SafeERC20: Handles non-standard ERC20 implementations
     */
    function depositToken(
        address token,
        uint256 amount
    )
        external
        override
        nonReentrant
        whenNotPaused
        nonZeroAmount(amount)
    {
        // Validate token is not native ETH (address(0))
        if (token == NATIVE_TOKEN) revert TokenNotSupported();

        // Cache token info (single read of storage struct)
        TokenInfo memory info = tokenInfo[token];

        // Validate token is supported and active
        if (!info.isSupported) revert TokenNotSupported();
        if (info.status != TokenStatus.Active) revert TokenPaused();

        // Cache state variables (single read each)
        uint256 cachedBankCap = bankCapUSD;
        uint256 cachedTotalValue = totalBankValueUSD;
        uint256 cachedSlippageTolerance = slippageToleranceBps;
        address cachedUsdc = usdc; // Cache immutable for comparison

        // Transfer tokens from user to contract
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        uint256 usdcAmount;

        // If token is USDC, credit directly
        if (token == cachedUsdc) {
            usdcAmount = amount;

            // Validate deposit doesn't exceed bank cap
            if (cachedTotalValue + usdcAmount > cachedBankCap)
                revert BankCapExceeded();
        } else {
            // Get expected USDC amount from swap
            uint256 expectedUSDC = getExpectedUSDC(token, amount);

            // Validate deposit doesn't exceed bank cap
            if (cachedTotalValue + expectedUSDC > cachedBankCap)
                revert BankCapExceeded();

            // Calculate minimum USDC with slippage protection
            uint256 minUSDC;
            unchecked {
                // Safe: MAX_BPS is 10000, slippageTolerance <= MAX_BPS (validated in setter)
                // Therefore (MAX_BPS - slippageTolerance) cannot underflow
                minUSDC = (expectedUSDC * (MAX_BPS - cachedSlippageTolerance)) / MAX_BPS;
            }

            // Approve Uniswap Router to spend tokens
            IERC20(token).forceApprove(address(uniswapRouter), amount);

            // Execute swap: Token -> USDC via Uniswap V2
            address[] memory path = new address[](2);
            path[0] = token;
            path[1] = cachedUsdc;

            uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(
                amount,
                minUSDC,
                path,
                address(this),
                block.timestamp + 300 // 5 minute deadline
            );

            usdcAmount = amounts[1];

            // Validate swap was successful
            if (usdcAmount == 0) revert SwapFailed();
            if (usdcAmount < minUSDC) revert SlippageTooHigh();

            // Emit swap event (usar immutable directamente)
            emit TokenSwapped(
                msg.sender,
                token,
                usdc, // Usar immutable directamente, no la cache
                amount,
                usdcAmount
            );
        }

        // Update user balance (single write)
        balances[msg.sender] += usdcAmount;

        // Update total bank value (single write)
        totalBankValueUSD = cachedTotalValue + usdcAmount;

        // Update token statistics (single write to storage)
        unchecked {
            // Safe: totalDeposits can't realistically overflow uint128
            // Casting to uint128 is safe because USDC has 6 decimals, max bank cap is ~1e12,
            // which fits comfortably in uint128 (max ~3.4e38)
            // forge-lint: disable-next-line(unsafe-typecast)
            tokenInfo[token].totalDeposits = info.totalDeposits + uint128(usdcAmount);
            // depositCount won't overflow uint64 in any realistic scenario
            tokenInfo[token].depositCount = info.depositCount + 1;
        }

        // Emit deposit event
        emit Deposit(msg.sender, token, amount, usdcAmount);
    }

    /* ========== WITHDRAWAL FUNCTIONS ========== */

    /**
     * @notice Withdraw USDC from the bank
     * @param amount Amount of USDC to withdraw (6 decimals)
     *
     * @dev Withdrawals are always in USDC
     *
     * PROCESS:
     * 1. Validate user has sufficient balance
     * 2. Validate amount doesn't exceed withdrawal limit
     * 3. Update balances
     * 4. Transfer USDC to user
     *
     * SECURITY:
     * - nonReentrant: Prevents reentrancy attacks
     * - whenNotPaused: Only works when contract is not paused
     * - nonZeroAmount: Rejects zero withdrawals
     * - CEI pattern: State updates before external call
     */
    function withdraw(
        uint256 amount
    ) external override nonReentrant whenNotPaused nonZeroAmount(amount) {
        // Cache state variables (single read each)
        uint256 userBalance = balances[msg.sender];
        uint256 cachedWithdrawalLimit = withdrawalLimitUSD;
        uint256 cachedTotalValue = totalBankValueUSD;
        address cachedUsdc = usdc; // Cache immutable for stack use

        // Validate user has sufficient balance
        if (userBalance < amount) revert InsufficientBalance();

        // Validate withdrawal limit
        if (amount > cachedWithdrawalLimit) revert WithdrawalLimitExceeded();

        // Update user balance (CEI pattern - single write)
        unchecked {
            // Safe: we validated userBalance >= amount above
            balances[msg.sender] = userBalance - amount;
        }

        // Update total bank value (single write)
        unchecked {
            // Safe: totalBankValueUSD >= amount (because user's balance is part of total)
            totalBankValueUSD = cachedTotalValue - amount;
        }

        // Update USDC token statistics (single write)
        unchecked {
            // Safe: withdrawalCount won't overflow uint64 in any realistic scenario
            tokenInfo[cachedUsdc].withdrawalCount++;
        }

        // Transfer USDC to user (INTERACTION phase)
        IERC20(cachedUsdc).safeTransfer(msg.sender, amount);

        // Emit withdrawal event (usar immutable directamente)
        emit Withdrawal(msg.sender, usdc, amount, amount);
    }

    /* ========== MANAGER FUNCTIONS ========== */

    /**
     * @notice Add a new token to the supported tokens list
     * @param token Address of the token to add
     *
     * @dev Only callable by manager role
     *
     * VALIDATIONS:
     * - Token address is not zero
     * - Token is not already supported
     * - Max tokens limit not reached
     * - Token implements ERC20Metadata (for decimals)
     * - Token decimals are between 1 and 18
     */
    function addToken(
        address token
    ) external override onlyRole(MANAGER_ROLE) nonZeroAddress(token) {
        // Validate token not already supported
        if (tokenInfo[token].isSupported) revert TokenAlreadySupported();

        // Validate max tokens not reached
        if (supportedTokens.length >= MAX_SUPPORTED_TOKENS)
            revert MaxTokensReached();

        // Get token decimals
        uint8 decimals;
        try IERC20Metadata(token).decimals() returns (uint8 _decimals) {
            decimals = _decimals;
        } catch {
            revert InvalidDecimals();
        }

        // Validate decimals
        if (decimals == 0 || decimals > 18) revert InvalidDecimals();

        // Add token
        _addToken(token, decimals);

        emit TokenAdded(token, decimals);
    }

    /**
     * @notice Set the status of a token
     * @param token Address of the token
     * @param newStatus New status for the token
     *
     * @dev Only callable by manager role
     */
    function setTokenStatus(
        address token,
        TokenStatus newStatus
    ) external override onlyRole(MANAGER_ROLE) {
        // Validate token is supported
        if (!tokenInfo[token].isSupported) revert TokenNotSupported();

        // Update status
        tokenInfo[token].status = newStatus;

        emit TokenStatusChanged(token, newStatus);
    }

    /**
     * @notice Set the bank capacity in USD
     * @param newCapUSD New bank capacity (6 decimals)
     *
     * @dev Only callable by manager role
     *
     * VALIDATIONS:
     * - New cap must be > 0
     * - New cap must be >= current total bank value
     */
    function setBankCap(
        uint256 newCapUSD
    ) external override onlyRole(MANAGER_ROLE) {
        // Cache state variables (single read each)
        uint256 cachedOldCap = bankCapUSD;
        uint256 cachedTotalValue = totalBankValueUSD;

        // Validations
        if (newCapUSD == 0) revert InvalidBankCap();
        if (newCapUSD < cachedTotalValue) revert InvalidBankCap();

        // Update bank cap (single write)
        bankCapUSD = newCapUSD;

        // Emit event with old value cached
        emit BankCapUpdated(cachedOldCap, newCapUSD);
    }

    /**
     * @notice Set the withdrawal limit in USD
     * @param newLimitUSD New withdrawal limit (6 decimals)
     *
     * @dev Only callable by manager role
     *
     * VALIDATIONS:
     * - New limit must be > 0
     * - New limit must be <= bank cap
     */
    function setWithdrawalLimit(
        uint256 newLimitUSD
    ) external override onlyRole(MANAGER_ROLE) {
        // Cache state variables (single read each)
        uint256 cachedOldLimit = withdrawalLimitUSD;
        uint256 cachedBankCap = bankCapUSD;

        // Validations
        if (newLimitUSD == 0 || newLimitUSD > cachedBankCap)
            revert InvalidWithdrawalLimit();

        // Update withdrawal limit (single write)
        withdrawalLimitUSD = newLimitUSD;

        // Emit event with old value cached
        emit WithdrawalLimitUpdated(cachedOldLimit, newLimitUSD);
    }

    /**
     * @notice Set the slippage tolerance for swaps
     * @param newSlippageBps New slippage tolerance in basis points
     *
     * @dev Only callable by manager role
     *
     * VALIDATIONS:
     * - New slippage must be <= 10000 (100%)
     */
    function setSlippageTolerance(
        uint256 newSlippageBps
    ) external override onlyRole(MANAGER_ROLE) {
        // Validation
        if (newSlippageBps > MAX_BPS) revert InvalidSlippage();

        // Cache old value (single read)
        uint256 cachedOldSlippage = slippageToleranceBps;

        // Update slippage tolerance (single write)
        slippageToleranceBps = newSlippageBps;

        // Emit event with old value cached
        emit SlippageToleranceUpdated(cachedOldSlippage, newSlippageBps);
    }

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Pause all deposits and withdrawals
     * @dev Only callable by admin role
     */
    function pause() external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause all deposits and withdrawals
     * @dev Only callable by admin role
     */
    function unpause() external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Emergency withdraw function to recover tokens
     * @param token Address of the token (address(0) for ETH)
     * @param amount Amount to withdraw
     * @param recipient Address to send tokens to
     *
     * @dev Only callable by admin role. Does NOT update user balances.
     * Should only be used in emergency situations.
     */
    function emergencyWithdraw(
        address token,
        uint256 amount,
        address recipient
    )
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonZeroAmount(amount)
        nonZeroAddress(recipient)
    {
        if (token == NATIVE_TOKEN) {
            // Withdraw ETH
            (bool success, ) = payable(recipient).call{value: amount}("");
            if (!success) revert SwapFailed();
        } else {
            // Withdraw ERC20
            IERC20(token).safeTransfer(recipient, amount);
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Get the USDC balance of a user
     * @param user Address of the user
     * @return The USDC balance (6 decimals)
     */
    function getBalance(
        address user
    ) external view override returns (uint256) {
        return balances[user];
    }

    /**
     * @notice Get the total bank value in USD
     * @return The total value in USD (6 decimals)
     */
    function getTotalBankValueUSD() external view override returns (uint256) {
        return totalBankValueUSD;
    }

    /**
     * @notice Get the list of all supported tokens
     * @return Array of supported token addresses
     */
    function getSupportedTokens()
        external
        view
        override
        returns (address[] memory)
    {
        return supportedTokens;
    }

    /**
     * @notice Get information about a specific token
     * @param token Address of the token
     * @return TokenInfo struct with token details
     */
    function getTokenInfo(
        address token
    ) external view override returns (TokenInfo memory) {
        return tokenInfo[token];
    }

    /**
     * @notice Get the current ETH/USD price from Chainlink
     * @return The ETH price in USD (8 decimals)
     *
     * @dev Validates price freshness and validity
     */
    function getETHPriceUSD() external view override returns (uint256) {
        return _getETHPrice();
    }

    /**
     * @notice Get the expected USDC amount for a token swap
     * @param tokenIn Input token address
     * @param amountIn Input amount (in token's native decimals)
     * @return expectedUSDC Expected USDC amount after swap (6 decimals)
     *
     * @dev Uses Uniswap V2 getAmountsOut for price estimation
     */
    function getExpectedUSDC(
        address tokenIn,
        uint256 amountIn
    ) public view override returns (uint256 expectedUSDC) {
        if (tokenIn == usdc) {
            // If token is already USDC, return amount directly
            return amountIn;
        }

        // Build swap path
        address[] memory path = new address[](2);
        if (tokenIn == NATIVE_TOKEN) {
            path[0] = uniswapRouter.WETH();
        } else {
            path[0] = tokenIn;
        }
        path[1] = usdc;

        // Get expected amounts from Uniswap
        try uniswapRouter.getAmountsOut(amountIn, path) returns (
            uint256[] memory amounts
        ) {
            expectedUSDC = amounts[1];
        } catch {
            revert NoSwapPath();
        }

        if (expectedUSDC == 0) revert AmountTooSmall();
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    /**
     * @notice Internal function to add a token
     * @param token Address of the token
     * @param decimals Decimals of the token
     */
    function _addToken(address token, uint8 decimals) internal {
        tokenInfo[token] = TokenInfo({
            totalDeposits: 0,
            depositCount: 0,
            withdrawalCount: 0,
            isSupported: true,
            decimals: decimals,
            status: TokenStatus.Active
        });

        supportedTokens.push(token);
    }

    /**
     * @notice Get the current ETH/USD price from Chainlink
     * @return price The ETH price in USD (8 decimals)
     *
     * @dev Validates:
     * - Round data is valid
     * - Price is not stale (< 1 hour old)
     * - Price is positive and above minimum
     */
    function _getETHPrice() internal view returns (uint256 price) {
        (
            uint80 roundId,
            int256 answer,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = ethUsdPriceFeed.latestRoundData();

        // Validate round data
        if (answeredInRound == 0 || roundId < answeredInRound)
            revert StalePrice();

        // Validate price freshness
        if (block.timestamp - updatedAt > MAX_PRICE_STALENESS)
            revert StalePrice();

        // Validate price is positive
        if (answer <= 0) revert InvalidPrice();

        // Casting to uint256 is safe because we validated answer > 0 above
        // forge-lint: disable-next-line(unsafe-typecast)
        price = uint256(answer);

        // Validate price is above minimum ($1)
        if (price < MIN_VALID_PRICE) revert InvalidPrice();
    }

    /**
     * @notice Internal function to validate amount is not zero
     * @param amount The amount to check
     */
    function _nonZeroAmount(uint256 amount) internal pure {
        if (amount == 0) revert ZeroAmount();
    }

    /**
     * @notice Internal function to validate address is not zero
     * @param addr The address to check
     */
    function _nonZeroAddress(address addr) internal pure {
        if (addr == address(0)) revert ZeroAddress();
    }
}
