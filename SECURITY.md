# Security Policy

## 🔒 Reporting Security Vulnerabilities

We take the security of KipuBankV3 seriously. If you discover a security vulnerability, please follow responsible disclosure practices:

### DO NOT

- ❌ Open a public GitHub issue
- ❌ Discuss the vulnerability publicly
- ❌ Exploit the vulnerability

### DO

- ✅ Email us at **security@kipubank.io** with details
- ✅ Provide a clear description and steps to reproduce
- ✅ Allow us reasonable time to fix before public disclosure (typically 90 days)
- ✅ Work with us to verify the fix

## 🎁 Bug Bounty Program

We offer rewards for responsible disclosure of security vulnerabilities:

### Severity Levels

| Severity | Description | Reward |
|----------|-------------|--------|
| **Critical** | Direct theft of funds, manipulation of balances | $10,000 - $50,000 |
| **High** | Unauthorized access, price oracle manipulation | $5,000 - $10,000 |
| **Medium** | DoS attacks, griefing, MEV exploits | $1,000 - $5,000 |
| **Low** | Gas inefficiencies, minor edge cases | $100 - $1,000 |

### Scope

**In Scope:**
- KipuBankV3.sol main contract
- Integration with Uniswap V2
- Oracle price manipulation
- Reentrancy attacks
- Access control bypasses
- Bank cap bypasses

**Out of Scope:**
- Phishing attacks
- Social engineering
- UI/Frontend bugs
- Third-party contracts (Uniswap, Chainlink)
- Testnet deployments
- Known issues listed below

## 🚨 Known Issues

### 1. Tokens with Transfer Fees
**Status**: Acknowledged
**Severity**: Medium
**Description**: Tokens like STA or PAXG that charge fees on transfer are not currently supported.
**Mitigation**: Will be addressed in future version with token whitelist.

### 2. Slippage on Large Swaps
**Status**: Acknowledged
**Severity**: Low
**Description**: Very large swaps may experience significant slippage on Uniswap V2.
**Mitigation**: Configurable slippage tolerance, recommended to use batched deposits.

### 3. USDC Depeg Risk
**Status**: Acknowledged
**Severity**: Medium
**Description**: If USDC loses its $1 peg, internal accounting may be affected.
**Mitigation**: Emergency pause mechanism available, future versions will support multiple stablecoins.

## 🛡️ Security Measures

### Implemented

- ✅ **ReentrancyGuard**: All state-changing functions protected
- ✅ **CEI Pattern**: Checks-Effects-Interactions consistently applied
- ✅ **AccessControl**: Role-based permissions (Admin, Manager)
- ✅ **Pausable**: Emergency pause mechanism
- ✅ **SafeERC20**: Secure token transfers
- ✅ **Chainlink Oracle**: Price feed validation (staleness, validity)
- ✅ **Slippage Protection**: Configurable tolerance for swaps
- ✅ **Custom Errors**: Gas-efficient error handling
- ✅ **Input Validation**: Zero amounts/addresses rejected

### Audits

- [ ] **Code4rena Audit**: Scheduled for Q2 2025
- [ ] **OpenZeppelin Audit**: Scheduled for Q2 2025
- [x] **Internal Security Review**: Completed

## 📞 Contact

- **Security Email**: security@kipubank.io
- **PGP Key**: [Download Here](https://kipubank.io/pgp-key.asc)
- **Discord**: https://discord.gg/kipubank (Security channel)

## 🕒 Response Timeline

- **Initial Response**: Within 24 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Critical (1-7 days), High (7-14 days), Medium (14-30 days)
- **Public Disclosure**: After fix is deployed + 30 days notice

## 🏆 Hall of Fame

We recognize security researchers who have helped improve KipuBankV3:

*No submissions yet - be the first!*

---

**Thank you for helping keep KipuBankV3 secure!**
