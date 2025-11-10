# 🚀 Deployment Instructions - Sepolia

**Date**: 2025-11-09
**Network**: Sepolia Testnet
**Status**: Ready to Deploy

---

## ⚡ Quick Deployment (Option 1 - Recommended)

Open your WSL terminal and run:

```bash
cd /mnt/c/Users/herna/OneDrive/proyects/KipuBankV3

# Make the script executable
chmod +x deploy-sepolia.sh

# Run deployment
./deploy-sepolia.sh
```

The script automatically:
1. ✅ Compiles the contract
2. ✅ Runs all 49 tests
3. ✅ Deploys to Sepolia
4. ✅ Verifies on Etherscan

---

## 🔧 Manual Deployment (Option 2)

If you prefer to execute step by step:

### Step 1: Open WSL terminal
```bash
cd /mnt/c/Users/herna/OneDrive/proyects/KipuBankV3
```

### Step 2: Load environment variables
```bash
source .env
```

### Step 3: Compile
```bash
forge build
```

### Step 4: Run tests (optional but recommended)
```bash
forge test --gas-report
```

You should see:
```
Ran 49 tests: 49 passed, 0 failed
```

### Step 5: Deploy + Verify
```bash
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3     --rpc-url $SEPOLIA_RPC_URL     --private-key $PRIVATE_KEY     --broadcast     --verify     --etherscan-api-key $ETHERSCAN_API_KEY     -vvv
```

---

## 📋 Expected Output

You’ll see something like:

```
[⠊] Compiling...
No files changed, compilation skipped

Script ran successfully.

== Logs ==
Deploying to Sepolia...
KipuBankV3 deployed to: 0x1234567890abcdef1234567890abcdef12345678
Bank Cap: 1000000000000
Withdrawal Limit: 100000000000
Slippage Tolerance: 100 bps

## Setting up 1 EVM.

==========================

Chain 11155111

Estimated gas price: 2.500000007 gwei

Estimated total gas used for script: 3234567

Estimated amount required: 0.008086417522640969 ETH

==========================

##### sepolia
✅  [Success]Hash: 0xabcd...1234
Contract Address: 0x1234567890abcdef1234567890abcdef12345678
Block: 12345678
Paid: 0.00789 ETH (3156789 gas * 2.5 gwei)

##### sepolia
✅ Sequence #1 on sepolia | Total Paid: 0.00789 ETH (3156789 gas * avg 2.5 gwei)

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Starting contract verification...
Submitting verification for [KipuBankV3] at 0x1234567890abcdef1234567890abcdef12345678
Submitted contract for verification:
        Response: `OK`
        GUID: `xyz123abc456`
        URL: https://sepolia.etherscan.io/address/0x1234567890abcdef1234567890abcdef12345678

Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
```

---

## 📍 Copy Deployment Information

After a successful deployment, copy:

### 1. Contract Address
```
Contract Address: 0x1234567890abcdef1234567890abcdef12345678
```

### 2. Etherscan URL
```
https://sepolia.etherscan.io/address/0x1234567890abcdef1234567890abcdef12345678#code
```

### 3. Transaction Hash
```
Hash: 0xabcd...1234
```

---

## ✅ Verify Deployment

### 1. On Etherscan

Visit the URL and check:
- ✅ Verified code (green checkmark)
- ✅ Contract tab shows Solidity code
- ✅ Read Contract displays view functions
- ✅ Write Contract allows interaction

### 2. Using Cast

```bash
# View bank cap
cast call 0x<CONTRACT_ADDRESS> "bankCapUSD()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# View withdrawal limit
cast call 0x<CONTRACT_ADDRESS> "withdrawalLimitUSD()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# View USDC address
cast call 0x<CONTRACT_ADDRESS> "usdc()(address)" --rpc-url $SEPOLIA_RPC_URL
```

---

## 🧪 Test the Contract

### Deposit ETH

```bash
# Get your address
cast wallet address --private-key $PRIVATE_KEY

# Deposit 0.1 ETH
cast send 0x<CONTRACT_ADDRESS>     "depositETH()"     --value 0.1ether     --private-key $PRIVATE_KEY     --rpc-url $SEPOLIA_RPC_URL

# View your balance
cast call 0x<CONTRACT_ADDRESS>     "getBalance(address)(uint256)"     <YOUR_ADDRESS>     --rpc-url $SEPOLIA_RPC_URL
```

### Deposit USDC (Sepolia)

First, you need Sepolia USDC:
- Faucet: https://faucet.circle.com/

```bash
# Approve USDC
cast send 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238     "approve(address,uint256)"     0x<CONTRACT_ADDRESS>     1000000000     --private-key $PRIVATE_KEY     --rpc-url $SEPOLIA_RPC_URL

# Deposit 1000 USDC (6 decimals)
cast send 0x<CONTRACT_ADDRESS>     "depositToken(address,uint256)"     0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238     1000000000     --private-key $PRIVATE_KEY     --rpc-url $SEPOLIA_RPC_URL
```

### Withdraw

```bash
# Withdraw 500 USDC
cast send 0x<CONTRACT_ADDRESS>     "withdraw(uint256)"     500000000     --private-key $PRIVATE_KEY     --rpc-url $SEPOLIA_RPC_URL
```

---

## 📊 Configuration Info

Your deployment will use these initial values:

```
Bank Cap:          1,000,000 USDC ($1M)
Withdrawal Limit:    100,000 USDC ($100K)
Slippage:                 1% (100 bps)

ETH/USD Oracle:    0x694AA1769357215DE4FAC081bf1f309aDC325306
Uniswap Router:    0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008
USDC:              0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
```

---

## ❌ Troubleshooting

### Error: "insufficient funds"

Your wallet needs Sepolia ETH:
- Faucet 1: https://sepoliafaucet.com/
- Faucet 2: https://www.alchemy.com/faucets/ethereum-sepolia
- Faucet 3: https://cloud.google.com/application/web3/faucet/ethereum/sepolia

You need ~0.01 ETH for deployment.

### Error: "Invalid API key"

Check your `ETHERSCAN_API_KEY` in `.env`:
1. Go to https://etherscan.io/myapikey
2. Create an API key if you don't have one
3. Update `.env`

### Error: "nonce too low"

```bash
# Reset nonce
cast nonce <YOUR_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

### Verification Failed

If the contract deployed but verification failed:

```bash
# Verify manually
forge verify-contract     0x<CONTRACT_ADDRESS>     src/KipuBankV3.sol:KipuBankV3     --chain sepolia     --etherscan-api-key $ETHERSCAN_API_KEY     --constructor-args $(cast abi-encode "constructor(address,address,address,uint256,uint256,uint256)"         0x694AA1769357215DE4FAC081bf1f309aDC325306         0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008         0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238         1000000000000         100000000000         100)
```

---

## 🎯 Next Steps After Deployment

1. ✅ Copy the contract address
2. ✅ Copy the Etherscan URL
3. ✅ Test depositETH() with 0.01 ETH
4. ✅ Check balance with getBalance()
5. ✅ Test withdraw()
6. ✅ Document the URL in your deliverable

---

## 📞 Support

If you have issues:
1. Check error logs with `-vvvv`
2. Make sure you have Sepolia ETH
3. Confirm environment variables are correct
4. Check [DEPLOYMENT.md](DEPLOYMENT.md) for more details

---

## 🔗 Useful Links

- **Sepolia Etherscan**: https://sepolia.etherscan.io/
- **Sepolia Faucet**: https://sepoliafaucet.com/
- **USDC Faucet**: https://faucet.circle.com/
- **Alchemy Dashboard**: https://dashboard.alchemy.com/
- **Foundry Book**: https://book.getfoundry.sh/

---

**Ready to Deploy!** 🚀

Run: `./deploy-sepolia.sh`
