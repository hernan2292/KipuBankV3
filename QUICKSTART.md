# Quick Start Guide - KipuBankV3

This guide will take you from zero to having KipuBankV3 running in 5 minutes.

## ⚡ Quick Setup (5 minutes)

### 1. Prerequisites

```bash
# Verify you have git
git --version

# Install Foundry (if you don't have it)
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Clone and Install

```bash
# Clone
git clone https://github.com/your-username/KipuBankV3.git
cd KipuBankV3

# Install dependencies
make install

# Compile
make build
```

### 3. Run Tests

```bash
# Run all tests
make test

# View detailed output
make test-v
```

**✅ If all tests pass, you're ready!**

---

## 🎯 Basic Usage

### Option 1: Local Deploy (Anvil)

```bash
# Terminal 1: Start local node
anvil

# Terminal 2: Deploy
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

### Option 2: Testnet Deploy (Sepolia)

```bash
# 1. Configure .env
cp .env.example .env
nano .env  # Add your API keys

# 2. Get testnet ETH
# https://sepoliafaucet.com/

# 3. Deploy
make deploy-sepolia
```

---

## 💡 Common Examples

### Deposit ETH

```bash
# Deposit 0.1 ETH
cast send <CONTRACT_ADDRESS> "depositETH()" \
  --value 0.1ether \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

### Deposit USDC

```bash
# 1. Approve USDC
cast send <USDC_ADDRESS> "approve(address,uint256)" \
  <CONTRACT_ADDRESS> \
  1000000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL

# 2. Deposit 1000 USDC
cast send <CONTRACT_ADDRESS> "depositToken(address,uint256)" \
  <USDC_ADDRESS> \
  1000000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

### Check Balance

```bash
cast call <CONTRACT_ADDRESS> "getBalance(address)(uint256)" \
  $YOUR_ADDRESS \
  --rpc-url $RPC_URL
```

### Withdraw USDC

```bash
cast send <CONTRACT_ADDRESS> "withdraw(uint256)" \
  100000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

---

## 🔍 Explore the Code

### Project Structure

```
KipuBankV3/
├── src/
│   ├── KipuBankV3.sol           ← Main contract
│   ├── interfaces/
│   │   ├── IKipuBankV3.sol      ← Main interface
│   │   └── IUniswapV2Router02.sol
│   └── mocks/                   ← Mocks for testing
├── test/
│   └── KipuBankV3.t.sol         ← Test suite (65+ tests)
├── script/
│   └── DeployKipuBankV3.s.sol   ← Deployment script
├── foundry.toml                  ← Foundry configuration
├── README.md                     ← Complete documentation
├── DEPLOYMENT.md                 ← Deployment guide
└── SECURITY.md                   ← Security policy
```

### Main Functions

```solidity
// Deposits
function depositETH() external payable
function depositToken(address token, uint256 amount) external

// Withdrawals
function withdraw(uint256 amount) external

// Manager
function addToken(address token) external
function setBankCap(uint256 newCapUSD) external
function setSlippageTolerance(uint256 newSlippageBps) external

// Admin
function pause() external
function unpause() external
function emergencyWithdraw(address token, uint256 amount, address recipient) external

// View
function getBalance(address user) external view returns (uint256)
function getTotalBankValueUSD() external view returns (uint256)
function getExpectedUSDC(address tokenIn, uint256 amountIn) external view returns (uint256)
```

---

## 🧪 Advanced Testing

### Specific Tests

```bash
# Only deposit tests
make test-DepositETH

# Only manager tests
forge test --match-test test_AddToken

# Fuzz tests
forge test --match-test testFuzz
```

### Coverage

```bash
# View coverage
make coverage

# Generate HTML report
forge coverage --report lcov
genhtml lcov.info --output-directory coverage
open coverage/index.html
```

### Fork Testing

```bash
# Test against real mainnet
forge test --fork-url $MAINNET_RPC_URL --match-test test_Integration
```

---

## 📚 Next Steps

1. **Read Complete Documentation**: [README.md](README.md)
2. **Understand Architecture**: See flow diagram in README
3. **Review Tests**: [test/KipuBankV3.t.sol](test/KipuBankV3.t.sol)
4. **Deploy on Testnet**: [DEPLOYMENT.md](DEPLOYMENT.md)
5. **Contribute**: [CONTRIBUTING.md](CONTRIBUTING.md)

---

## ❓ FAQ

### Why use Uniswap V2 instead of V3?
V2 is simpler for this use case. V3 will be considered in future versions.

### Can users recover the original token?
No, all deposits are converted to USDC. Withdrawals are USDC only.

### What happens if USDC loses its peg?
The contract has a `pause()` function for emergencies. Multiple stablecoins will be supported in the future.

### How much gas does a deposit with swap cost?
Approximately 150k-250k gas (depends on swap route). Direct ETH is cheaper than ERC20 tokens.

### Is it safe for production?
**NO** without professional audit. This is an educational project. See [SECURITY.md](SECURITY.md).

---

## 🆘 Help

- **Documentation**: [README.md](README.md)
- **Support**: support@whitepaper.com
- **Security**: security@whitepaper.com
- **Developer**: Hernan Herrera (hernanherrera@whitepaper.com)
- **Organization**: White Paper

---

## 🎉 Ready!

You now have everything to start using and developing with KipuBankV3.

**Happy coding!** 🚀
