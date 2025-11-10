# Gas Cost Analysis - KipuBankV3

This document provides a detailed analysis of gas costs for all functions in the KipuBankV3 contract.

---

## 📊 Executive Summary

| Category | Average Gas | Cost USD* |
|-----------|-------------|-----------|
| **Deposits** | 200,000 - 300,000 | $30 - $45 |
| **Withdrawals** | 80,000 - 100,000 | $12 - $15 |
| **Management** | 50,000 - 80,000 | $7.5 - $12 |
| **Queries** | 3,000 - 10,000 | $0.45 - $1.5 |

*Assuming ETH = $3,000, Gas Price = 50 gwei

---

## 🔍 Detailed Analysis by Function

### 1. DEPOSITS

#### 1.1 `depositETH()` - ETH Deposit with Swap to USDC

**Operations:**
```solidity
1. Cache state variables (4 SLOAD)          ~8,400 gas
2. Read TokenInfo struct (1 SLOAD)          ~2,100 gas
3. Call getExpectedUSDC() (external view)   ~5,000 gas
4. Approve router implicitly                ~    0 gas (ETH doesn't require)
5. Swap via Uniswap V2 (swapExactETHForTokens)
   - WETH deposit                           ~50,000 gas
   - Uniswap swap logic                     ~80,000 gas
   - USDC transfer to contract              ~30,000 gas
6. Update balances[msg.sender] (SSTORE)     ~22,100 gas
7. Update totalBankValueUSD (SSTORE)        ~5,000 gas
8. Update tokenInfo (2 fields, SSTORE)      ~5,000 gas
9. Emit 2 events                            ~3,000 gas
10. ReentrancyGuard overhead                ~2,400 gas
```

**Total Estimated Gas:** **~213,000 gas**

**Breakdown:**
- Storage reads: ~10,500 gas
- Swap logic (Uniswap): ~160,000 gas
- Storage writes: ~32,100 gas
- Events: ~3,000 gas
- Overhead (reentrancy, validations): ~7,400 gas

**Cost in USD:** $31.95 (ETH = $3000, 50 gwei)

**Applied Optimizations:**
- ✅ State variable caching (savings: ~6,300 gas)
- ✅ Single writes (savings: ~10,000 gas)
- ✅ Unchecked arithmetic (savings: ~600 gas)
- **Total saved: ~16,900 gas vs unoptimized version**

---

#### 1.2 `depositToken()` - ERC20 Token Deposit with Swap to USDC

**Case A: Token = USDC (no swap)**

**Operations:**
```solidity
1. Cache state variables (4 SLOAD)          ~8,400 gas
2. Read TokenInfo struct (1 SLOAD)          ~2,100 gas
3. SafeTransferFrom (USDC → contract)       ~35,000 gas
4. Update balances[msg.sender] (SSTORE)     ~22,100 gas
5. Update totalBankValueUSD (SSTORE)        ~5,000 gas
6. Update tokenInfo (2 fields, SSTORE)      ~5,000 gas
7. Emit 1 event                             ~1,500 gas
8. ReentrancyGuard overhead                 ~2,400 gas
```

**Total Estimated Gas:** **~81,500 gas**

**Cost in USD:** $12.23

---

**Case B: Token ≠ USDC (with swap)**

**Operations:**
```solidity
1. Cache state variables (4 SLOAD)          ~8,400 gas
2. Read TokenInfo struct (1 SLOAD)          ~2,100 gas
3. Call getExpectedUSDC() (external view)   ~5,000 gas
4. SafeTransferFrom (Token → contract)      ~35,000 gas
5. forceApprove router (SSTORE)             ~22,100 gas
6. Swap via Uniswap V2 (swapExactTokensForTokens)
   - Token transfer to pair                 ~30,000 gas
   - Uniswap swap logic                     ~80,000 gas
   - USDC transfer to contract              ~30,000 gas
7. Update balances[msg.sender] (SSTORE)     ~22,100 gas
8. Update totalBankValueUSD (SSTORE)        ~5,000 gas
9. Update tokenInfo (2 fields, SSTORE)      ~5,000 gas
10. Emit 2 events                           ~3,000 gas
11. ReentrancyGuard overhead                ~2,400 gas
```

**Total Estimated Gas:** **~250,100 gas**

**Cost in USD:** $37.52

**Applied Optimizations:**
- ✅ Memory struct for TokenInfo (savings: ~4,200 gas)
- ✅ Single SSTORE for token stats (savings: ~10,000 gas)
- ✅ Unchecked arithmetic (savings: ~600 gas)
- **Total saved: ~14,800 gas**

---

### 2. WITHDRAWALS

#### 2.1 `withdraw()` - USDC Withdrawal

**Operations:**
```solidity
1. Cache state variables (4 SLOAD)          ~8,400 gas
2. Validations                              ~1,000 gas
3. Update balances[msg.sender] (SSTORE)     ~5,000 gas (warm slot)
4. Update totalBankValueUSD (SSTORE)        ~5,000 gas (warm slot)
5. Update tokenInfo.withdrawalCount (SSTORE)~5,000 gas
6. SafeTransfer USDC to user                ~30,000 gas
7. Emit 1 event                             ~1,500 gas
8. ReentrancyGuard overhead                 ~2,400 gas
```

**Total Estimated Gas:** **~58,300 gas**

**Cost in USD:** $8.75

**Applied Optimizations:**
- ✅ State variable caching (savings: ~6,300 gas)
- ✅ Unchecked arithmetic (savings: ~600 gas)
- ✅ Single SSTORE per variable (savings: ~10,000 gas)
- **Total saved: ~16,900 gas**

**Note:** If it's the user's first withdrawal, SSTORE costs more (~22,100 gas each), total would be ~93,300 gas.

---

### 3. MANAGER FUNCTIONS

#### 3.1 `addToken()` - Add Supported Token

**Operations:**
```solidity
1. Check if already supported (1 SLOAD)     ~2,100 gas
2. Check supportedTokens.length (1 SLOAD)   ~2,100 gas
3. Call token.decimals() (external view)    ~5,000 gas
4. Create TokenInfo struct (1 SSTORE)       ~22,100 gas
5. Push to supportedTokens array (SSTORE)   ~22,100 gas
6. Emit event                               ~1,000 gas
```

**Total Estimated Gas:** **~54,400 gas**

**Cost in USD:** $8.16

---

#### 3.2 `setTokenStatus()` - Change Token Status

**Operations:**
```solidity
1. Read tokenInfo (1 SLOAD)                 ~2,100 gas
2. Update tokenInfo.status (1 SSTORE)       ~5,000 gas
3. Emit event                               ~1,000 gas
```

**Total Estimated Gas:** **~8,100 gas**

**Cost in USD:** $1.22

---

#### 3.3 `setBankCap()` - Update Bank Cap

**Operations:**
```solidity
1. Cache old bankCapUSD (1 SLOAD)           ~2,100 gas
2. Cache totalBankValueUSD (1 SLOAD)        ~2,100 gas
3. Validations                              ~1,000 gas
4. Update bankCapUSD (1 SSTORE)             ~5,000 gas
5. Emit event                               ~1,000 gas
```

**Total Estimated Gas:** **~11,200 gas**

**Cost in USD:** $1.68

**Applied Optimizations:**
- ✅ Cache old value before writing (savings: ~2,100 gas)

---

#### 3.4 `setWithdrawalLimit()` - Update Withdrawal Limit

**Operations:**
```solidity
1. Cache old withdrawalLimitUSD (1 SLOAD)   ~2,100 gas
2. Cache bankCapUSD (1 SLOAD)               ~2,100 gas
3. Validations                              ~1,000 gas
4. Update withdrawalLimitUSD (1 SSTORE)     ~5,000 gas
5. Emit event                               ~1,000 gas
```

**Total Estimated Gas:** **~11,200 gas**

**Cost in USD:** $1.68

---

#### 3.5 `setSlippageTolerance()` - Update Slippage

**Operations:**
```solidity
1. Validation                               ~500 gas
2. Cache old slippageToleranceBps (1 SLOAD) ~2,100 gas
3. Update slippageToleranceBps (1 SSTORE)   ~5,000 gas
4. Emit event                               ~1,000 gas
```

**Total Estimated Gas:** **~8,600 gas**

**Cost in USD:** $1.29

---

### 4. ADMIN FUNCTIONS

#### 4.1 `pause()` - Pause Contract

**Operations:**
```solidity
1. Check role (2 SLOAD)                     ~4,200 gas
2. Update paused state (1 SSTORE)           ~5,000 gas
3. Emit event                               ~1,000 gas
```

**Total Estimated Gas:** **~10,200 gas**

**Cost in USD:** $1.53

---

#### 4.2 `unpause()` - Unpause Contract

**Operations:**
```solidity
1. Check role (2 SLOAD)                     ~4,200 gas
2. Update paused state (1 SSTORE)           ~5,000 gas
3. Emit event                               ~1,000 gas
```

**Total Estimated Gas:** **~10,200 gas**

**Cost in USD:** $1.53

---

#### 4.3 `emergencyWithdraw()` - Emergency Withdrawal

**Case A: ETH**

**Operations:**
```solidity
1. Check role (2 SLOAD)                     ~4,200 gas
2. Validations                              ~1,500 gas
3. Call to transfer ETH                     ~10,000 gas
```

**Total Estimated Gas:** **~15,700 gas**

**Cost in USD:** $2.36

---

**Case B: ERC20**

**Operations:**
```solidity
1. Check role (2 SLOAD)                     ~4,200 gas
2. Validations                              ~1,500 gas
3. SafeTransfer token                       ~30,000 gas
```

**Total Estimated Gas:** **~35,700 gas**

**Cost in USD:** $5.36

---

### 5. VIEW FUNCTIONS (Read-Only)

#### 5.1 `getBalance()` - Query User Balance

**Operations:**
```solidity
1. Read balances[user] (1 SLOAD)            ~2,100 gas
```

**Total Estimated Gas:** **~2,100 gas**

**Cost in USD:** $0.32 (if called in tx, free in view call)

---

#### 5.2 `getTotalBankValueUSD()` - Query Bank Total

**Operations:**
```solidity
1. Read totalBankValueUSD (1 SLOAD)         ~2,100 gas
```

**Total Estimated Gas:** **~2,100 gas**

**Cost in USD:** $0.32 (if called in tx, free in view call)

---

#### 5.3 `getSupportedTokens()` - List Supported Tokens

**Operations:**
```solidity
1. Read supportedTokens array length        ~2,100 gas
2. Copy array to memory (~5 tokens)         ~1,000 gas
```

**Total Estimated Gas:** **~3,100 gas** (for 5 tokens)

**Note:** Increases ~200 gas per additional token.

**Cost in USD:** $0.47 (if called in tx, free in view call)

---

#### 5.4 `getTokenInfo()` - Query Token Info

**Operations:**
```solidity
1. Read tokenInfo[token] struct (1 SLOAD)   ~2,100 gas
2. Copy struct to memory                    ~500 gas
```

**Total Estimated Gas:** **~2,600 gas**

**Cost in USD:** $0.39 (if called in tx, free in view call)

---

#### 5.5 `getETHPriceUSD()` - Query ETH Price

**Operations:**
```solidity
1. Call Chainlink oracle                    ~5,000 gas
2. Validations                              ~1,000 gas
```

**Total Estimated Gas:** **~6,000 gas**

**Cost in USD:** $0.90 (if called in tx, free in view call)

---

#### 5.6 `getExpectedUSDC()` - Estimate USDC from Swap

**Operations:**
```solidity
1. Build path array                         ~500 gas
2. Call Uniswap getAmountsOut               ~8,000 gas
3. Validations                              ~500 gas
```

**Total Estimated Gas:** **~9,000 gas**

**Cost in USD:** $1.35 (if called in tx, free in view call)

---

## 📈 Comparison: With and Without Optimizations

| Function | Without Optimizations | With Optimizations | Savings |
|---------|---------------------|-------------------|--------|
| `depositETH()` | ~230,000 gas | ~213,000 gas | **-7.4%** |
| `depositToken()` (swap) | ~265,000 gas | ~250,000 gas | **-5.7%** |
| `withdraw()` | ~75,000 gas | ~58,000 gas | **-22.7%** |
| `setBankCap()` | ~13,300 gas | ~11,200 gas | **-15.8%** |
| `setWithdrawalLimit()` | ~13,300 gas | ~11,200 gas | **-15.8%** |

**Total average savings: ~12-15%**

---

## 💰 Cost Calculations in Different Scenarios

### Scenario 1: Low Gas Price (30 gwei)

| Function | Gas | Cost ETH | Cost USD (ETH=$3000) |
|---------|-----|----------|---------------------|
| depositETH() | 213,000 | 0.00639 ETH | $19.17 |
| depositToken() (swap) | 250,000 | 0.00750 ETH | $22.50 |
| depositToken() (USDC) | 81,500 | 0.00245 ETH | $7.35 |
| withdraw() | 58,000 | 0.00174 ETH | $5.22 |
| addToken() | 54,400 | 0.00163 ETH | $4.89 |

---

### Scenario 2: Medium Gas Price (50 gwei) - CURRENT

| Function | Gas | Cost ETH | Cost USD (ETH=$3000) |
|---------|-----|----------|---------------------|
| depositETH() | 213,000 | 0.01065 ETH | **$31.95** |
| depositToken() (swap) | 250,000 | 0.01250 ETH | **$37.50** |
| depositToken() (USDC) | 81,500 | 0.00408 ETH | **$12.24** |
| withdraw() | 58,000 | 0.00290 ETH | **$8.70** |
| addToken() | 54,400 | 0.00272 ETH | **$8.16** |

---

### Scenario 3: High Gas Price (100 gwei)

| Function | Gas | Cost ETH | Cost USD (ETH=$3000) |
|---------|-----|----------|---------------------|
| depositETH() | 213,000 | 0.0213 ETH | $63.90 |
| depositToken() (swap) | 250,000 | 0.0250 ETH | $75.00 |
| depositToken() (USDC) | 81,500 | 0.00815 ETH | $24.45 |
| withdraw() | 58,000 | 0.00580 ETH | $17.40 |
| addToken() | 54,400 | 0.00544 ETH | $16.32 |

---

## 🎯 Recommendations for Users

### To Minimize Gas Costs:

1. **Deposit USDC directly** instead of other tokens
   - Savings: ~170,000 gas (~$25.50 at 50 gwei)

2. **Make large deposits** instead of multiple small ones
   - Fixed cost of ~213,000 gas per deposit regardless of amount

3. **Monitor gas prices**
   - Use tools like [ETH Gas Station](https://ethgasstation.info/)
   - Wait for gas < 50 gwei for non-urgent operations

4. **Use L2s in the future** (when KipuBankV3 deploys on L2)
   - Polygon: ~100x cheaper
   - Arbitrum: ~10x cheaper
   - Optimism: ~10x cheaper

---

## 📊 Gas Distribution by Category

### Read Operations (SLOAD)
- **Base cost:** 2,100 gas per slot
- **Warm access:** 100 gas (already read in same tx)
- **Cold access:** 2,100 gas (first read)

### Write Operations (SSTORE)
- **Slot zero → non-zero:** 22,100 gas (first write)
- **Slot non-zero → non-zero:** 5,000 gas (update)
- **Slot non-zero → zero:** 5,000 gas + 15,000 gas refund

### External Calls
- **Call to external contract:** 2,600 gas base
- **ERC20 transfer:** ~30,000-50,000 gas
- **Uniswap swap:** ~80,000-120,000 gas

### Events
- **LOG0 (no indexed):** ~375 gas
- **LOG1 (1 indexed):** ~750 gas
- **LOG2 (2 indexed):** ~1,125 gas
- **LOG3 (3 indexed):** ~1,500 gas
- **+ ~8 gas per byte of data**

---

## 🧪 How to Run Gas Analysis

To get exact gas costs in your environment:

```bash
# 1. Run tests with gas report
forge test --gas-report

# 2. View only specific functions
forge test --gas-report --match-contract KipuBankV3Test

# 3. Generate detailed report in file
forge test --gas-report > gas-report.txt

# 4. Gas snapshot (compare changes)
forge snapshot
forge snapshot --diff

# 5. Gas with optimizations disabled (comparison)
forge test --gas-report --no-optimizer
```

---

## 📝 Important Notes

1. **Values are estimates** based on typical Solidity operations
2. **Actual gas may vary** depending on:
   - Blockchain state (hot/cold storage slots)
   - Uniswap swap complexity
   - Token pair liquidity
   - Solidity compiler version

3. **View functions are FREE** when called outside transactions (via `eth_call`)

4. **Applied optimizations:**
   - State variable caching
   - Single SLOAD/SSTORE per variable
   - Unchecked arithmetic where safe
   - Memory structs instead of storage pointers

---

## 🔗 References

- [Ethereum Yellow Paper - Gas Costs](https://ethereum.github.io/yellowpaper/paper.pdf)
- [EIP-2200: Structured Definitions for Net Gas Metering](https://eips.ethereum.org/EIPS/eip-2200)
- [Solidity Optimizer](https://docs.soliditylang.org/en/latest/internals/optimizer.html)
- [ETH Gas Station](https://ethgasstation.info/)

---

**Last updated:** 2025-11-09
**Contract version:** KipuBankV3 v1.0.0
**Solidity:** 0.8.30
**Optimizer:** Enabled (200 runs)
**Author**: Hernan Herrera
**Organization**: White Paper
