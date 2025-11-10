# KipuBankV3 - Project Structure

**Author**: Hernan Herrera
**Organization**: White Paper
**Date**: 2025-11-09

## 📁 Complete File Structure

```
KipuBankV3/
│
├── .github/
│   └── workflows/
│       └── ci.yml                      # GitHub Actions CI/CD pipeline
│
├── src/                                # Solidity Contracts
│   ├── KipuBankV3.sol                 # 🏦 Main contract (800+ lines)
│   │                                   # - ETH/ERC20 deposits
│   │                                   # - Automatic swap via Uniswap V2
│   │                                   # - Bank cap management
│   │                                   # - Admin/Manager roles
│   │
│   ├── interfaces/                     # Interfaces
│   │   ├── IKipuBankV3.sol            # Main bank interface
│   │   │                               # - Public function definition
│   │   │                               # - Custom events and errors
│   │   │                               # - Data structures (TokenInfo)
│   │   │
│   │   └── IUniswapV2Router02.sol     # Uniswap V2 Router interface
│   │                                   # - swapExactTokensForTokens
│   │                                   # - swapExactETHForTokens
│   │                                   # - getAmountsOut
│   │
│   └── mocks/                          # Mock contracts for testing
│       ├── MockERC20.sol               # Test ERC20 token
│       ├── MockV3Aggregator.sol        # Mock Chainlink oracle
│       └── MockUniswapV2Router.sol     # Mock Uniswap V2 router
│
├── test/                               # Tests with Foundry
│   └── KipuBankV3.t.sol               # 🧪 Complete test suite (65+ tests)
│                                       # - Unit tests
│                                       # - Integration tests
│                                       # - Fuzz tests
│                                       # - Coverage: ~78%
│
├── script/                             # Deployment scripts
│   └── DeployKipuBankV3.s.sol         # 🚀 Deployment script
│                                       # - Sepolia configuration
│                                       # - Mainnet configuration
│                                       # - Auto-verification
│
├── lib/                                # External dependencies (git submodules)
│   ├── openzeppelin-contracts/        # OpenZeppelin (v5.0.0)
│   ├── chainlink/                      # Chainlink contracts
│   └── forge-std/                      # Forge standard library
│
├── .vscode/                            # VSCode configuration
│
├── .github/                            # GitHub configuration
│   └── workflows/                      # CI/CD pipelines
│
├── cache/                              # Compilation cache (gitignored)
├── out/                                # Compiled artifacts (gitignored)
├── broadcast/                          # Deployment logs (gitignored)
│
├── 📄 README.md                        # 📚 Main documentation (1,400+ lines)
│                                       # - Executive summary
│                                       # - System architecture
│                                       # - Installation guide
│                                       # - Contract interaction
│                                       # - Threat analysis
│                                       # - Design decisions
│
├── 📄 DEPLOYMENT.md                    # 🚀 Deployment guide (700+ lines)
│                                       # - Step-by-step setup
│                                       # - Sepolia/Mainnet deployment
│                                       # - Post-deployment testing
│                                       # - Troubleshooting
│
├── 📄 QUICKSTART.md                    # ⚡ Quick start (300+ lines)
│                                       # - 5-minute setup
│                                       # - Practical examples
│                                       # - FAQ
│
├── 📄 SECURITY.md                      # 🔒 Security policy (200+ lines)
│                                       # - Vulnerability reporting
│                                       # - Bug bounty program
│                                       # - Known issues
│
├── 📄 IMPLEMENTATION_SUMMARY.md        # ✅ Implementation summary
│                                       # - Objectives compliance
│                                       # - Technical decisions
│                                       # - Project metrics
│
├── 📄 PROJECT_STRUCTURE.md             # 📁 This file
│                                       # - Project structure
│                                       # - File description
│
├── 📄 foundry.toml                     # ⚙️ Foundry configuration
│                                       # - Compiler settings
│                                       # - RPC endpoints
│                                       # - Optimizer config
│
├── 📄 remappings.txt                   # 🔗 Import remappings
│                                       # - @openzeppelin → lib/openzeppelin-contracts
│                                       # - @chainlink → lib/chainlink
│
├── 📄 Makefile                         # 🛠️ Useful commands
│                                       # - make install, build, test
│                                       # - make deploy-sepolia, deploy-mainnet
│                                       # - make coverage, gas-report
│
├── 📄 package.json                     # 📦 Project metadata
│                                       # - npm scripts
│                                       # - Development dependencies
│
├── 📄 .env.example                     # 🔐 Environment variables template
│                                       # - RPC URLs
│                                       # - Private key (placeholder)
│                                       # - Etherscan API key
│
├── 📄 .gitignore                       # 🚫 Files ignored by Git
│                                       # - cache/, out/, broadcast/
│                                       # - .env (CRITICAL)
│                                       # - node_modules/
│
├── 📄 .gitattributes                   # 📝 Git attributes
│                                       # - EOL normalization
│                                       # - Binary files handling
│
└── 📄 LICENSE                          # ⚖️ MIT License
```

---

## 🎯 Key Files by Category

### 🏗️ Smart Contracts (Production)

| File | Lines | Description | Purpose |
|---------|--------|-------------|-----------|
| `src/KipuBankV3.sol` | 800+ | Main contract | Core banking logic, swaps, bank cap |
| `src/interfaces/IKipuBankV3.sol` | 200+ | Main interface | Public function definition |
| `src/interfaces/IUniswapV2Router02.sol` | 80+ | Uniswap interface | Integration with Uniswap V2 |

### 🧪 Testing

| File | Lines | Tests | Coverage |
|---------|--------|-------|-----------|
| `test/KipuBankV3.t.sol` | 600+ | 65+ | ~78% |
| `src/mocks/MockERC20.sol` | 30+ | - | Mock token |
| `src/mocks/MockV3Aggregator.sol` | 60+ | - | Mock oracle |
| `src/mocks/MockUniswapV2Router.sol` | 130+ | - | Mock router |

### 📚 Documentation

| File | Lines | Words | Audience |
|---------|--------|----------|-----------|
| `README.md` | 1,400+ | 12,000+ | Developers, Auditors, Users |
| `DEPLOYMENT.md` | 700+ | 6,000+ | DevOps, Deployers |
| `QUICKSTART.md` | 300+ | 2,500+ | New Developers |
| `SECURITY.md` | 200+ | 1,800+ | Security Researchers |
| `IMPLEMENTATION_SUMMARY.md` | 500+ | 4,000+ | Evaluators, Technical Review |

### 🛠️ Configuration and Scripts

| File | Purpose |
|---------|-----------|
| `foundry.toml` | Foundry configuration (compiler, optimizer, RPC) |
| `remappings.txt` | Library import remappings |
| `Makefile` | Useful commands (test, deploy, coverage) |
| `package.json` | Metadata and npm scripts |
| `.env.example` | Environment variables template |
| `script/DeployKipuBankV3.s.sol` | Automated deployment script |

### 🔒 Security and CI/CD

| File | Purpose |
|---------|-----------|
| `.github/workflows/ci.yml` | CI/CD pipeline (build, test, lint) |
| `SECURITY.md` | Vulnerability disclosure policy |
| `.gitignore` | Protection of sensitive files (.env) |

---

## 📊 Project Statistics

### Solidity Code

```
Main Contracts:          800+ lines
Interfaces:              280+ lines
Mocks:                   220+ lines
Tests:                   600+ lines
Scripts:                  70+ lines
─────────────────────────────────────
TOTAL SOLIDITY:         ~2000 lines
```

### Documentation

```
README.md:              1,400+ lines
DEPLOYMENT.md:            700+ lines
QUICKSTART.md:            300+ lines
SECURITY.md:              200+ lines
IMPLEMENTATION_SUMMARY:   500+ lines
PROJECT_STRUCTURE:        200+ lines
─────────────────────────────────────
TOTAL DOCS:             ~3300 lines
```

### Tests

```
Total Tests:               65+
Coverage:                  78%
Test Code Lines:          600+
Test Categories:           10
```

---

## 🔍 Quick Navigation Map

### For Auditors

1. **Start**: [README.md](README.md) - "System Architecture" Section
2. **Code**: [src/KipuBankV3.sol](src/KipuBankV3.sol) - Main contract with NatSpec
3. **Security**: [README.md](README.md) - "Threat Analysis" Section
4. **Tests**: [test/KipuBankV3.t.sol](test/KipuBankV3.t.sol) - Complete suite

### For Frontend Developers

1. **Start**: [QUICKSTART.md](QUICKSTART.md) - 5-minute setup
2. **API**: [src/interfaces/IKipuBankV3.sol](src/interfaces/IKipuBankV3.sol) - Public functions
3. **Examples**: [README.md](README.md) - "Contract Interaction" Section
4. **Addresses**: Add after deployment

### For DevOps

1. **Start**: [DEPLOYMENT.md](DEPLOYMENT.md) - Complete guide
2. **Config**: [foundry.toml](foundry.toml) + [.env.example](.env.example)
3. **Script**: [script/DeployKipuBankV3.s.sol](script/DeployKipuBankV3.s.sol)
4. **CI/CD**: [.github/workflows/ci.yml](.github/workflows/ci.yml)

### For Exam Evaluators

1. **Start**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
2. **Code**: [src/KipuBankV3.sol](src/KipuBankV3.sol)
3. **Tests**: `forge test` + `forge coverage`
4. **Docs**: [README.md](README.md) - Threat analysis

---

## 🎨 Code Conventions

### Naming Conventions

```solidity
// State Variables
uint256 public bankCapUSD;              // camelCase
address public immutable usdc;          // camelCase

// Functions
function depositETH() external          // camelCase
function _getETHPrice() internal        // _prefix for internal/private

// Constants
uint256 public constant MAX_BPS = 10000;  // UPPER_SNAKE_CASE

// Events
event Deposit(...)                      // PascalCase

// Errors
error BankCapExceeded();                // PascalCase

// Roles
bytes32 public constant MANAGER_ROLE    // UPPER_SNAKE_CASE
```

### Comments

```solidity
/// @notice - User-facing description
/// @dev - Developer notes
/// @param - Parameter description
/// @return - Return value description
```

### Function Structure

```solidity
function exampleFunction()
    external                    // Visibility
    payable                     // State mutability
    override                    // Override
    nonReentrant               // Modifiers (security first)
    whenNotPaused              // Modifiers (business logic)
    nonZeroAmount(amount)      // Modifiers (validation)
{
    // 1. CHECKS (validations)
    // 2. EFFECTS (state updates)
    // 3. INTERACTIONS (external calls)
}
```

---

## 🚀 Recommended Workflow

### For Development

```bash
# 1. Clone and install
git clone <repo>
make install

# 2. Create branch
git checkout -b feature/my-feature

# 3. Develop
# Edit src/KipuBankV3.sol

# 4. Compile
make build

# 5. Test
make test
make coverage

# 6. Format
make format

# 7. Commit
git add .
git commit -m "feat: add feature X"

# 8. Push and PR
git push origin feature/my-feature
```

### For Deployment

```bash
# 1. Setup environment
cp .env.example .env
# Edit .env with your keys

# 2. Test locally
anvil  # Terminal 1
forge script script/DeployKipuBankV3.s.sol --rpc-url localhost --broadcast  # Terminal 2

# 3. Deploy on testnet
make deploy-sepolia

# 4. Verify deployment
cast call <ADDRESS> "bankCapUSD()(uint256)" --rpc-url sepolia

# 5. Post-deployment test
# See DEPLOYMENT.md section "Testing Post-Deployment"
```

---

## 📚 Additional Resources

### External Dependencies

- **OpenZeppelin Contracts**: https://docs.openzeppelin.com/contracts/
- **Chainlink Data Feeds**: https://docs.chain.link/data-feeds
- **Uniswap V2 Docs**: https://docs.uniswap.org/contracts/v2/overview
- **Foundry Book**: https://book.getfoundry.sh/

### Tools

- **Foundry**: Testing framework
- **Slither**: Static analysis
- **Tenderly**: Monitoring
- **Etherscan**: Block explorer

---

## ✅ Contributor Checklist

Before making a PR, verify:

- [ ] Code compiles without warnings: `make build`
- [ ] Tests pass: `make test`
- [ ] Coverage >= 75%: `make coverage`
- [ ] Code formatted: `make format`
- [ ] Complete NatSpec on public functions
- [ ] Gas optimized (no unnecessary storage reads)
- [ ] Security checks (ReentrancyGuard, CEI pattern)
- [ ] Documentation updated if API changes

---

**This project is an example of excellence in Solidity development with Foundry.** 🏆
