// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {KipuBankV3} from "../src/KipuBankV3.sol";
import {IKipuBankV3} from "../src/interfaces/IKipuBankV3.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";
import {MockV3Aggregator} from "../src/mocks/MockV3Aggregator.sol";
import {MockUniswapV2Router} from "../src/mocks/MockUniswapV2Router.sol";

/**
 * @title KipuBankV3Test
 * @notice Comprehensive test suite for KipuBankV3
 * @dev Tests cover all main functionality, edge cases, and security concerns
 */
contract KipuBankV3Test is Test {
    /* ========== STATE VARIABLES ========== */

    KipuBankV3 public bank;
    MockERC20 public usdc;
    MockERC20 public dai;
    MockERC20 public weth;
    MockV3Aggregator public ethPriceFeed;
    MockUniswapV2Router public uniswapRouter;

    address public owner;
    address public manager;
    address public user1;
    address public user2;

    uint256 public constant INITIAL_BANK_CAP = 1_000_000e6; // $1M
    uint256 public constant INITIAL_WITHDRAWAL_LIMIT = 100_000e6; // $100K
    uint256 public constant INITIAL_SLIPPAGE = 100; // 1%
    uint256 public constant ETH_PRICE = 3000e8; // $3000 (8 decimals)

    /* ========== EVENTS ========== */

    event Deposit(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 usdValue
    );
    event Withdrawal(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 usdValue
    );
    event TokenSwapped(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );
    event TokenAdded(address indexed token, uint8 decimals);
    event BankCapUpdated(uint256 oldCap, uint256 newCap);

    /* ========== SETUP ========== */

    function setUp() public {
        // Create test accounts
        owner = makeAddr("owner");
        manager = makeAddr("manager");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy mock tokens
        usdc = new MockERC20("USD Coin", "USDC", 6);
        dai = new MockERC20("Dai Stablecoin", "DAI", 18);
        weth = new MockERC20("Wrapped Ether", "WETH", 18);

        // Deploy mock price feed
        ethPriceFeed = new MockV3Aggregator(8, int256(ETH_PRICE));

        // Deploy mock Uniswap router
        uniswapRouter = new MockUniswapV2Router(address(weth));

        // Fund router with tokens for swaps
        usdc.mint(address(uniswapRouter), 10_000_000e6); // 10M USDC
        dai.mint(address(uniswapRouter), 10_000_000e18); // 10M DAI

        // Deploy KipuBankV3 as owner
        vm.startPrank(owner);
        bank = new KipuBankV3(
            address(ethPriceFeed),
            address(uniswapRouter),
            address(usdc),
            INITIAL_BANK_CAP,
            INITIAL_WITHDRAWAL_LIMIT,
            INITIAL_SLIPPAGE
        );

        // Grant manager role
        bank.grantRole(bank.MANAGER_ROLE(), manager);
        vm.stopPrank();

        // Fund users with ETH and tokens
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);

        usdc.mint(user1, 100_000e6);
        usdc.mint(user2, 100_000e6);

        dai.mint(user1, 100_000e18);
        dai.mint(user2, 100_000e18);
    }

    /* ========== CONSTRUCTOR TESTS ========== */

    function test_Constructor_Success() public view {
        assertEq(address(bank.ethUsdPriceFeed()), address(ethPriceFeed));
        assertEq(address(bank.uniswapRouter()), address(uniswapRouter));
        assertEq(bank.usdc(), address(usdc));
        assertEq(bank.bankCapUSD(), INITIAL_BANK_CAP);
        assertEq(bank.withdrawalLimitUSD(), INITIAL_WITHDRAWAL_LIMIT);
        assertEq(bank.slippageToleranceBps(), INITIAL_SLIPPAGE);
    }

    function test_Constructor_GrantsRoles() public view {
        assertTrue(bank.hasRole(bank.DEFAULT_ADMIN_ROLE(), owner));
        assertTrue(bank.hasRole(bank.MANAGER_ROLE(), owner));
        assertTrue(bank.hasRole(bank.MANAGER_ROLE(), manager));
    }

    function test_Constructor_AddsDefaultTokens() public view {
        address[] memory tokens = bank.getSupportedTokens();
        assertEq(tokens.length, 2);
        assertEq(tokens[0], address(0)); // Native ETH
        assertEq(tokens[1], address(usdc));
    }

    function test_Constructor_RevertsOnZeroAddress() public {
        vm.expectRevert(IKipuBankV3.ZeroAddress.selector);
        new KipuBankV3(
            address(0), // Zero address
            address(uniswapRouter),
            address(usdc),
            INITIAL_BANK_CAP,
            INITIAL_WITHDRAWAL_LIMIT,
            INITIAL_SLIPPAGE
        );
    }

    function test_Constructor_RevertsOnInvalidBankCap() public {
        vm.expectRevert(IKipuBankV3.InvalidBankCap.selector);
        new KipuBankV3(
            address(ethPriceFeed),
            address(uniswapRouter),
            address(usdc),
            0, // Zero bank cap
            INITIAL_WITHDRAWAL_LIMIT,
            INITIAL_SLIPPAGE
        );
    }

    function test_Constructor_RevertsOnInvalidWithdrawalLimit() public {
        vm.expectRevert(IKipuBankV3.InvalidWithdrawalLimit.selector);
        new KipuBankV3(
            address(ethPriceFeed),
            address(uniswapRouter),
            address(usdc),
            INITIAL_BANK_CAP,
            0, // Zero withdrawal limit
            INITIAL_SLIPPAGE
        );
    }

    /* ========== DEPOSIT ETH TESTS ========== */

    function test_DepositETH_Success() public {
        uint256 depositAmount = 1 ether;
        uint256 expectedUSDC = (depositAmount * uniswapRouter.exchangeRate()) / 10000;

        vm.startPrank(user1);

        // Expect events
        vm.expectEmit(true, true, true, true);
        emit TokenSwapped(user1, address(0), address(usdc), depositAmount, expectedUSDC);

        vm.expectEmit(true, true, true, true);
        emit Deposit(user1, address(0), depositAmount, expectedUSDC);

        bank.depositETH{value: depositAmount}();
        vm.stopPrank();

        // Verify balance
        assertEq(bank.getBalance(user1), expectedUSDC);
        assertEq(bank.getTotalBankValueUSD(), expectedUSDC);
    }

    function test_DepositETH_MultipleDeposits() public {
        vm.startPrank(user1);

        bank.depositETH{value: 1 ether}();
        uint256 balance1 = bank.getBalance(user1);

        bank.depositETH{value: 2 ether}();
        uint256 balance2 = bank.getBalance(user1);

        vm.stopPrank();

        assertTrue(balance2 > balance1);
        assertEq(bank.getTotalBankValueUSD(), balance2);
    }

    function test_DepositETH_RevertsOnZeroAmount() public {
        vm.startPrank(user1);
        vm.expectRevert(IKipuBankV3.ZeroAmount.selector);
        bank.depositETH{value: 0}();
        vm.stopPrank();
    }

    function test_DepositETH_RevertsWhenPaused() public {
        vm.prank(owner);
        bank.pause();

        vm.startPrank(user1);
        vm.expectRevert();
        bank.depositETH{value: 1 ether}();
        vm.stopPrank();
    }

    function test_DepositETH_RevertsOnBankCapExceeded() public {
        // Set low bank cap
        vm.prank(manager);
        bank.setBankCap(1000e6); // $1000

        vm.startPrank(user1);
        vm.expectRevert(IKipuBankV3.BankCapExceeded.selector);
        bank.depositETH{value: 10 ether}(); // Would exceed cap
        vm.stopPrank();
    }

    /* ========== DEPOSIT TOKEN TESTS ========== */

    function test_DepositToken_USDC_Success() public {
        uint256 depositAmount = 1000e6; // $1000

        vm.startPrank(user1);
        usdc.approve(address(bank), depositAmount);

        vm.expectEmit(true, true, true, true);
        emit Deposit(user1, address(usdc), depositAmount, depositAmount);

        bank.depositToken(address(usdc), depositAmount);
        vm.stopPrank();

        assertEq(bank.getBalance(user1), depositAmount);
        assertEq(bank.getTotalBankValueUSD(), depositAmount);
    }

    function test_DepositToken_DAI_WithSwap() public {
        // Add DAI as supported token
        vm.prank(manager);
        bank.addToken(address(dai));

        uint256 depositAmount = 1000e18; // 1000 DAI
        uint256 expectedUSDC = (depositAmount * uniswapRouter.exchangeRate()) / 10000;

        vm.startPrank(user1);
        dai.approve(address(bank), depositAmount);

        vm.expectEmit(true, true, true, true);
        emit TokenSwapped(user1, address(dai), address(usdc), depositAmount, expectedUSDC);

        bank.depositToken(address(dai), depositAmount);
        vm.stopPrank();

        assertEq(bank.getBalance(user1), expectedUSDC);
    }

    function test_DepositToken_RevertsOnZeroAmount() public {
        vm.startPrank(user1);
        vm.expectRevert(IKipuBankV3.ZeroAmount.selector);
        bank.depositToken(address(usdc), 0);
        vm.stopPrank();
    }

    function test_DepositToken_RevertsOnTokenNotSupported() public {
        MockERC20 unsupportedToken = new MockERC20("Unsupported", "UNS", 18);

        vm.startPrank(user1);
        vm.expectRevert(IKipuBankV3.TokenNotSupported.selector);
        bank.depositToken(address(unsupportedToken), 1000e18);
        vm.stopPrank();
    }

    function test_DepositToken_RevertsOnNativeToken() public {
        vm.startPrank(user1);
        vm.expectRevert(IKipuBankV3.TokenNotSupported.selector);
        bank.depositToken(address(0), 1 ether);
        vm.stopPrank();
    }

    /* ========== WITHDRAWAL TESTS ========== */

    function test_Withdraw_Success() public {
        // First deposit
        uint256 depositAmount = 10000e6;
        vm.startPrank(user1);
        usdc.approve(address(bank), depositAmount);
        bank.depositToken(address(usdc), depositAmount);

        // Then withdraw
        uint256 withdrawAmount = 5000e6;
        uint256 balanceBefore = usdc.balanceOf(user1);

        vm.expectEmit(true, true, true, true);
        emit Withdrawal(user1, address(usdc), withdrawAmount, withdrawAmount);

        bank.withdraw(withdrawAmount);
        vm.stopPrank();

        assertEq(bank.getBalance(user1), depositAmount - withdrawAmount);
        assertEq(usdc.balanceOf(user1), balanceBefore + withdrawAmount);
    }

    function test_Withdraw_RevertsOnZeroAmount() public {
        vm.startPrank(user1);
        vm.expectRevert(IKipuBankV3.ZeroAmount.selector);
        bank.withdraw(0);
        vm.stopPrank();
    }

    function test_Withdraw_RevertsOnInsufficientBalance() public {
        vm.startPrank(user1);
        vm.expectRevert(IKipuBankV3.InsufficientBalance.selector);
        bank.withdraw(1000e6);
        vm.stopPrank();
    }

    function test_Withdraw_RevertsOnWithdrawalLimitExceeded() public {
        // Deposit large amount
        uint256 depositAmount = 100_000e6;
        vm.startPrank(user1);
        usdc.approve(address(bank), depositAmount);
        bank.depositToken(address(usdc), depositAmount);

        // Try to withdraw more than limit
        vm.expectRevert(IKipuBankV3.WithdrawalLimitExceeded.selector);
        bank.withdraw(INITIAL_WITHDRAWAL_LIMIT + 1);
        vm.stopPrank();
    }

    /* ========== MANAGER FUNCTIONS TESTS ========== */

    function test_AddToken_Success() public {
        vm.startPrank(manager);

        vm.expectEmit(true, false, false, true);
        emit TokenAdded(address(dai), 18);

        bank.addToken(address(dai));
        vm.stopPrank();

        IKipuBankV3.TokenInfo memory info = bank.getTokenInfo(address(dai));
        assertTrue(info.isSupported);
        assertEq(info.decimals, 18);
        assertEq(uint8(info.status), uint8(IKipuBankV3.TokenStatus.Active));
    }

    function test_AddToken_RevertsOnTokenAlreadySupported() public {
        vm.startPrank(manager);
        bank.addToken(address(dai));

        vm.expectRevert(IKipuBankV3.TokenAlreadySupported.selector);
        bank.addToken(address(dai));
        vm.stopPrank();
    }

    function test_AddToken_RevertsOnZeroAddress() public {
        vm.startPrank(manager);
        vm.expectRevert(IKipuBankV3.ZeroAddress.selector);
        bank.addToken(address(0));
        vm.stopPrank();
    }

    function test_AddToken_RevertsOnUnauthorized() public {
        vm.startPrank(user1);
        vm.expectRevert();
        bank.addToken(address(dai));
        vm.stopPrank();
    }

    function test_SetTokenStatus_Success() public {
        vm.startPrank(manager);
        bank.addToken(address(dai));

        bank.setTokenStatus(address(dai), IKipuBankV3.TokenStatus.Paused);
        vm.stopPrank();

        IKipuBankV3.TokenInfo memory info = bank.getTokenInfo(address(dai));
        assertEq(uint8(info.status), uint8(IKipuBankV3.TokenStatus.Paused));
    }

    function test_SetBankCap_Success() public {
        uint256 newCap = 2_000_000e6;

        vm.startPrank(manager);
        vm.expectEmit(true, true, true, true);
        emit BankCapUpdated(INITIAL_BANK_CAP, newCap);

        bank.setBankCap(newCap);
        vm.stopPrank();

        assertEq(bank.bankCapUSD(), newCap);
    }

    function test_SetBankCap_RevertsOnZero() public {
        vm.startPrank(manager);
        vm.expectRevert(IKipuBankV3.InvalidBankCap.selector);
        bank.setBankCap(0);
        vm.stopPrank();
    }

    function test_SetWithdrawalLimit_Success() public {
        uint256 newLimit = 50_000e6;

        vm.prank(manager);
        bank.setWithdrawalLimit(newLimit);

        assertEq(bank.withdrawalLimitUSD(), newLimit);
    }

    function test_SetSlippageTolerance_Success() public {
        uint256 newSlippage = 200; // 2%

        vm.prank(manager);
        bank.setSlippageTolerance(newSlippage);

        assertEq(bank.slippageToleranceBps(), newSlippage);
    }

    function test_SetSlippageTolerance_RevertsOnInvalid() public {
        vm.startPrank(manager);
        vm.expectRevert(IKipuBankV3.InvalidSlippage.selector);
        bank.setSlippageTolerance(10001); // > 100%
        vm.stopPrank();
    }

    /* ========== ADMIN FUNCTIONS TESTS ========== */

    function test_Pause_Success() public {
        vm.prank(owner);
        bank.pause();

        assertTrue(bank.paused());
    }

    function test_Unpause_Success() public {
        vm.startPrank(owner);
        bank.pause();
        bank.unpause();
        vm.stopPrank();

        assertFalse(bank.paused());
    }

    function test_Pause_RevertsOnUnauthorized() public {
        vm.startPrank(user1);
        vm.expectRevert();
        bank.pause();
        vm.stopPrank();
    }

    function test_EmergencyWithdraw_ETH() public {
        // Send ETH to contract
        vm.deal(address(bank), 10 ether);

        uint256 balanceBefore = owner.balance;

        vm.prank(owner);
        bank.emergencyWithdraw(address(0), 5 ether, owner);

        assertEq(owner.balance, balanceBefore + 5 ether);
    }

    function test_EmergencyWithdraw_Token() public {
        // Send tokens to contract
        usdc.mint(address(bank), 10000e6);

        uint256 balanceBefore = usdc.balanceOf(owner);

        vm.prank(owner);
        bank.emergencyWithdraw(address(usdc), 5000e6, owner);

        assertEq(usdc.balanceOf(owner), balanceBefore + 5000e6);
    }

    /* ========== VIEW FUNCTIONS TESTS ========== */

    function test_GetBalance() public {
        vm.startPrank(user1);
        usdc.approve(address(bank), 1000e6);
        bank.depositToken(address(usdc), 1000e6);
        vm.stopPrank();

        assertEq(bank.getBalance(user1), 1000e6);
    }

    function test_GetTotalBankValueUSD() public {
        vm.startPrank(user1);
        usdc.approve(address(bank), 1000e6);
        bank.depositToken(address(usdc), 1000e6);
        vm.stopPrank();

        vm.startPrank(user2);
        usdc.approve(address(bank), 2000e6);
        bank.depositToken(address(usdc), 2000e6);
        vm.stopPrank();

        assertEq(bank.getTotalBankValueUSD(), 3000e6);
    }

    function test_GetSupportedTokens() public view {
        address[] memory tokens = bank.getSupportedTokens();
        assertEq(tokens.length, 2);
    }

    function test_GetTokenInfo() public view {
        IKipuBankV3.TokenInfo memory info = bank.getTokenInfo(address(usdc));
        assertTrue(info.isSupported);
        assertEq(info.decimals, 6);
    }

    function test_GetETHPriceUSD() public view {
        uint256 price = bank.getETHPriceUSD();
        assertEq(price, ETH_PRICE);
    }

    function test_GetExpectedUSDC_ForUSDC() public view {
        uint256 amount = 1000e6;
        uint256 expected = bank.getExpectedUSDC(address(usdc), amount);
        assertEq(expected, amount);
    }

    function test_GetExpectedUSDC_ForETH() public view {
        uint256 amount = 1 ether;
        uint256 expected = bank.getExpectedUSDC(address(0), amount);
        assertTrue(expected > 0);
    }

    /* ========== INTEGRATION TESTS ========== */

    function test_Integration_MultipleUsersDepositsAndWithdrawals() public {
        // User1 deposits ETH
        vm.startPrank(user1);
        bank.depositETH{value: 1 ether}();
        uint256 user1Balance = bank.getBalance(user1);
        vm.stopPrank();

        // User2 deposits USDC
        vm.startPrank(user2);
        usdc.approve(address(bank), 5000e6);
        bank.depositToken(address(usdc), 5000e6);
        uint256 user2Balance = bank.getBalance(user2);
        vm.stopPrank();

        // Verify total
        assertEq(bank.getTotalBankValueUSD(), user1Balance + user2Balance);

        // User1 withdraws half
        vm.startPrank(user1);
        bank.withdraw(user1Balance / 2);
        vm.stopPrank();

        // Verify balances
        assertEq(bank.getBalance(user1), user1Balance / 2);
        assertEq(bank.getTotalBankValueUSD(), user1Balance / 2 + user2Balance);
    }

    function test_Integration_TokenSwapFlow() public {
        // Add DAI
        vm.prank(manager);
        bank.addToken(address(dai));

        // User deposits DAI, should be swapped to USDC
        vm.startPrank(user1);
        uint256 daiAmount = 1000e18;
        dai.approve(address(bank), daiAmount);
        bank.depositToken(address(dai), daiAmount);
        vm.stopPrank();

        // Verify USDC balance (not DAI)
        uint256 balance = bank.getBalance(user1);
        assertTrue(balance > 0);

        // User can withdraw USDC
        vm.startPrank(user1);
        bank.withdraw(balance);
        vm.stopPrank();

        assertEq(bank.getBalance(user1), 0);
        assertTrue(usdc.balanceOf(user1) > 0);
    }

    /* ========== FUZZ TESTS ========== */

    function testFuzz_DepositETH(uint256 amount) public {
        // Bound amount to reasonable range
        amount = bound(amount, 0.01 ether, 50 ether);

        vm.deal(user1, amount);

        vm.startPrank(user1);
        bank.depositETH{value: amount}();
        vm.stopPrank();

        assertTrue(bank.getBalance(user1) > 0);
    }

    function testFuzz_DepositUSDC(uint256 amount) public {
        // Bound amount to reasonable range
        amount = bound(amount, 1e6, 100_000e6);

        usdc.mint(user1, amount);

        vm.startPrank(user1);
        usdc.approve(address(bank), amount);
        bank.depositToken(address(usdc), amount);
        vm.stopPrank();

        assertEq(bank.getBalance(user1), amount);
    }

    function testFuzz_WithdrawUSDC(uint256 depositAmount, uint256 withdrawAmount) public {
        depositAmount = bound(depositAmount, 1000e6, 50_000e6);
        withdrawAmount = bound(withdrawAmount, 1e6, depositAmount);

        usdc.mint(user1, depositAmount);

        vm.startPrank(user1);
        usdc.approve(address(bank), depositAmount);
        bank.depositToken(address(usdc), depositAmount);

        bank.withdraw(withdrawAmount);
        vm.stopPrank();

        assertEq(bank.getBalance(user1), depositAmount - withdrawAmount);
    }

    /* ========== RECEIVE/FALLBACK TESTS ========== */

    function test_Receive_Reverts() public {
        vm.startPrank(user1);
        (bool success, ) = address(bank).call{value: 1 ether}("");
        assertFalse(success);
        vm.stopPrank();
    }

    function test_Fallback_Reverts() public {
        vm.startPrank(user1);
        (bool success, ) = address(bank).call{value: 1 ether}("invalidFunction()");
        assertFalse(success);
        vm.stopPrank();
    }
}
