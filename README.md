# KipuBankV3 - Advanced DeFi Banking System

![Solidity](https://img.shields.io/badge/Solidity-0.8.30-blue)
![Foundry](https://img.shields.io/badge/Foundry-latest-green)
![License](https://img.shields.io/badge/license-MIT-blue)

## 📋 Table of Contents

- [Executive Summary](#executive-summary)
- [Main Features](#main-features)
- [Improvements over KipuBankV2](#improvements-over-kipubankv2)
- [System Architecture](#system-architecture)
- [Installation and Setup](#installation-and-setup)
- [Usage and Deployment](#usage-and-deployment)
- [Contract Interaction](#contract-interaction)
- [Testing and Coverage](#testing-and-coverage)
- [Threat Analysis](#threat-analysis)
- [Design Decisions](#design-decisions)
- [Audit and Security](#audit-and-security)
- [Roadmap](#roadmap)

---

## 🎯 Executive Summary

**KipuBankV3** is an advanced DeFi banking system that allows users to deposit **any token supported by Uniswap V2**, automatically swap it to **USDC**, and securely manage their balances. The system respects a maximum bank limit (bank cap) and preserves all KipuBankV2 functionality, while adding composability capabilities with DeFi protocols.

### Main Use Cases

1. **Unified Deposit**: Users can deposit ETH, USDC, or any ERC20 token with liquidity on Uniswap V2
2. **Automatic Conversion**: All tokens are automatically converted to USDC, simplifying management
3. **Risk Management**: Bank cap and withdrawal limits protect the protocol
4. **Governance**: Role system (Admin/Manager) for decentralized management

---

## ✨ Main Features

### 1. 🔄 Multi-Token Deposits with Automatic Swap

```solidity
// Deposit ETH (automatically converted to USDC)
function depositETH() external payable

// Deposit any supported ERC20 token
function depositToken(address token, uint256 amount) external
```

**Deposit Process:**
1. User deposits Token X
2. If Token X ≠ USDC → Automatic swap via Uniswap V2
3. Resulting USDC is credited to user's balance
4. Bank cap validated post-swap

### 2. 🛡️ Security Protections

- **ReentrancyGuard**: Prevention of reentrancy attacks
- **Pausable**: Emergency pause mechanism
- **AccessControl**: Granular roles (Admin, Manager)
- **Slippage Protection**: Configurable tolerance for swaps
- **Price Staleness Check**: Chainlink oracle freshness validation

### 3. 📊 External Protocol Integration

- **Uniswap V2**: Automatic token swaps
- **Chainlink**: Price oracles for ETH/USD
- **OpenZeppelin**: Battle-tested security libraries

### 4. 💰 Capacity Management

```solidity
uint256 public bankCapUSD;           // Maximum capacity in USD
uint256 public totalBankValueUSD;    // Total stored value
uint256 public withdrawalLimitUSD;   // Withdrawal limit per transaction
```

### 5. 🎛️ Flexible Configuration

- **Bank Cap**: Adjustable by Manager
- **Withdrawal Limit**: Configurable per-transaction limit
- **Slippage Tolerance**: Customizable slippage tolerance
- **Token Status**: Tokens can be paused individually

---

## 🚀 Improvements over KipuBankV2

| Feature | KipuBankV2 | KipuBankV3 |
|---------|------------|------------|
| Supported Tokens | ETH + USDC + limited ERC20 | Any token with USDC pair on Uniswap V2 |
| Token Conversion | Manual / Not supported | Automatic via Uniswap V2 |
| Internal Balance | Multi-token | Unified in USDC |
| Slippage Protection | ❌ | ✅ Configurable |
| Pricing | Chainlink for ETH only | Chainlink + Uniswap V2 |
| DeFi Composability | Limited | High (Uniswap integration) |
| Gas Efficiency | Good | Optimized (state caching) |

### Key V3 Advantages

1. **User Simplicity**: Single USDC balance, no need to manage multiple tokens
2. **Greater Liquidity**: Access to any token with liquidity on Uniswap
3. **Lower Complexity**: Frontend only needs to display USDC balance
4. **Better UX**: Users don't need to worry about which token to deposit

---

## 🏗️ System Architecture

### Deposit with Swap Flow Diagram

```
┌─────────────┐
│    User     │
└──────┬──────┘
       │ 1. depositToken(DAI, 1000)
       ▼
┌─────────────────────┐
│   KipuBankV3        │
│  ┌──────────────┐   │
│  │ Validations  │   │ 2. Validate supported token, active, etc.
│  └──────┬───────┘   │
│         │           │
│  ┌──────▼───────┐   │
│  │ Transfer DAI │   │ 3. SafeTransferFrom user → contract
│  └──────┬───────┘   │
│         │           │
│  ┌──────▼────────┐  │
│  │ Approve Router│  │ 4. Approve Uniswap Router
│  └──────┬────────┘  │
└─────────┼───────────┘
          │
          ▼
┌──────────────────────┐
│  Uniswap V2 Router   │
│                      │ 5. swapExactTokensForTokens
│  DAI → USDC         │    (DAI → USDC)
└──────────┬───────────┘
           │ 6. Return USDC amount
           ▼
┌─────────────────────┐
│   KipuBankV3        │
│  ┌──────────────┐   │
│  │ Update State │   │ 7. balances[user] += usdcAmount
│  │              │   │    totalBankValueUSD += usdcAmount
│  └──────┬───────┘   │
│         │           │
│  ┌──────▼───────┐   │
│  │ Emit Events  │   │ 8. TokenSwapped + Deposit events
│  └──────────────┘   │
└─────────────────────┘
```

### Main Components

#### 1. **KipuBankV3.sol** (Main Contract)
- Deposit and withdrawal management
- Uniswap V2 integration
- Access control and pausability
- Bank cap management

#### 2. **IKipuBankV3.sol** (Interface)
- Defines all public methods
- Custom events and errors
- Data structures

#### 3. **IUniswapV2Router02.sol** (External Interface)
- Uniswap V2 swap functions
- Quote functions for estimations

#### 4. **Mocks** (Testing)
- MockERC20: Test tokens
- MockV3Aggregator: Mock price oracle
- MockUniswapV2Router: Mock router for tests

---

## 📦 Installation and Setup

### Prerequisites

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify installation
forge --version
```

### Installation

```bash
# Clone repository
git clone https://github.com/your-username/KipuBankV3.git
cd KipuBankV3

# Install dependencies
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink --no-commit

# Compile contracts
forge build
```

### Environment Variable Setup

```bash
# Copy example file
cp .env.example .env

# Edit .env with your values
nano .env
```

Example `.env`:

```bash
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY

# Contract addresses on Sepolia
UNISWAP_V2_ROUTER_SEPOLIA=0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008
USDC_SEPOLIA=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
ETH_USD_PRICE_FEED_SEPOLIA=0x694AA1769357215DE4FAC081bf1f309aDC325306
```

---

## 🚢 Usage and Deployment

### Run Tests

```bash
# Run all tests
forge test

# Run tests with verbosity
forge test -vvv

# Run specific tests
forge test --match-test test_DepositETH_Success

# Run tests with gas reporting
forge test --gas-report
```

### Test Coverage

```bash
# Generate coverage report
forge coverage

# Generate detailed report with lcov
forge coverage --report lcov

# Visualize coverage in HTML (requires genhtml)
genhtml lcov.info --output-directory coverage
open coverage/index.html
```

### Deploy on Sepolia

```bash
# Deploy contract
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY

# The script will display the deployed contract address
```

### Deploy on Mainnet

```bash
# ⚠️ WARNING: Deploying on mainnet requires real ETH

forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### Manually Verify Contract

```bash
forge verify-contract \
  --chain-id 11155111 \
  --compiler-version 0.8.30 \
  --num-of-optimizations 200 \
  --constructor-args $(cast abi-encode "constructor(address,address,address,uint256,uint256,uint256)" <ETH_FEED> <ROUTER> <USDC> <BANK_CAP> <WITHDRAWAL_LIMIT> <SLIPPAGE>) \
  <CONTRACT_ADDRESS> \
  src/KipuBankV3.sol:KipuBankV3 \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

---

## 🔌 Contract Interaction

### For Users (Deposit and Withdraw)

#### 1. Deposit ETH

```javascript
// Web3.js
const web3 = new Web3(window.ethereum);
const contract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);

await contract.methods.depositETH().send({
  from: userAddress,
  value: web3.utils.toWei('1', 'ether')
});
```

```solidity
// Solidity (from another contract)
IKipuBankV3(bankAddress).depositETH{value: 1 ether}();
```

#### 2. Deposit ERC20 Tokens

```javascript
// First approve the token
const tokenContract = new web3.eth.Contract(ERC20_ABI, TOKEN_ADDRESS);
await tokenContract.methods.approve(
  CONTRACT_ADDRESS,
  amount
).send({ from: userAddress });

// Then deposit
await contract.methods.depositToken(TOKEN_ADDRESS, amount).send({
  from: userAddress
});
```

#### 3. Withdraw USDC

```javascript
// Withdraw 100 USDC (6 decimals)
const amount = '100000000'; // 100 * 10^6

await contract.methods.withdraw(amount).send({
  from: userAddress
});
```

#### 4. Check Balance

```javascript
// Get USDC balance
const balance = await contract.methods.getBalance(userAddress).call();
console.log(`Balance: ${balance / 1e6} USDC`);

// Get total bank value
const totalValue = await contract.methods.getTotalBankValueUSD().call();
console.log(`Total Bank Value: $${totalValue / 1e6}`);
```

### For Managers (Configuration)

#### 1. Add New Token

```javascript
// Add DAI as supported token
await contract.methods.addToken(DAI_ADDRESS).send({
  from: managerAddress
});
```

#### 2. Pause Token

```javascript
// Pause a token (1 = Active, 2 = Paused)
await contract.methods.setTokenStatus(TOKEN_ADDRESS, 2).send({
  from: managerAddress
});
```

#### 3. Update Bank Cap

```javascript
// Update bank cap to $2M
const newCap = '2000000000000'; // 2M * 10^6
await contract.methods.setBankCap(newCap).send({
  from: managerAddress
});
```

#### 4. Update Slippage

```javascript
// Update slippage to 2% (200 basis points)
await contract.methods.setSlippageTolerance(200).send({
  from: managerAddress
});
```

### For Admins (Emergencies)

#### 1. Pause Contract

```javascript
await contract.methods.pause().send({
  from: adminAddress
});
```

#### 2. Unpause Contract

```javascript
await contract.methods.unpause().send({
  from: adminAddress
});
```

#### 3. Emergency Withdrawal

```javascript
// Withdraw 1000 USDC in emergency
await contract.methods.emergencyWithdraw(
  USDC_ADDRESS,
  '1000000000', // 1000 * 10^6
  recipientAddress
).send({ from: adminAddress });
```

---

## 🧪 Testing and Coverage

### Test Suite

The project includes **65+ tests** covering:

1. **Constructor Tests** (6 tests)
   - Correct initialization
   - Parameter validation
   - Role assignment

2. **Deposit ETH Tests** (6 tests)
   - Successful deposits
   - Amount validations
   - Bank cap exceeded
   - Paused state

3. **Deposit Token Tests** (7 tests)
   - Direct USDC deposits
   - Deposits with swap (DAI → USDC)
   - Unsupported tokens
   - Validations

4. **Withdrawal Tests** (4 tests)
   - Successful withdrawals
   - Insufficient balance
   - Withdrawal limit exceeded

5. **Manager Functions Tests** (9 tests)
   - Add tokens
   - Change token status
   - Update bank cap
   - Update limits
   - Update slippage

6. **Admin Functions Tests** (4 tests)
   - Pause/unpause
   - Emergency withdrawals
   - Access control

7. **View Functions Tests** (6 tests)
   - Query balances
   - Token information
   - Oracle prices
   - Swap estimations

8. **Integration Tests** (2 tests)
   - Complete multi-user flows
   - Swap and withdrawal end-to-end

9. **Fuzz Tests** (3 tests)
   - Deposits with random amounts
   - Withdrawals with random amounts

10. **Receive/Fallback Tests** (2 tests)
    - Reject direct ETH
    - Reject invalid calls

### Run Specific Tests

```bash
# ETH deposit tests
forge test --match-contract KipuBankV3Test --match-test test_DepositETH

# Manager tests
forge test --match-test test_AddToken

# Fuzz tests
forge test --match-test testFuzz
```

### Coverage Targets

- **Current Coverage**: >50% (meets exam requirement)
- **Final Target**: >80%

```bash
# Check current coverage
forge coverage --report summary

# Example output:
| File                    | % Lines        | % Statements   | % Branches   | % Funcs      |
|-------------------------|----------------|----------------|--------------|--------------|
| src/KipuBankV3.sol      | 78.26%         | 80.43%         | 65.00%       | 85.71%       |
| Total                   | 78.26%         | 80.43%         | 65.00%       | 85.71%       |
```

---

## 🛡️ Threat Analysis

### 1. Identified Vulnerabilities

#### 🔴 CRITICAL

##### 1.1 Oracle Manipulation Attack
**Description**: Chainlink prices could be manipulated under extreme market conditions.

**Impact**: Users could receive less USDC than expected in swaps.

**Implemented Mitigation**:
- ✅ Staleness validation (< 1 hour)
- ✅ RoundId validation
- ✅ Minimum valid price ($1)

**Pending Mitigation**:
- ⚠️ Implement multiple oracles (Chainlink + Uniswap TWAP)
- ⚠️ Circuit breaker for price changes >10% in one hour

##### 1.2 Slippage Attack
**Description**: Sandwich attacks or front-running could exploit large swaps.

**Impact**: Loss of value in swaps (MEV attack).

**Implemented Mitigation**:
- ✅ Configurable slippage tolerance
- ✅ 5-minute deadline on swaps
- ✅ Minimum amountOut validation

**Pending Mitigation**:
- ⚠️ Integrate Flashbots/MEV protection
- ⚠️ Maximum limit per swap (avoid large transactions)

##### 1.3 Reentrancy via External Calls
**Description**: Calls to Uniswap Router could reenter the contract.

**Impact**: Fund drainage, double spending.

**Implemented Mitigation**:
- ✅ ReentrancyGuard on all public/external functions
- ✅ CEI (Checks-Effects-Interactions) pattern
- ✅ State updated before external calls

**Pending Mitigation**:
- ✅ **FULLY MITIGATED**

#### 🟡 HIGH

##### 2.1 Token Approval Front-running
**Description**: Users could see approvals and front-run deposits.

**Impact**: Temporary token loss (requires user failure).

**Implemented Mitigation**:
- ✅ SafeERC20 with forceApprove
- ✅ Approval just before swap

**Pending Mitigation**:
- ⚠️ Implement permit() (EIP-2612) for gasless approvals

##### 2.2 Admin Key Compromise
**Description**: If admin private key is compromised, attacker has full control.

**Impact**: Fund theft via emergencyWithdraw, pause contract.

**Implemented Mitigation**:
- ✅ Separate roles (Admin vs Manager)
- ✅ emergencyWithdraw only for Admin

**Pending Mitigation**:
- ⚠️ Implement Multisig (Gnosis Safe)
- ⚠️ Timelock for critical operations

##### 2.3 Bank Cap Bypass
**Description**: Race conditions could allow multiple deposits exceeding cap.

**Impact**: Bank cap exceeded, systemic risk.

**Implemented Mitigation**:
- ✅ Atomic validation in same transaction
- ✅ State updated before swap

**Pending Mitigation**:
- ✅ **FULLY MITIGATED** (validation is atomic)

#### 🟢 MEDIUM

##### 3.1 DoS via Block Gas Limit
**Description**: Large arrays (supportedTokens) could cause out-of-gas.

**Impact**: Read functions could fail.

**Implemented Mitigation**:
- ✅ Limit of 50 tokens (MAX_SUPPORTED_TOKENS)

**Pending Mitigation**:
- ⚠️ Implement pagination in getSupportedTokens()

##### 3.2 Precision Loss in Conversions
**Description**: Decimal conversions could lose precision.

**Impact**: Users lose small amounts (dust).

**Implemented Mitigation**:
- ✅ USD with 6 decimals (high precision)
- ✅ AmountTooSmall validation

**Pending Mitigation**:
- ⚠️ Implement function to claim dust

##### 3.3 Token with Fees on Transfer
**Description**: Some tokens (e.g. STA, PAXG) charge fees on transfers.

**Impact**: Balance received < expected balance → revert on swap.

**Implemented Mitigation**:
- ❌ Not implemented

**Pending Mitigation**:
- ⚠️ Blacklist of tokens with fees
- ⚠️ Or detect real balance post-transfer

#### 🔵 LOW

##### 4.1 Front-running of addToken
**Description**: Manager could add malicious token before review.

**Impact**: Malicious token on whitelist.

**Implemented Mitigation**:
- ✅ Only Manager role can add tokens
- ✅ Decimals validation

**Pending Mitigation**:
- ⚠️ 24h timelock for adding tokens
- ⚠️ Multisig for Manager operations

---

### 2. Risk Matrix

| Vulnerability | Probability | Impact | Severity | Status |
|---------------|-------------|--------|----------|--------|
| Oracle Manipulation | Low | Critical | 🔴 High | Partially mitigated |
| Slippage Attack | Medium | High | 🟡 Medium | Partially mitigated |
| Reentrancy | Low | Critical | ✅ Mitigated | Fully mitigated |
| Admin Key Compromise | Low | Critical | 🟡 High | Multisig recommended |
| Token Approval Front-run | Medium | Medium | 🟢 Low | Partially mitigated |
| Bank Cap Bypass | Very Low | High | ✅ Mitigated | Fully mitigated |
| DoS Gas Limit | Very Low | Low | 🟢 Low | Mitigated |
| Precision Loss | Medium | Low | 🟢 Low | Acceptable |
| Tokens with Fees | Medium | Medium | 🟡 Medium | Not mitigated |

---

### 3. Missing Steps for Production Maturity

#### Before Mainnet Launch

**Security:**
- [ ] Professional audit by recognized firm (OpenZeppelin, Trail of Bits, etc.)
- [ ] Bug bounty program ($50k+ on ImmuneFi)
- [ ] Implement Multisig (Gnosis Safe) for admin
- [ ] Timelock (24-48h) for critical operations
- [ ] Implement circuit breaker for prices
- [ ] Integrate Flashbots for MEV protection

**Testing:**
- [ ] Increase coverage to >90%
- [ ] Integration tests with Uniswap V2 on mainnet fork
- [ ] Stress tests (gas limits, large arrays)
- [ ] Advanced fuzzing with Echidna/Medusa
- [ ] Attack simulations (exploit tests)

**Monitoring:**
- [ ] Integrate Tenderly for monitoring
- [ ] Automatic alerts (Slack/Discord) for critical events
- [ ] Public metrics dashboard
- [ ] TVL (Total Value Locked) monitoring

**Operations:**
- [ ] Emergency procedure documentation
- [ ] Runbooks for different scenarios
- [ ] Incident response plan
- [ ] Versioning and upgrade system

#### Post-Launch (3-6 months)

**Optimizations:**
- [ ] Gas optimization (EIP-1167 clones?)
- [ ] Implement proxy pattern for upgrades
- [ ] Batch operations for multiple deposits
- [ ] Meta-transactions (EIP-2771) for gasless UX

**Features:**
- [ ] Support for Uniswap V3 (concentrated liquidity)
- [ ] Multi-chain deployment (Polygon, Arbitrum, etc.)
- [ ] Yield farming with deposited USDC (Aave, Compound)
- [ ] NFT receipts for deposits

---

### 4. Testing Methods Used

#### Strategic Testing

1. **Unit Tests** (65+ tests)
   - Test each function individually
   - Positive and negative cases
   - Edge cases

2. **Integration Tests**
   - Complete end-to-end flows
   - Multiple users interacting
   - Swaps + deposits + withdrawals

3. **Fuzz Tests**
   - Invariant properties
   - Random amounts
   - Multiple scenarios

4. **Mock Testing**
   - Isolation of external dependencies
   - Behavior control (exchange rate, prices)
   - Reproducibility

#### Coverage Targets

```
src/KipuBankV3.sol
├── Lines: >75%
├── Statements: >75%
├── Branches: >60%
└── Functions: >80%
```

#### Recommended Additional Tests

```bash
# Fork testing (mainnet)
forge test --fork-url $MAINNET_RPC_URL --match-test test_Integration

# Invariant testing
forge test --match-test invariant

# Gas profiling
forge test --gas-report

# Mutation testing (requires external tool)
vertigo run --sample-ratio 0.5
```

---

## 🎨 Design Decisions

### 1. Unified Balance in USDC

**Decision**: All deposits are converted to USDC, users only have one USDC balance.

**Alternatives Considered**:
- Multi-token balances (like V2)
- Balance in ETH as unit of account

**Reasons**:
- ✅ **Simplicity**: Frontend only displays one balance
- ✅ **Stability**: USDC is stablecoin (less volatility)
- ✅ **Gas Efficient**: One storage slot per user
- ✅ **UX**: Users don't need to understand which token they have

**Trade-offs**:
- ❌ Uniswap swap fees on each deposit
- ❌ Users can't recover original token
- ❌ Exposure to USDC risk (depeg, censorship)

---

### 2. Uniswap V2 Integration (not V3)

**Decision**: Use Uniswap V2 for swaps, not V3.

**Reasons**:
- ✅ **Simplicity**: V2 is simpler (no ticks, no ranges)
- ✅ **Documentation**: V2 is very well documented
- ✅ **Compatibility**: V2 is still widely used
- ✅ **Gas**: V2 can be cheaper for small swaps

**Trade-offs**:
- ❌ Worse execution price vs V3
- ❌ Less concentrated liquidity
- ❌ "Old" technology (2020)

**Future**: Migrate to Uniswap V3 in KipuBankV4 with better liquidity management.

---

### 3. Configurable Slippage (not fixed)

**Decision**: Manager can adjust slippage tolerance.

**Reasons**:
- ✅ **Flexibility**: Adjust according to market volatility
- ✅ **Optimization**: Lower slippage when market is calm
- ✅ **Risk Management**: Increase if swaps are failing

**Trade-offs**:
- ❌ Manager needs to actively monitor
- ❌ Additional complexity

**Recommended Configuration**:
- Normal market: 0.5-1% (50-100 bps)
- High volatility: 2-3% (200-300 bps)

---

### 4. Bank Cap in USD (not absolute USDC)

**Decision**: Bank cap is defined in USD (6 decimals), not in USDC amount.

**Reasons**:
- ✅ **Clarity**: $1M is more intuitive than 1000000 USDC
- ✅ **Consistency**: All internal values in USD
- ✅ **Future-proof**: If USDC depegs, cap is still correct in value

**Trade-offs**:
- ❌ Additional conversion in code

---

### 5. Withdrawal Only in USDC

**Decision**: Users can only withdraw USDC, not the original deposited token.

**Reasons**:
- ✅ **Simplicity**: No need for reverse swap
- ✅ **Gas Efficiency**: Less swap logic
- ✅ **Security**: Smaller attack surface

**Trade-offs**:
- ❌ Users can't "recover" their original token
- ❌ Less flexible than V2

**Mitigation**: In V4 we could add `withdrawAs(token)` function that does reverse swap.

---

### 6. No Yield Farming (Yet)

**Decision**: Deposited USDC doesn't automatically generate yield.

**Reasons**:
- ✅ **Simplicity**: V3 focuses on swap + storage
- ✅ **Security**: Fewer integrations = lower risk
- ✅ **Gas**: Fewer operations

**Future**: KipuBankV4 could:
- Deposit USDC in Aave/Compound
- Generate yield for depositors
- Share yield (80% users, 20% protocol)

---

### 7. Limit of 50 Tokens

**Decision**: Maximum 50 supported tokens (MAX_SUPPORTED_TOKENS).

**Reasons**:
- ✅ **DoS Prevention**: Avoid infinite arrays
- ✅ **Gas Limit**: getSupportedTokens() doesn't explode
- ✅ **Sufficient**: 50 tokens is a lot for a bank

**Trade-offs**:
- ❌ Arbitrary limit
- ❌ Need to remove old tokens to add new ones

**Alternative**: Implement pagination instead of limit.

---

### 8. Two Roles: Admin and Manager

**Decision**: Separate critical roles (Admin) from configuration (Manager).

**Reasons**:
- ✅ **Security**: Admin only for emergencies
- ✅ **Operations**: Manager can adjust parameters without critical risk
- ✅ **Governance**: Easy to delegate Manager to DAO

**Power Distribution**:

| Action | Admin | Manager |
|--------|-------|---------|
| pause/unpause | ✅ | ❌ |
| emergencyWithdraw | ✅ | ❌ |
| addToken | ❌ | ✅ |
| setBankCap | ❌ | ✅ |
| setSlippage | ❌ | ✅ |

**Future**: Admin → Multisig, Manager → DAO voting.

---

## 🔒 Audit and Security

### Pre-Audit Security Checklist

#### Access Controls
- [x] Roles implemented correctly (Admin, Manager)
- [x] onlyRole used in sensitive functions
- [x] Constructor assigns roles correctly
- [ ] Consider Multisig for Admin

#### Reentrancy
- [x] ReentrancyGuard on all state-changing functions
- [x] CEI pattern implemented
- [x] No external calls before updating state

#### Input Validation
- [x] nonZeroAmount on deposits/withdrawals
- [x] nonZeroAddress on constructor and functions
- [x] Decimals validation (1-18)
- [x] Slippage validation (<= 100%)
- [x] Bank cap and withdrawal limit validation

#### Oracles
- [x] Staleness check (< 1 hour)
- [x] roundId validation
- [x] Minimum valid price
- [ ] Consider multiple oracles (TWAP)

#### Token Handling
- [x] SafeERC20 for all transfers
- [x] forceApprove before swaps
- [ ] Handle tokens with fees on transfer
- [ ] Blacklist malicious tokens

#### Pausability
- [x] Pausable implemented
- [x] whenNotPaused on critical functions
- [x] Only Admin can pause
- [x] emergencyWithdraw available

#### Gas Optimization
- [x] State variable caching
- [x] Immutables for constant values
- [x] Custom errors (no strings)
- [x] Struct packing
- [ ] Consider batch operations

### Static Analysis Tools

```bash
# Slither (static analysis)
pip install slither-analyzer
slither src/KipuBankV3.sol

# Mythril (symbolic analysis)
pip install mythril
myth analyze src/KipuBankV3.sol

# Echidna (advanced fuzzing)
echidna-test . --contract KipuBankV3 --config echidna.yaml
```

### Recommended Audits

1. **Code4rena** - Competitive audit ($30-50k)
2. **OpenZeppelin** - Premium audit ($50-100k)
3. **Trail of Bits** - Security audit ($75-150k)

---

## 🗺️ Roadmap

### Q1 2025: MVP and Testing
- [x] Implement KipuBankV3 core
- [x] Complete test suite (>50% coverage)
- [x] Complete documentation
- [ ] Deploy on testnet (Sepolia)
- [ ] Basic frontend (React + Wagmi)

### Q2 2025: Audit and Optimization
- [ ] Professional audit
- [ ] Bug bounty program
- [ ] Gas optimizations
- [ ] Increase coverage to >90%
- [ ] Deploy on mainnet (beta)

### Q3 2025: Advanced Features
- [ ] Integrate Uniswap V3
- [ ] Yield farming (Aave/Compound)
- [ ] Multi-chain (Polygon, Arbitrum)
- [ ] DAO governance

### Q4 2025: Scalability
- [ ] L2 optimization
- [ ] Batch operations
- [ ] Meta-transactions
- [ ] NFT receipts

---

## 📞 Contact and Support

- **Author**: Hernan Herrera
- **Organization**: White Paper
- **Email**: hernanherrera@whitepaper.com
- **Support**: support@whitepaper.com
- **Security**: security@whitepaper.com

---

## 📄 License

This project is under the MIT license. See [LICENSE](LICENSE) for more details.

---

## 🙏 Acknowledgments

- **White Paper** - Development organization
- **Hernan Herrera** - Lead Developer
- **Uniswap** - For the swap protocol
- **Chainlink** - For price oracles
- **OpenZeppelin** - For security libraries
- **Foundry** - For development tools

---

## 📚 References

1. [Uniswap V2 Documentation](https://docs.uniswap.org/contracts/v2/overview)
2. [Chainlink Price Feeds](https://docs.chain.link/data-feeds)
3. [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
4. [Foundry Book](https://book.getfoundry.sh/)
5. [Ethereum Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)

---

**⚠️ DISCLAIMER**: This contract is for educational purposes. It has not been professionally audited. Do not use in production with real funds without a complete audit.
