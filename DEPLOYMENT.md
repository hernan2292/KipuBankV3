# Guía de Despliegue - KipuBankV3

Esta guía detalla el proceso paso a paso para desplegar KipuBankV3 en testnet (Sepolia) y mainnet.

## 📋 Pre-requisitos

### 1. Instalar Foundry

```bash
# Instalar Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verificar instalación
forge --version
cast --version
```

### 2. Obtener API Keys

#### Alchemy/Infura (RPC)
1. Crear cuenta en [Alchemy](https://www.alchemy.com/) o [Infura](https://infura.io/)
2. Crear app para Sepolia y Mainnet
3. Copiar API keys

#### Etherscan (Verificación)
1. Crear cuenta en [Etherscan](https://etherscan.io/)
2. Ir a API Keys → Create new API key
3. Copiar API key

### 3. Obtener ETH para Gas

#### Sepolia Testnet
- Faucet 1: https://sepoliafaucet.com/
- Faucet 2: https://www.alchemy.com/faucets/ethereum-sepolia
- Faucet 3: https://sepolia-faucet.pk910.de/

#### Mainnet
- Comprar ETH en exchange (Coinbase, Binance, etc.)
- Transferir a tu wallet de deployment

---

## 🔧 Configuración

### 1. Clonar y Configurar Proyecto

```bash
# Clonar repositorio
git clone https://github.com/your-username/KipuBankV3.git
cd KipuBankV3

# Instalar dependencias
make install
# O manualmente:
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink --no-commit
forge install foundry-rs/forge-std --no-commit

# Compilar contratos
make build
```

### 2. Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env
nano .env
```

Completar el archivo `.env`:

```bash
# RPC URLs (reemplazar YOUR_API_KEY)
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY

# Private Key (⚠️ NUNCA compartir ni commitear!)
PRIVATE_KEY=0x1234567890abcdef...

# Etherscan API Key
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY

# Direcciones de contratos (ya configuradas)
UNISWAP_V2_ROUTER_SEPOLIA=0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008
USDC_SEPOLIA=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
ETH_USD_PRICE_FEED_SEPOLIA=0x694AA1769357215DE4FAC081bf1f309aDC325306
```

**⚠️ SEGURIDAD**:
- NUNCA commitear el archivo `.env` a Git
- Usar wallet separada para deployment (no tu wallet personal)
- Para producción, usar hardware wallet o Multisig

---

## 🧪 Testing Pre-Deployment

### 1. Tests Locales

```bash
# Ejecutar todos los tests
make test

# Tests con verbose
make test-v

# Tests específicos
make test-DepositETH

# Gas report
make gas-report

# Cobertura
make coverage
```

**Target**: Todos los tests deben pasar ✅

### 2. Fork Testing (Mainnet)

```bash
# Ejecutar tests en fork de mainnet
forge test --fork-url $MAINNET_RPC_URL

# Test específico en fork
forge test --fork-url $MAINNET_RPC_URL --match-test test_Integration
```

Esto ejecuta tests contra un fork local de mainnet, usando datos reales de Uniswap y Chainlink.

---

## 🚀 Deployment en Sepolia (Testnet)

### 1. Verificar Balance

```bash
# Verificar balance de ETH en Sepolia
cast balance $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL

# Convertir a ETH legible
cast balance $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL | cast --to-unit ether
```

Necesitas al menos **0.05 ETH** en Sepolia para deployment + interacciones.

### 2. Dry Run (Simulación)

```bash
# Simular deployment sin broadcast
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $SEPOLIA_RPC_URL
```

Esto simula el deployment y muestra:
- Gas estimado
- Direcciones de contratos
- Errores (si hay)

### 3. Deployment Real

```bash
# Opción 1: Usando Makefile
make deploy-sepolia

# Opción 2: Comando completo
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

**Output esperado**:
```
Deploying to Sepolia...
KipuBankV3 deployed to: 0x1234567890abcdef...
Bank Cap: 1000000000000
Withdrawal Limit: 100000000000
Slippage Tolerance: 100 bps

Starting verification...
Contract verified: https://sepolia.etherscan.io/address/0x123...
```

### 4. Guardar Dirección del Contrato

```bash
# Guardar en archivo para referencia
echo "KIPUBANK_V3_SEPOLIA=0xYourContractAddress" >> .env
```

### 5. Verificación Manual (si falló auto-verificación)

```bash
# Obtener los argumentos del constructor en formato ABI
cast abi-encode "constructor(address,address,address,uint256,uint256,uint256)" \
  0x694AA1769357215DE4FAC081bf1f309aDC325306 \  # ethUsdPriceFeed
  0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008 \  # uniswapRouter
  0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 \  # usdc
  1000000000000 \  # bankCapUSD (1M USDC)
  100000000000 \   # withdrawalLimitUSD (100K USDC)
  100              # slippageTolerance (1%)

# Verificar manualmente
forge verify-contract \
  --chain-id 11155111 \
  --num-of-optimizations 200 \
  --compiler-version 0.8.30 \
  --constructor-args <RESULTADO_ABI_ENCODE> \
  <CONTRACT_ADDRESS> \
  src/KipuBankV3.sol:KipuBankV3 \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

---

## 🧪 Testing Post-Deployment (Sepolia)

### 1. Verificar Estado Inicial

```bash
# Obtener bank cap
cast call <CONTRACT_ADDRESS> "bankCapUSD()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# Obtener tokens soportados
cast call <CONTRACT_ADDRESS> "getSupportedTokens()(address[])" --rpc-url $SEPOLIA_RPC_URL

# Verificar roles
cast call <CONTRACT_ADDRESS> "hasRole(bytes32,address)(bool)" \
  $(cast --format-bytes32-string "MANAGER_ROLE") \
  $YOUR_ADDRESS \
  --rpc-url $SEPOLIA_RPC_URL
```

### 2. Test de Depósito ETH

```bash
# Depositar 0.1 ETH
cast send <CONTRACT_ADDRESS> "depositETH()" \
  --value 0.1ether \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL

# Verificar balance
cast call <CONTRACT_ADDRESS> "getBalance(address)(uint256)" \
  $YOUR_ADDRESS \
  --rpc-url $SEPOLIA_RPC_URL
```

### 3. Test de Depósito USDC

```bash
# Obtener dirección de USDC Sepolia
USDC_SEPOLIA=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238

# Aprobar KipuBankV3 para gastar USDC
cast send $USDC_SEPOLIA "approve(address,uint256)" \
  <CONTRACT_ADDRESS> \
  1000000000 \  # 1000 USDC (6 decimals)
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL

# Depositar 1000 USDC
cast send <CONTRACT_ADDRESS> "depositToken(address,uint256)" \
  $USDC_SEPOLIA \
  1000000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

### 4. Test de Retiro

```bash
# Retirar 100 USDC
cast send <CONTRACT_ADDRESS> "withdraw(uint256)" \
  100000000 \  # 100 USDC
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

### 5. Test de Funciones de Manager

```bash
# Agregar nuevo token (ej. DAI)
DAI_SEPOLIA=0xYourDAIAddress

cast send <CONTRACT_ADDRESS> "addToken(address)" \
  $DAI_SEPOLIA \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL

# Actualizar bank cap
cast send <CONTRACT_ADDRESS> "setBankCap(uint256)" \
  2000000000000 \  # 2M USDC
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

---

## 🌐 Deployment en Mainnet

### ⚠️ PRE-FLIGHT CHECKLIST

**ANTES de desplegar en mainnet, verificar:**

- [ ] ✅ Todos los tests pasan en local
- [ ] ✅ Fork tests pasan en mainnet fork
- [ ] ✅ Deployment en Sepolia exitoso
- [ ] ✅ Testing post-deployment en Sepolia completo
- [ ] ✅ Auditoría de seguridad completada (RECOMENDADO)
- [ ] ✅ Bug bounty program configurado
- [ ] ✅ Multisig preparado para admin role
- [ ] ✅ Monitoreo configurado (Tenderly, Defender)
- [ ] ✅ Plan de respuesta a incidentes documentado
- [ ] ✅ Gas price aceptable (<50 gwei recomendado)
- [ ] ✅ Balance suficiente (~0.5 ETH recomendado)

### 1. Verificar Parámetros de Mainnet

```bash
# Verificar direcciones de mainnet
echo "ETH/USD Feed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"
echo "Uniswap Router: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
echo "USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

# Verificar gas price actual
cast gas-price --rpc-url $MAINNET_RPC_URL

# Convertir a Gwei
cast --to-unit gwei $(cast gas-price --rpc-url $MAINNET_RPC_URL)
```

### 2. Dry Run en Mainnet Fork

```bash
# Simular deployment en fork de mainnet
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --fork-url $MAINNET_RPC_URL
```

### 3. Deployment Real (Con Confirmación)

```bash
# ⚠️ ÚLTIMA ADVERTENCIA ⚠️
echo "¿Estás SEGURO de querer desplegar en MAINNET?"
echo "Esto usará ETH REAL y el contrato será INMUTABLE."
echo "Presiona Ctrl+C para cancelar, o Enter para continuar..."
read

# Deployment
make deploy-mainnet

# O comando completo
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --slow  # Espera entre transacciones para confirmación
```

### 4. Post-Deployment Inmediato

```bash
# 1. Guardar dirección
echo "KIPUBANK_V3_MAINNET=0xYourMainnetAddress" >> .env

# 2. Transferir ownership a Multisig (CRÍTICO)
MULTISIG_ADDRESS=0xYourGnosisSafeAddress

cast send <CONTRACT_ADDRESS> "grantRole(bytes32,address)" \
  $(cast keccak "DEFAULT_ADMIN_ROLE") \
  $MULTISIG_ADDRESS \
  --private-key $PRIVATE_KEY \
  --rpc-url $MAINNET_RPC_URL

# 3. Renunciar a tu admin role (después de verificar multisig)
cast send <CONTRACT_ADDRESS> "renounceRole(bytes32,address)" \
  $(cast keccak "DEFAULT_ADMIN_ROLE") \
  $YOUR_ADDRESS \
  --private-key $PRIVATE_KEY \
  --rpc-url $MAINNET_RPC_URL
```

### 5. Configurar Monitoreo

```bash
# Configurar alertas en Tenderly
# 1. Ir a https://dashboard.tenderly.co/
# 2. Add Contract → Paste mainnet address
# 3. Configure Alerts:
#    - Deposit > $100k
#    - Withdrawal > $50k
#    - pause() called
#    - emergencyWithdraw() called
#    - Bank cap > 90% lleno

# Configurar OpenZeppelin Defender
# 1. Ir a https://defender.openzeppelin.com/
# 2. Import Contract
# 3. Configure Sentinels para eventos críticos
```

---

## 📊 Verificación y Monitoreo

### Etherscan

1. Ir a https://etherscan.io/address/<CONTRACT_ADDRESS>
2. Verificar:
   - Contract ✅ (green checkmark)
   - Read Contract (funciones view)
   - Write Contract (funciones state-changing)
   - Events (depósitos, retiros, swaps)

### Tenderly

```bash
# Agregar contrato a Tenderly
tenderly export init
tenderly export <CONTRACT_ADDRESS>
```

### DeFi Llama

Enviar contrato para tracking de TVL:
- GitHub: https://github.com/DefiLlama/DefiLlama-Adapters
- Submit PR con adapter para KipuBankV3

---

## 🔧 Troubleshooting

### Error: "Insufficient funds"

```bash
# Verificar balance
cast balance $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL

# Obtener ETH de faucet
# Sepolia: https://sepoliafaucet.com/
```

### Error: "Verification failed"

```bash
# Verificar manualmente
forge verify-contract \
  --chain-id <CHAIN_ID> \
  --compiler-version 0.8.30 \
  --num-of-optimizations 200 \
  <CONTRACT_ADDRESS> \
  src/KipuBankV3.sol:KipuBankV3

# O usar Etherscan UI
# 1. Ir a Etherscan
# 2. Contract → Verify & Publish
# 3. Copiar código de KipuBankV3.sol
# 4. Marcar optimización (200 runs)
```

### Error: "Nonce too low"

```bash
# Obtener nonce actual
cast nonce $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL

# Si hay discrepancia, esperar o usar --nonce flag
```

### Gas muy alto

```bash
# Esperar a gas price bajo
while [ $(cast --to-unit gwei $(cast gas-price --rpc-url mainnet)) -gt 30 ]; do
  echo "Gas price too high, waiting..."
  sleep 300  # Esperar 5 minutos
done
echo "Gas price acceptable, deploying..."
```

---

## 📝 Checklist Final

### Pre-Deployment
- [ ] Tests pasan (100%)
- [ ] Coverage >50%
- [ ] Code review completo
- [ ] Auditoría (si mainnet)
- [ ] Gas optimizado
- [ ] Documentación completa

### Deployment
- [ ] .env configurado
- [ ] Balance suficiente
- [ ] Dry run exitoso
- [ ] Deployment ejecutado
- [ ] Contrato verificado en Etherscan

### Post-Deployment
- [ ] Tests post-deployment pasan
- [ ] Ownership transferido a Multisig
- [ ] Monitoreo configurado
- [ ] Alertas configuradas
- [ ] Documentación actualizada con direcciones
- [ ] Anuncio público (Twitter, Discord)

---

## 🆘 Soporte

Si encuentras problemas:

1. **Documentación**: Revisa [README.md](README.md)
2. **Issues**: https://github.com/your-username/KipuBankV3/issues
3. **Discord**: https://discord.gg/kipubank
4. **Email**: support@kipubank.io

---

## 📚 Referencias

- [Foundry Book](https://book.getfoundry.sh/)
- [Sepolia Faucets](https://faucetlink.to/sepolia)
- [Etherscan API Docs](https://docs.etherscan.io/)
- [Tenderly Docs](https://docs.tenderly.co/)
- [OpenZeppelin Defender](https://docs.openzeppelin.com/defender/)

---

**Buena suerte con tu deployment! 🚀**
