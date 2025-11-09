# Quick Start Guide - KipuBankV3

Esta guía te llevará desde cero hasta tener KipuBankV3 funcionando en 5 minutos.

## ⚡ Setup Rápido (5 minutos)

### 1. Prerequisitos

```bash
# Verificar que tienes git
git --version

# Instalar Foundry (si no lo tienes)
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Clonar e Instalar

```bash
# Clonar
git clone https://github.com/your-username/KipuBankV3.git
cd KipuBankV3

# Instalar dependencias
make install

# Compilar
make build
```

### 3. Ejecutar Tests

```bash
# Correr todos los tests
make test

# Ver output detallado
make test-v
```

**✅ Si todos los tests pasan, estás listo!**

---

## 🎯 Uso Básico

### Opción 1: Deploy Local (Anvil)

```bash
# Terminal 1: Iniciar nodo local
anvil

# Terminal 2: Deploy
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

### Opción 2: Deploy Testnet (Sepolia)

```bash
# 1. Configurar .env
cp .env.example .env
nano .env  # Agregar tus API keys

# 2. Obtener ETH de testnet
# https://sepoliafaucet.com/

# 3. Deploy
make deploy-sepolia
```

---

## 💡 Ejemplos Comunes

### Depositar ETH

```bash
# Depositar 0.1 ETH
cast send <CONTRACT_ADDRESS> "depositETH()" \
  --value 0.1ether \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

### Depositar USDC

```bash
# 1. Aprobar USDC
cast send <USDC_ADDRESS> "approve(address,uint256)" \
  <CONTRACT_ADDRESS> \
  1000000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL

# 2. Depositar 1000 USDC
cast send <CONTRACT_ADDRESS> "depositToken(address,uint256)" \
  <USDC_ADDRESS> \
  1000000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

### Consultar Balance

```bash
cast call <CONTRACT_ADDRESS> "getBalance(address)(uint256)" \
  $YOUR_ADDRESS \
  --rpc-url $RPC_URL
```

### Retirar USDC

```bash
cast send <CONTRACT_ADDRESS> "withdraw(uint256)" \
  100000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

---

## 🔍 Explorar el Código

### Estructura del Proyecto

```
KipuBankV3/
├── src/
│   ├── KipuBankV3.sol           ← Contrato principal
│   ├── interfaces/
│   │   ├── IKipuBankV3.sol      ← Interface principal
│   │   └── IUniswapV2Router02.sol
│   └── mocks/                   ← Mocks para testing
├── test/
│   └── KipuBankV3.t.sol         ← Suite de tests (65+ tests)
├── script/
│   └── DeployKipuBankV3.s.sol   ← Script de deployment
├── foundry.toml                  ← Configuración Foundry
├── README.md                     ← Documentación completa
├── DEPLOYMENT.md                 ← Guía de deployment
└── SECURITY.md                   ← Política de seguridad
```

### Funciones Principales

```solidity
// Depósitos
function depositETH() external payable
function depositToken(address token, uint256 amount) external

// Retiros
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

## 🧪 Testing Avanzado

### Tests Específicos

```bash
# Solo tests de depósitos
make test-DepositETH

# Solo tests de manager
forge test --match-test test_AddToken

# Fuzz tests
forge test --match-test testFuzz
```

### Cobertura

```bash
# Ver cobertura
make coverage

# Generar reporte HTML
forge coverage --report lcov
genhtml lcov.info --output-directory coverage
open coverage/index.html
```

### Fork Testing

```bash
# Test contra mainnet real
forge test --fork-url $MAINNET_RPC_URL --match-test test_Integration
```

---

## 📚 Próximos Pasos

1. **Leer Documentación Completa**: [README.md](README.md)
2. **Entender Arquitectura**: Ver diagrama de flujo en README
3. **Revisar Tests**: [test/KipuBankV3.t.sol](test/KipuBankV3.t.sol)
4. **Deploy en Testnet**: [DEPLOYMENT.md](DEPLOYMENT.md)
5. **Contribuir**: [CONTRIBUTING.md](CONTRIBUTING.md)

---

## ❓ FAQ

### ¿Por qué usar Uniswap V2 y no V3?
V2 es más simple para este caso de uso. V3 se considerará en futuras versiones.

### ¿Los usuarios pueden recuperar el token original?
No, todos los depósitos se convierten a USDC. Los retiros son solo en USDC.

### ¿Qué pasa si USDC pierde su peg?
El contrato tiene función `pause()` para emergencias. En el futuro se soportarán múltiples stablecoins.

### ¿Cuánto gas cuesta un depósito con swap?
Aproximadamente 150k-250k gas (depende de la ruta de swap). ETH directo es más barato que tokens ERC20.

### ¿Es seguro para producción?
**NO** sin auditoría profesional. Esto es un proyecto educativo. Ver [SECURITY.md](SECURITY.md).

---

## 🆘 Ayuda

- **Documentación**: [README.md](README.md)
- **Issues**: https://github.com/your-username/KipuBankV3/issues
- **Discord**: https://discord.gg/kipubank
- **Email**: support@kipubank.io

---

## 🎉 ¡Listo!

Ya tienes todo para empezar a usar y desarrollar con KipuBankV3.

**Happy coding!** 🚀
