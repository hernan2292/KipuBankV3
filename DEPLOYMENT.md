# Deployment Guide - KipuBankV3

This guide outlines the step-by-step process for deploying **KipuBankV3** on the Sepolia testnet and mainnet.

## 📋 Prerequisites

### 1. Install Foundry

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify installation
forge --version
cast --version
```

### 2. Obtain API Keys

#### Alchemy/Infura (RPC)
1. Create an account on [Alchemy](https://www.alchemy.com/) or [Infura](https://infura.io/)
2. Create an app for Sepolia and Mainnet
3. Copy the API keys

#### Etherscan (Verification)
1. Create an account on [Etherscan](https://etherscan.io/)
2. Go to **API Keys** → **Create new API key**
3. Copy the API key

### 3. Acquire ETH for Gas

#### Sepolia Testnet
- Faucet 1: https://sepoliafaucet.com/
- Faucet 2: https://www.alchemy.com/faucets/ethereum-sepolia
- Faucet 3: https://sepolia-faucet.pk910.de/

#### Mainnet
- Buy ETH on an exchange (Coinbase, Binance, etc.)
- Transfer it to your deployment wallet

---

## 🔧 Configuration

### 1. Clone and Set Up Project

```bash
# Clone repository
git clone https://github.com/your-username/KipuBankV3.git
cd KipuBankV3

# Install dependencies
make install
# Or manually:
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink --no-commit
forge install foundry-rs/forge-std --no-commit

# Compile contracts
make build
```

### 2. Set Environment Variables

```bash
# Copy example file
cp .env.example .env

# Edit .env
nano .env
```

Complete the `.env` file:

```bash
# RPC URLs (replace YOUR_API_KEY)
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY

# Private Key (⚠️ NEVER share or commit!)
PRIVATE_KEY=0x1234567890abcdef...

# Etherscan API Key
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY

# Contract addresses (already configured)
UNISWAP_V2_ROUTER_SEPOLIA=0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008
USDC_SEPOLIA=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
ETH_USD_PRICE_FEED_SEPOLIA=0x694AA1769357215DE4FAC081bf1f309aDC325306
```

**⚠️ SECURITY**:
- Never commit the `.env` file to Git
- Use a separate wallet for deployment (do not use your personal wallet)
- For production, use a hardware wallet or Multisig

---

## 🧪 Testing Before Deployment

### 1. Local Tests

```bash
# Run all tests
make test

# Verbose tests
make test-v

# Specific tests
make test-DepositETH

# Gas report
make gas-report

# Coverage
make coverage
```

**Target**: All tests must pass ✅

### 2. Fork Tests (Mainnet)

```bash
# Run tests on a mainnet fork
forge test --fork-url $MAINNET_RPC_URL

# Specific fork test
forge test --fork-url $MAINNET_RPC_URL --match-test test_Integration
```

This runs tests against a local fork of mainnet, using real Uniswap and Chainlink data.

---

## 🚀 Deployment on Sepolia (Testnet)

### 1. Verify Balance

```bash
# Check ETH balance on Sepolia
cast balance $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL

# Convert to readable ETH
cast balance $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL | cast --to-unit ether
```

You need at least **0.05 ETH** on Sepolia for deployment + interactions.

### 2. Dry Run (Simulation)

```bash
# Simulate deployment without broadcast
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $SEPOLIA_RPC_URL
```

This shows gas estimates, contract addresses, and any errors.

### 3. Real Deployment

```bash
# Option 1: Using Makefile
make deploy-sepolia

# Option 2: Full command
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

**Expected output**:
```
Deploying to Sepolia...
KipuBankV3 deployed to: 0x1234567890abcdef...
Bank Cap: 1000000000000
Withdrawal Limit: 100000000000
Slippage Tolerance: 100 bps

Starting verification...
Contract verified: https://sepolia.etherscan.io/address/0x123...
```

### 4. Save Contract Address

```bash
# Save in file for reference
echo "KIPUBANK_V3_SEPOLIA=0xYourContractAddress" >> .env
```

### 5. Manual Verification (if auto-verification fails)

```bash
# Get constructor args in ABI-encoded format
cast abi-encode "constructor(address,address,address,uint256,uint256,uint256)" \
  0x694AA1769357215DE4FAC081bf1f309aDC325306 \  # ethUsdPriceFeed
  0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008 \  # uniswapRouter
  0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 \  # usdc
  1000000000000 \  # bankCapUSD (1M USDC)
  100000000000 \   # withdrawalLimitUSD (100K USDC)
  100              # slippageTolerance (1%)

# Manual verify
forge verify-contract \
  --chain-id 11155111 \
  --num-of-optimizations 200 \
  --compiler-version 0.8.30 \
  --constructor-args <ABI_ENCODED_RESULT> \
  <CONTRACT_ADDRESS> \
  src/KipuBankV3.sol:KipuBankV3 \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

---

## 🧪 Testing After Deployment (Sepolia)

### 1. Verify Initial State

```bash
# Get bank cap
cast call <CONTRACT_ADDRESS> "bankCapUSD()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# Get supported tokens
cast call <CONTRACT_ADDRESS> "getSupportedTokens()(address[])" --rpc-url $SEPOLIA_RPC_URL

# Verify roles
cast call <CONTRACT_ADDRESS> "hasRole(bytes32,address)(bool)" \
  $(cast --format-bytes32-string "MANAGER_ROLE") \
  $YOUR_ADDRESS \
  --rpc-url $SEPOLIA_RPC_URL
```

### 2. ETH Deposit Test

```bash
# Deposit 0.1 ETH
cast send <CONTRACT_ADDRESS> "depositETH()" \
  --value 0.1ether \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL

# Check balance
cast call <CONTRACT_ADDRESS> "getBalance(address)(uint256)" \
  $YOUR_ADDRESS \
  --rpc-url $SEPOLIA_RPC_URL
```

### 3. USDC Deposit Test

```bash
# USDC Sepolia address
USDC_SEPOLIA=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238

# Approve KipuBankV3 to spend USDC
cast send $USDC_SEPOLIA "approve(address,uint256)" \
  <CONTRACT_ADDRESS> \
  1000000000 \  # 1000 USDC (6 decimals)
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL

# Deposit 1000 USDC
cast send <CONTRACT_ADDRESS> "depositToken(address,uint256)" \
  $USDC_SEPOLIA \
  1000000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

### 4. Withdrawal Test

```bash
# Withdraw 100 USDC
cast send <CONTRACT_ADDRESS> "withdraw(uint256)" \
  100000000 \  # 100 USDC
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

### 5. Manager Functions Test

```bash
# Add a new token (e.g., DAI)
DAI_SEPOLIA=0xYourDAIAddress

cast send <CONTRACT_ADDRESS> "addToken(address)" \
  $DAI_SEPOLIA \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL

# Increase bank cap
cast send <CONTRACT_ADDRESS> "grantRole(bytes32,address)" \
  $(cast keccak "DEFAULT_ADMIN_ROLE") \
  $MULTISIG_ADDRESS \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

---

## 🌐 Deployment on Mainnet

### ⚠️ PRE-FLIGHT CHECKLIST

**BEFORE deploying to mainnet, ensure**:

- [ ] ✅ All tests pass locally
- [ ] ✅ Coverage >50%
- [ ] Full code review
- [ ] Security audit completed (RECOMMENDED for mainnet)
- [ ] Gas usage optimized
- [ ] Documentation fully updated

### 1. Verify Mainnet Parameters

```bash
# Verify mainnet addresses
echo "ETH/USD Feed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"
echo "Uniswap Router: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
echo "USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

# Check current gas price
cast gas-price --rpc-url $MAINNET_RPC_URL

# Convert to Gwei
cast --to-unit gwei $(cast gas-price --rpc-url $MAINNET_RPC_URL)
```

### 2. Dry Run on Mainnet Fork

```bash
# Simulate deployment on mainnet fork
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --fork-url $MAINNET_RPC_URL
```

### 3. Real Deployment (with Confirmation)

```bash
# ⚠️ FINAL WARNING ⚠️
echo "ARE YOU SURE you want to deploy to MAINNET?"
echo "This will use REAL ETH and the contract will be IMMUTABLE."
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Deploy
make deploy-mainnet

# Or full command
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --slow  # Wait between transactions for confirmation
```

### 4. Immediate Post-Deployment

```bash
# 1. Record address
echo "KIPUBANK_V3_MAINNET=0xYourMainnetAddress" >> .env

# 2. Transfer ownership to Multisig (CRITICAL)
MULTISIG_ADDRESS=0xYourGnosisSafeAddress

cast send <CONTRACT_ADDRESS> "grantRole(bytes32,address)" \
  $(cast keccak "DEFAULT_ADMIN_ROLE") \
  $MULTISIG_ADDRESS \
  --private-key $PRIVATE_KEY \
  --rpc-url $MAINNET_RPC_URL

# 3. Renounce your admin role (after verifying multisig)
cast send <CONTRACT_ADDRESS> "renounceRole(bytes32,address)" \
  $(cast keccak "DEFAULT_ADMIN_ROLE") \
  $YOUR_ADDRESS \
  --private-key $PRIVATE_KEY \
  --rpc-url $MAINNET_RPC_URL
```

### 5. Configure Monitoring

```bash
# Tenderly alerts
# 1. Go to https://dashboard.tenderly.co/
# 2. Add Contract → paste mainnet address
# 3. Configure Alerts:
#    - Deposit > $100k
#    - Withdrawal > $50k
#    - pause() called
#    - emergencyWithdraw() called
#    - Bank cap > 90% filled

# OpenZeppelin Defender
# 1. Go to https://defender.openzeppelin.com/
# 2. Import Contract
# 3. Set up Sentinels for critical events
```

---

## 📊 Verification & Monitoring

### Etherscan

1. Go to https://etherscan.io/address/<CONTRACT_ADDRESS>
2. Verify:
   - Contract ✅ (green checkmark)
   - Read Contract (view functions)
   - Write Contract (state-changing functions)
   - Events (deposits, withdrawals, swaps)

### Tenderly

```bash
# Add contract to Tenderly
tenderly export init
tenderly export <CONTRACT_ADDRESS>
```

### DefiLlama TVL Tracking

- Submit a PR to https://github.com/DefiLlama/DefiLlama-Adapters with an adapter for KipuBankV3.

---

## 🔧 Troubleshooting

### Error: "Insufficient funds"

```bash
# Check balance
cast balance $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL

# Get ETH from faucet
# Sepolia: https://sepoliafaucet.com/
```

### Error: "Verification failed"

```bash
# Manual verification
forge verify-contract \
  --chain-id <CHAIN_ID> \
  --compiler-version 0.8.30 \
  --num-of-optimizations 200 \
  <CONTRACT_ADDRESS> \
  src/KipuBankV3.sol:KipuBankV3

# Or use the Etherscan UI
# 1. Go to Etherscan
# 2. Contract → Verify & Publish
# 3. Paste KipuBankV3.sol source code
# 4. Select optimization (200 runs)
```

### Error: "Nonce too low"

```bash
# Get current nonce
cast nonce $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL

# If there's a mismatch, wait or use `--nonce` flag
```

### Gas too high

```bash
# Wait for lower gas price
while [ $(cast --to-unit gwei $(cast gas-price --rpc-url mainnet)) -gt 30 ]; do
  echo "Gas price too high, waiting..."
  sleep 300  # Wait 5 minutes
done
echo "Gas price acceptable, deploying..."
```

---

## 📝 Final Checklist

| Item | Status |
|------|--------|
| **All tests pass** | ✅ |
| **Coverage > 50%** | ✅ |
| **Code review completed** | ✅ |
| **Security audit done** | ✅ |
| **Gas usage optimized** | ✅ |
| **Documentation complete** | ✅ |

### Deployment

| Step | Done |
|------|------|
| `.env` configured | ✅ |
| Sufficient balance | ✅ |
| Dry run succeeded | ✅ |
| Contract deployed | ✅ |
| Verified on Etherscan | ✅ |

### Post-Deployment

| Task | Done |
|------|------|
| Tests pass on Sepolia | ✅ |
| Ownership moved to Multisig | ✅ |
| Monitoring set up | ✅ |
| Alerts configured | ✅ |
| Addresses recorded in docs | ✅ |
| Public announcement made | ✅ |

---

## 🆘 Support

If you run into issues:

1. **Documentation**: Check the [README.md](README.md)
2. **Support Email**: support@whitepaper.com
3. **Security Email**: security@whitepaper.com
4. **Developer**: Hernan Herrera (hernanherrera@whitepaper.com)
5. **Organization**: White Paper

---

## 📚 References

- [Foundry Book](https://book.getfoundry.sh/)
- [Sepolia Faucets](https://faucetlink.to/sepolia)
- [Etherscan API Docs](https://docs.etherscan.io/)
- [Tenderly Docs](https://docs.tenderly.co/)
- [OpenZeppelin Defender](https://docs.openzeppelin.com/defender/)

---

**Good luck with your deployment!** 🚀
