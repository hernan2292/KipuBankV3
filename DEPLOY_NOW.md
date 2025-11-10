# 🚀 Instrucciones de Deployment - Sepolia

**Fecha**: 2025-11-09
**Red**: Sepolia Testnet
**Estado**: Listo para desplegar

---

## ⚡ Deployment Rápido (Opción 1 - Recomendado)

Abre tu terminal WSL y ejecuta:

```bash
cd /mnt/c/Users/herna/OneDrive/proyects/KipuBankV3

# Hacer ejecutable el script
chmod +x deploy-sepolia.sh

# Ejecutar deployment
./deploy-sepolia.sh
```

El script automáticamente:
1. ✅ Compila el contrato
2. ✅ Ejecuta los 49 tests
3. ✅ Despliega en Sepolia
4. ✅ Verifica en Etherscan

---

## 🔧 Deployment Manual (Opción 2)

Si prefieres ejecutar paso a paso:

### Paso 1: Abrir terminal WSL
```bash
cd /mnt/c/Users/herna/OneDrive/proyects/KipuBankV3
```

### Paso 2: Cargar variables
```bash
source .env
```

### Paso 3: Compilar
```bash
forge build
```

### Paso 4: Ejecutar tests (opcional pero recomendado)
```bash
forge test --gas-report
```

Deberías ver:
```
Ran 49 tests: 49 passed, 0 failed
```

### Paso 5: Deploy + Verify
```bash
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    -vvv
```

---

## 📋 Output Esperado

Verás algo como:

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

## 📍 Copiar Información del Deployment

Después del deployment exitoso, copia:

### 1. Dirección del Contrato
```
Contract Address: 0x1234567890abcdef1234567890abcdef12345678
```

### 2. URL de Etherscan
```
https://sepolia.etherscan.io/address/0x1234567890abcdef1234567890abcdef12345678#code
```

### 3. Transaction Hash
```
Hash: 0xabcd...1234
```

---

## ✅ Verificar Deployment

### 1. En Etherscan

Visita la URL y verifica:
- ✅ Código verificado (checkmark verde)
- ✅ Contract tab muestra el código Solidity
- ✅ Read Contract muestra funciones view
- ✅ Write Contract permite interacción

### 2. Usando Cast

```bash
# Ver bank cap
cast call 0x<CONTRACT_ADDRESS> "bankCapUSD()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# Ver withdrawal limit
cast call 0x<CONTRACT_ADDRESS> "withdrawalLimitUSD()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# Ver USDC address
cast call 0x<CONTRACT_ADDRESS> "usdc()(address)" --rpc-url $SEPOLIA_RPC_URL
```

---

## 🧪 Probar el Contrato

### Depositar ETH

```bash
# Obtener tu address
cast wallet address --private-key $PRIVATE_KEY

# Depositar 0.1 ETH
cast send 0x<CONTRACT_ADDRESS> \
    "depositETH()" \
    --value 0.1ether \
    --private-key $PRIVATE_KEY \
    --rpc-url $SEPOLIA_RPC_URL

# Ver tu balance
cast call 0x<CONTRACT_ADDRESS> \
    "getBalance(address)(uint256)" \
    <TU_ADDRESS> \
    --rpc-url $SEPOLIA_RPC_URL
```

### Depositar USDC (Sepolia)

Primero necesitas USDC de Sepolia:
- Faucet: https://faucet.circle.com/

```bash
# Aprobar USDC
cast send 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 \
    "approve(address,uint256)" \
    0x<CONTRACT_ADDRESS> \
    1000000000 \
    --private-key $PRIVATE_KEY \
    --rpc-url $SEPOLIA_RPC_URL

# Depositar 1000 USDC (6 decimals)
cast send 0x<CONTRACT_ADDRESS> \
    "depositToken(address,uint256)" \
    0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 \
    1000000000 \
    --private-key $PRIVATE_KEY \
    --rpc-url $SEPOLIA_RPC_URL
```

### Retirar

```bash
# Retirar 500 USDC
cast send 0x<CONTRACT_ADDRESS> \
    "withdraw(uint256)" \
    500000000 \
    --private-key $PRIVATE_KEY \
    --rpc-url $SEPOLIA_RPC_URL
```

---

## 📊 Información de Configuración

Tu deployment usará estos valores iniciales:

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

Tu wallet necesita ETH de Sepolia:
- Faucet 1: https://sepoliafaucet.com/
- Faucet 2: https://www.alchemy.com/faucets/ethereum-sepolia
- Faucet 3: https://cloud.google.com/application/web3/faucet/ethereum/sepolia

Necesitas ~0.01 ETH para el deployment.

### Error: "Invalid API key"

Verifica tu `ETHERSCAN_API_KEY` en `.env`:
1. Ve a https://etherscan.io/myapikey
2. Crea una API key si no tienes
3. Actualiza `.env`

### Error: "nonce too low"

```bash
# Reset nonce
cast nonce <TU_ADDRESS> --rpc-url $SEPOLIA_RPC_URL
```

### Verification Failed

Si el contrato se deployó pero la verificación falló:

```bash
# Verificar manualmente
forge verify-contract \
    0x<CONTRACT_ADDRESS> \
    src/KipuBankV3.sol:KipuBankV3 \
    --chain sepolia \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --constructor-args $(cast abi-encode "constructor(address,address,address,uint256,uint256,uint256)" \
        0x694AA1769357215DE4FAC081bf1f309aDC325306 \
        0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008 \
        0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 \
        1000000000000 \
        100000000000 \
        100)
```

---

## 🎯 Próximos Pasos Después del Deployment

1. ✅ Copiar la dirección del contrato
2. ✅ Copiar la URL de Etherscan
3. ✅ Probar depositETH() con 0.01 ETH
4. ✅ Verificar balance con getBalance()
5. ✅ Probar withdraw()
6. ✅ Documentar la URL en tu entregable

---

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs de error con `-vvvv`
2. Verifica que tengas ETH en Sepolia
3. Confirma que las variables de entorno están correctas
4. Consulta [DEPLOYMENT.md](DEPLOYMENT.md) para más detalles

---

## 🔗 Enlaces Útiles

- **Sepolia Etherscan**: https://sepolia.etherscan.io/
- **Sepolia Faucet**: https://sepoliafaucet.com/
- **USDC Faucet**: https://faucet.circle.com/
- **Alchemy Dashboard**: https://dashboard.alchemy.com/
- **Foundry Book**: https://book.getfoundry.sh/

---

**¡Listo para desplegar!** 🚀

Ejecuta: `./deploy-sepolia.sh`
