# Testing Guide - KipuBankV3

**Author**: Hernan Herrera
**Organization**: White Paper
**Date**: 2025-11-09

This guide will help you run all tests and gas analysis for the project.

---

## 📋 Prerequisites

### 1. Install Foundry

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify installation
forge --version
cast --version
anvil --version
```

---

## 🧪 Running Tests

### Basic Tests

```bash
# Run all tests
forge test

# Expected output:
# Running 65 tests for test/KipuBankV3.t.sol:KipuBankV3Test
# [PASS] test_AddToken_Success() (gas: 54432)
# [PASS] test_Constructor_Success() (gas: 1234567)
# ...
# Test result: ok. 65 passed; 0 failed; finished in 1.23s
```

### Tests with Verbosity

```bash
# Level 1: Show errors
forge test -v

# Level 2: Show logs
forge test -vv

# Level 3: Show stack traces
forge test -vvv

# Level 4: Show setup traces
forge test -vvvv

# Level 5: Show everything
forge test -vvvvv
```

### Specific Tests

```bash
# Run only deposit tests
forge test --match-test "Deposit"

# Run only withdrawal tests
forge test --match-test "Withdraw"

# Run a specific test
forge test --match-test "test_DepositETH_Success"

# Run tests that do NOT contain a pattern
forge test --no-match-test "Fuzz"
```

### Tests by Contract

```bash
# Run only KipuBankV3Test tests
forge test --match-contract KipuBankV3Test

# Run tests from multiple contracts
forge test --match-contract "KipuBank|Mock"
```

---

## ⛽ Gas Analysis

### Basic Gas Report

```bash
# Generate gas report
forge test --gas-report

# Expected output:
# ╭─────────────────────────────────────────────────────────────╮
# │ KipuBankV3 contract                                         │
# ├─────────────────────────────┬─────────────────────────────┤
# │ Function Name               │ Gas                         │
# ├─────────────────────────────┼─────────────────────────────┤
# │ depositETH                  │ 213045                      │
# │ depositToken                │ 250123 / 81523              │
# │ withdraw                    │ 58234                       │
# │ ...                         │                             │
# ╰─────────────────────────────┴─────────────────────────────╯
```

### Gas Report to File

```bash
# Save complete report
forge test --gas-report > gas-report.txt

# View report
cat gas-report.txt

# Or with pagination
less gas-report.txt
```

### Gas Snapshot

```bash
# Create gas snapshot
forge snapshot

# This creates .gas-snapshot with:
# test_DepositETH_Success() (gas: 213045)
# test_DepositToken_USDC_Success() (gas: 81523)
# ...

# View snapshot
cat .gas-snapshot

# Compare with changes
forge snapshot --diff

# Output shows changes:
# test_DepositETH_Success() (gas: 213045 → 210123) [-2922]
# test_Withdraw_Success() (gas: 58234 → 57123) [-1111]
```

### Gas with Different Optimizations

```bash
# Without optimizer
forge test --gas-report --no-optimizer

# With optimizer (200 runs) - DEFAULT
forge test --gas-report --optimizer-runs 200

# With optimizer (1000 runs) - For production
forge test --gas-report --optimizer-runs 1000

# With optimizer (1 run) - For cheap deployment
forge test --gas-report --optimizer-runs 1
```

---

## 📊 Coverage (Test Coverage)

### Generate Coverage Report

```bash
# Basic coverage
forge coverage

# Expected output:
# ╭─────────────────────────────────────────────────────────╮
# │ File                    │ % Lines  │ % Statements │ ...│
# ├─────────────────────────┼──────────┼──────────────┼────┤
# │ src/KipuBankV3.sol      │ 78.26%   │ 80.43%       │... │
# │ Total                   │ 78.26%   │ 80.43%       │... │
# ╰─────────────────────────┴──────────┴──────────────┴────╯
```

### Detailed Coverage with LCOV

```bash
# Generate LCOV file
forge coverage --report lcov

# This creates lcov.info

# Generate HTML (requires lcov/genhtml)
genhtml lcov.info --output-directory coverage

# Open in browser
open coverage/index.html  # macOS
xdg-open coverage/index.html  # Linux
start coverage/index.html  # Windows
```

### Coverage by File

```bash
# View coverage only for KipuBankV3.sol
forge coverage --report summary --match-path "src/KipuBankV3.sol"

# View coverage for specific tests
forge coverage --match-test "Deposit"
```

---

## 🔍 Debugging

### Tests with Traces

```bash
# View execution traces
forge test --match-test "test_DepositETH_Success" -vvvv

# View traces with opcodes
forge test --match-test "test_DepositETH_Success" --debug

# This opens interactive debugger:
# - Enter: next step
# - 'q': quit
# - 'c': continue
# - 'j/k': navigate stack
```

### Tests with Fork

```bash
# Run tests on mainnet fork
forge test --fork-url $MAINNET_RPC_URL

# Run tests on Sepolia fork
forge test --fork-url $SEPOLIA_RPC_URL

# Fork at specific block
forge test --fork-url $MAINNET_RPC_URL --fork-block-number 18000000
```

### Tests with Logs

```bash
# In your tests, add:
# import "forge-std/console.sol";
# console.log("Balance:", balance);
# console.log("User:", user);

# Run with -vv to see logs
forge test -vv
```

---

## 🚀 Complete Analysis Script

Use the included script for complete analysis:

```bash
# Make executable
chmod +x test-gas.sh

# Execute
./test-gas.sh

# Output:
# ======================================
#   KipuBankV3 - Gas Analysis
# ======================================
#
# [1/5] Compiling contracts...
# ✓ Compilation successful
#
# [2/5] Running tests...
# ✓ Tests successful
#
# [3/5] Generating gas report...
# ✓ Report generated: gas-report-full.txt
#
# [4/5] Generating gas snapshot...
# ✓ Snapshot generated: .gas-snapshot
#
# [5/5] Gas Summary by Function
# ...
```

---

## 📈 Integration Tests

### Test with Anvil (Local)

```bash
# Terminal 1: Start Anvil
anvil

# Output:
# Listening on 127.0.0.1:8545
# Chain ID: 31337
# Available Accounts:
# (0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
# Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Terminal 2: Deploy and test
forge script script/DeployKipuBankV3.s.sol \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

### Test on Sepolia

```bash
# Make sure .env is configured
source .env

# Run tests on Sepolia fork
forge test --fork-url $SEPOLIA_RPC_URL -vv
```

---

## 🎯 Specific Tests by Functionality

### Deposit Tests

```bash
# All deposit tests
forge test --match-test "Deposit" --gas-report

# Only ETH deposits
forge test --match-test "DepositETH" -vv

# Only token deposits
forge test --match-test "DepositToken" -vv

# Fuzz tests for deposits
forge test --match-test "testFuzz_Deposit" -vv
```

### Withdrawal Tests

```bash
# All withdrawal tests
forge test --match-test "Withdraw" --gas-report

# With verbosity
forge test --match-test "Withdraw" -vv
```

### Manager Tests

```bash
# Manager functions
forge test --match-test "AddToken|SetToken|SetBank|SetWithdrawal|SetSlippage" --gas-report
```

### Admin Tests

```bash
# Admin functions
forge test --match-test "Pause|Emergency" --gas-report
```

### View Functions Tests

```bash
# View functions
forge test --match-test "GetBalance|GetTotal|GetSupported|GetToken|GetETH|GetExpected" -vv
```

---

## 🔄 Development Workflow

### 1. Make Code Changes

```bash
# Edit src/KipuBankV3.sol
vim src/KipuBankV3.sol
```

### 2. Compile and Verify

```bash
# Compile
forge build

# Verify warnings
forge build --force 2>&1 | grep -i warning
```

### 3. Run Tests

```bash
# Basic tests
forge test

# If they fail, run with verbosity
forge test -vvv
```

### 4. Verify Gas

```bash
# Compare gas before/after
forge snapshot --diff
```

### 5. Verify Coverage

```bash
# Ensure >= 50% coverage
forge coverage
```

### 6. Commit Changes

```bash
git add .
git commit -m "feat: improve X with Y gas savings"
```

---

## 📊 Expected Benchmarks

### Expected Test Results

```
Running 65 tests for test/KipuBankV3.t.sol:KipuBankV3Test

Constructor Tests (6):
✓ test_Constructor_Success
✓ test_Constructor_GrantsRoles
✓ test_Constructor_AddsDefaultTokens
✓ test_Constructor_RevertsOnZeroAddress
✓ test_Constructor_RevertsOnInvalidBankCap
✓ test_Constructor_RevertsOnInvalidWithdrawalLimit

Deposit ETH Tests (6):
✓ test_DepositETH_Success (gas: 213045)
✓ test_DepositETH_MultipleDeposits
✓ test_DepositETH_RevertsOnZeroAmount
✓ test_DepositETH_RevertsWhenPaused
✓ test_DepositETH_RevertsOnBankCapExceeded

Deposit Token Tests (7):
✓ test_DepositToken_USDC_Success (gas: 81523)
✓ test_DepositToken_DAI_WithSwap (gas: 250123)
✓ test_DepositToken_RevertsOnZeroAmount
✓ test_DepositToken_RevertsOnTokenNotSupported
✓ test_DepositToken_RevertsOnNativeToken

... (rest of tests)

Test result: ok. 65 passed; 0 failed; finished in 2.34s
```

### Expected Gas

```
Deployment Cost: 2,345,678 gas

Function Gas Costs:
- depositETH(): ~213,000 gas
- depositToken() [USDC]: ~81,500 gas
- depositToken() [swap]: ~250,000 gas
- withdraw(): ~58,000 gas
- addToken(): ~54,400 gas
- setBankCap(): ~11,200 gas
- setWithdrawalLimit(): ~11,200 gas
- pause(): ~10,200 gas
```

### Expected Coverage

```
src/KipuBankV3.sol:
- Lines: 78%+
- Statements: 80%+
- Branches: 65%+
- Functions: 85%+
```

---

## ❓ Troubleshooting

### Error: "forge: command not found"

```bash
# Reinstall Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Error: "Failed to resolve imports"

```bash
# Install dependencies
forge install

# Or manually:
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink --no-commit
```

### Error: "Stack too deep"

```bash
# Compile with via-ir
forge build --via-ir

# Or adjust optimizer runs
forge build --optimizer-runs 1
```

### Tests Fail Randomly

```bash
# Run with fixed seed
forge test --fuzz-seed 42

# Increase fuzz runs
forge test --fuzz-runs 1000
```

---

## 📚 Additional Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Forge Testing Cheatsheet](https://github.com/dabit3/foundry-cheatsheet)
- [Foundry Discord](https://discord.gg/foundry)
- [GitHub Issues](https://github.com/foundry-rs/foundry/issues)

---

## ✅ Testing Checklist

Before deployment or PR:

- [ ] `forge build` compiles without errors
- [ ] `forge test` - all tests pass
- [ ] `forge test --gas-report` - gas is reasonable
- [ ] `forge coverage` - coverage >= 50%
- [ ] `forge snapshot --diff` - gas changes are expected
- [ ] `slither .` - no critical vulnerabilities
- [ ] Integration tests on fork pass
- [ ] Documentation updated

---

**Happy Testing!** 🧪✨
