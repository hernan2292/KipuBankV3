# Análisis de Costos de Gas - KipuBankV3

Este documento proporciona un análisis detallado de los costos de gas para todas las funciones del contrato KipuBankV3.

---

## 📊 Resumen Ejecutivo

| Categoría | Gas Promedio | Costo USD* |
|-----------|--------------|------------|
| **Depósitos** | 200,000 - 300,000 | $30 - $45 |
| **Retiros** | 80,000 - 100,000 | $12 - $15 |
| **Gestión** | 50,000 - 80,000 | $7.5 - $12 |
| **Consultas** | 3,000 - 10,000 | $0.45 - $1.5 |

*Asumiendo ETH = $3,000, Gas Price = 50 gwei

---

## 🔍 Análisis Detallado por Función

### 1. DEPÓSITOS

#### 1.1 `depositETH()` - Depósito de ETH con Swap a USDC

**Operaciones:**
```solidity
1. Cache state variables (4 SLOAD)          ~8,400 gas
2. Read TokenInfo struct (1 SLOAD)          ~2,100 gas
3. Call getExpectedUSDC() (external view)   ~5,000 gas
4. Approve router implícitamente            ~    0 gas (ETH no requiere)
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

**Gas Total Estimado:** **~213,000 gas**

**Breakdown:**
- Lectura de storage: ~10,500 gas
- Lógica de swap (Uniswap): ~160,000 gas
- Escritura de storage: ~32,100 gas
- Eventos: ~3,000 gas
- Overhead (reentrancy, validaciones): ~7,400 gas

**Costo en USD:** $31.95 (ETH = $3000, 50 gwei)

**Optimizaciones Aplicadas:**
- ✅ State variable caching (ahorro: ~6,300 gas)
- ✅ Single writes (ahorro: ~10,000 gas)
- ✅ Unchecked arithmetic (ahorro: ~600 gas)
- **Total ahorrado: ~16,900 gas vs versión no optimizada**

---

#### 1.2 `depositToken()` - Depósito de Token ERC20 con Swap a USDC

**Caso A: Token = USDC (sin swap)**

**Operaciones:**
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

**Gas Total Estimado:** **~81,500 gas**

**Costo en USD:** $12.23

---

**Caso B: Token ≠ USDC (con swap)**

**Operaciones:**
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

**Gas Total Estimado:** **~250,100 gas**

**Costo en USD:** $37.52

**Optimizaciones Aplicadas:**
- ✅ Memory struct for TokenInfo (ahorro: ~4,200 gas)
- ✅ Single SSTORE for token stats (ahorro: ~10,000 gas)
- ✅ Unchecked arithmetic (ahorro: ~600 gas)
- **Total ahorrado: ~14,800 gas**

---

### 2. RETIROS

#### 2.1 `withdraw()` - Retiro de USDC

**Operaciones:**
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

**Gas Total Estimado:** **~58,300 gas**

**Costo en USD:** $8.75

**Optimizaciones Aplicadas:**
- ✅ State variable caching (ahorro: ~6,300 gas)
- ✅ Unchecked arithmetic (ahorro: ~600 gas)
- ✅ Single SSTORE per variable (ahorro: ~10,000 gas)
- **Total ahorrado: ~16,900 gas**

**Nota:** Si es el primer retiro del usuario, los SSTORE cuestan más (~22,100 gas cada uno), total sería ~93,300 gas.

---

### 3. FUNCIONES DE MANAGER

#### 3.1 `addToken()` - Agregar Token Soportado

**Operaciones:**
```solidity
1. Check if already supported (1 SLOAD)     ~2,100 gas
2. Check supportedTokens.length (1 SLOAD)   ~2,100 gas
3. Call token.decimals() (external view)    ~5,000 gas
4. Create TokenInfo struct (1 SSTORE)       ~22,100 gas
5. Push to supportedTokens array (SSTORE)   ~22,100 gas
6. Emit event                               ~1,000 gas
```

**Gas Total Estimado:** **~54,400 gas**

**Costo en USD:** $8.16

---

#### 3.2 `setTokenStatus()` - Cambiar Estado de Token

**Operaciones:**
```solidity
1. Read tokenInfo (1 SLOAD)                 ~2,100 gas
2. Update tokenInfo.status (1 SSTORE)       ~5,000 gas
3. Emit event                               ~1,000 gas
```

**Gas Total Estimado:** **~8,100 gas**

**Costo en USD:** $1.22

---

#### 3.3 `setBankCap()` - Actualizar Bank Cap

**Operaciones:**
```solidity
1. Cache old bankCapUSD (1 SLOAD)           ~2,100 gas
2. Cache totalBankValueUSD (1 SLOAD)        ~2,100 gas
3. Validations                              ~1,000 gas
4. Update bankCapUSD (1 SSTORE)             ~5,000 gas
5. Emit event                               ~1,000 gas
```

**Gas Total Estimado:** **~11,200 gas**

**Costo en USD:** $1.68

**Optimizaciones Aplicadas:**
- ✅ Cache old value antes de escribir (ahorro: ~2,100 gas)

---

#### 3.4 `setWithdrawalLimit()` - Actualizar Límite de Retiro

**Operaciones:**
```solidity
1. Cache old withdrawalLimitUSD (1 SLOAD)   ~2,100 gas
2. Cache bankCapUSD (1 SLOAD)               ~2,100 gas
3. Validations                              ~1,000 gas
4. Update withdrawalLimitUSD (1 SSTORE)     ~5,000 gas
5. Emit event                               ~1,000 gas
```

**Gas Total Estimado:** **~11,200 gas**

**Costo en USD:** $1.68

---

#### 3.5 `setSlippageTolerance()` - Actualizar Slippage

**Operaciones:**
```solidity
1. Validation                               ~500 gas
2. Cache old slippageToleranceBps (1 SLOAD) ~2,100 gas
3. Update slippageToleranceBps (1 SSTORE)   ~5,000 gas
4. Emit event                               ~1,000 gas
```

**Gas Total Estimado:** **~8,600 gas**

**Costo en USD:** $1.29

---

### 4. FUNCIONES DE ADMIN

#### 4.1 `pause()` - Pausar Contrato

**Operaciones:**
```solidity
1. Check role (2 SLOAD)                     ~4,200 gas
2. Update paused state (1 SSTORE)           ~5,000 gas
3. Emit event                               ~1,000 gas
```

**Gas Total Estimado:** **~10,200 gas**

**Costo en USD:** $1.53

---

#### 4.2 `unpause()` - Despausar Contrato

**Operaciones:**
```solidity
1. Check role (2 SLOAD)                     ~4,200 gas
2. Update paused state (1 SSTORE)           ~5,000 gas
3. Emit event                               ~1,000 gas
```

**Gas Total Estimado:** **~10,200 gas**

**Costo en USD:** $1.53

---

#### 4.3 `emergencyWithdraw()` - Retiro de Emergencia

**Caso A: ETH**

**Operaciones:**
```solidity
1. Check role (2 SLOAD)                     ~4,200 gas
2. Validations                              ~1,500 gas
3. Call to transfer ETH                     ~10,000 gas
```

**Gas Total Estimado:** **~15,700 gas**

**Costo en USD:** $2.36

---

**Caso B: ERC20**

**Operaciones:**
```solidity
1. Check role (2 SLOAD)                     ~4,200 gas
2. Validations                              ~1,500 gas
3. SafeTransfer token                       ~30,000 gas
```

**Gas Total Estimado:** **~35,700 gas**

**Costo en USD:** $5.36

---

### 5. FUNCIONES VIEW (Solo Lectura)

#### 5.1 `getBalance()` - Consultar Balance de Usuario

**Operaciones:**
```solidity
1. Read balances[user] (1 SLOAD)            ~2,100 gas
```

**Gas Total Estimado:** **~2,100 gas**

**Costo en USD:** $0.32 (si se llama en tx, gratis en view call)

---

#### 5.2 `getTotalBankValueUSD()` - Consultar Total del Banco

**Operaciones:**
```solidity
1. Read totalBankValueUSD (1 SLOAD)         ~2,100 gas
```

**Gas Total Estimado:** **~2,100 gas**

**Costo en USD:** $0.32 (si se llama en tx, gratis en view call)

---

#### 5.3 `getSupportedTokens()` - Listar Tokens Soportados

**Operaciones:**
```solidity
1. Read supportedTokens array length        ~2,100 gas
2. Copy array to memory (~5 tokens)         ~1,000 gas
```

**Gas Total Estimado:** **~3,100 gas** (para 5 tokens)

**Nota:** Aumenta ~200 gas por cada token adicional.

**Costo en USD:** $0.47 (si se llama en tx, gratis en view call)

---

#### 5.4 `getTokenInfo()` - Consultar Info de Token

**Operaciones:**
```solidity
1. Read tokenInfo[token] struct (1 SLOAD)   ~2,100 gas
2. Copy struct to memory                    ~500 gas
```

**Gas Total Estimado:** **~2,600 gas**

**Costo en USD:** $0.39 (si se llama en tx, gratis en view call)

---

#### 5.5 `getETHPriceUSD()` - Consultar Precio de ETH

**Operaciones:**
```solidity
1. Call Chainlink oracle                    ~5,000 gas
2. Validations                              ~1,000 gas
```

**Gas Total Estimado:** **~6,000 gas**

**Costo en USD:** $0.90 (si se llama en tx, gratis en view call)

---

#### 5.6 `getExpectedUSDC()` - Estimar USDC de Swap

**Operaciones:**
```solidity
1. Build path array                         ~500 gas
2. Call Uniswap getAmountsOut               ~8,000 gas
3. Validations                              ~500 gas
```

**Gas Total Estimado:** **~9,000 gas**

**Costo en USD:** $1.35 (si se llama en tx, gratis en view call)

---

## 📈 Comparativa: Con y Sin Optimizaciones

| Función | Sin Optimizaciones | Con Optimizaciones | Ahorro |
|---------|-------------------|-------------------|--------|
| `depositETH()` | ~230,000 gas | ~213,000 gas | **-7.4%** |
| `depositToken()` (swap) | ~265,000 gas | ~250,000 gas | **-5.7%** |
| `withdraw()` | ~75,000 gas | ~58,000 gas | **-22.7%** |
| `setBankCap()` | ~13,300 gas | ~11,200 gas | **-15.8%** |
| `setWithdrawalLimit()` | ~13,300 gas | ~11,200 gas | **-15.8%** |

**Ahorro total promedio: ~12-15%**

---

## 💰 Cálculo de Costos en Diferentes Escenarios

### Escenario 1: Gas Price Bajo (30 gwei)

| Función | Gas | Costo ETH | Costo USD (ETH=$3000) |
|---------|-----|-----------|---------------------|
| depositETH() | 213,000 | 0.00639 ETH | $19.17 |
| depositToken() (swap) | 250,000 | 0.00750 ETH | $22.50 |
| depositToken() (USDC) | 81,500 | 0.00245 ETH | $7.35 |
| withdraw() | 58,000 | 0.00174 ETH | $5.22 |
| addToken() | 54,400 | 0.00163 ETH | $4.89 |

---

### Escenario 2: Gas Price Medio (50 gwei) - ACTUAL

| Función | Gas | Costo ETH | Costo USD (ETH=$3000) |
|---------|-----|-----------|---------------------|
| depositETH() | 213,000 | 0.01065 ETH | **$31.95** |
| depositToken() (swap) | 250,000 | 0.01250 ETH | **$37.50** |
| depositToken() (USDC) | 81,500 | 0.00408 ETH | **$12.24** |
| withdraw() | 58,000 | 0.00290 ETH | **$8.70** |
| addToken() | 54,400 | 0.00272 ETH | **$8.16** |

---

### Escenario 3: Gas Price Alto (100 gwei)

| Función | Gas | Costo ETH | Costo USD (ETH=$3000) |
|---------|-----|-----------|---------------------|
| depositETH() | 213,000 | 0.0213 ETH | $63.90 |
| depositToken() (swap) | 250,000 | 0.0250 ETH | $75.00 |
| depositToken() (USDC) | 81,500 | 0.00815 ETH | $24.45 |
| withdraw() | 58,000 | 0.00580 ETH | $17.40 |
| addToken() | 54,400 | 0.00544 ETH | $16.32 |

---

## 🎯 Recomendaciones para Usuarios

### Para Minimizar Costos de Gas:

1. **Depositar USDC directamente** en lugar de otros tokens
   - Ahorro: ~170,000 gas (~$25.50 a 50 gwei)

2. **Realizar depósitos grandes** en lugar de múltiples pequeños
   - Costo fijo de ~213,000 gas por depósito independiente del monto

3. **Monitorear gas prices**
   - Usar herramientas como [ETH Gas Station](https://ethgasstation.info/)
   - Esperar a gas < 50 gwei para operaciones no urgentes

4. **Usar L2s en el futuro** (cuando KipuBankV3 se despliegue en L2)
   - Polygon: ~100x más barato
   - Arbitrum: ~10x más barato
   - Optimism: ~10x más barato

---

## 📊 Distribución de Gas por Categoría

### Operaciones de Lectura (SLOAD)
- **Costo base:** 2,100 gas por slot
- **Warm access:** 100 gas (ya leído en misma tx)
- **Cold access:** 2,100 gas (primera lectura)

### Operaciones de Escritura (SSTORE)
- **Slot zero → non-zero:** 22,100 gas (primera escritura)
- **Slot non-zero → non-zero:** 5,000 gas (actualización)
- **Slot non-zero → zero:** 5,000 gas + 15,000 gas refund

### Llamadas Externas
- **Call a contrato externo:** 2,600 gas base
- **Transfer ERC20:** ~30,000-50,000 gas
- **Uniswap swap:** ~80,000-120,000 gas

### Eventos
- **LOG0 (sin indexed):** ~375 gas
- **LOG1 (1 indexed):** ~750 gas
- **LOG2 (2 indexed):** ~1,125 gas
- **LOG3 (3 indexed):** ~1,500 gas
- **+ ~8 gas por byte de data**

---

## 🧪 Cómo Ejecutar Análisis de Gas

Para obtener costos de gas exactos en tu entorno:

```bash
# 1. Ejecutar tests con reporte de gas
forge test --gas-report

# 2. Ver solo funciones específicas
forge test --gas-report --match-contract KipuBankV3Test

# 3. Generar reporte detallado en archivo
forge test --gas-report > gas-report.txt

# 4. Snapshot de gas (comparar cambios)
forge snapshot
forge snapshot --diff

# 5. Gas con optimizaciones desactivadas (comparación)
forge test --gas-report --no-optimizer
```

---

## 📝 Notas Importantes

1. **Los valores son estimaciones** basadas en operaciones típicas de Solidity
2. **Gas real puede variar** dependiendo de:
   - Estado de la blockchain (storage slots calientes/fríos)
   - Complejidad del swap en Uniswap
   - Liquidez del par de tokens
   - Versión del compilador de Solidity

3. **View functions son GRATIS** cuando se llaman fuera de transacciones (via `eth_call`)

4. **Optimizaciones aplicadas:**
   - State variable caching
   - Single SLOAD/SSTORE por variable
   - Unchecked arithmetic donde es seguro
   - Memory structs en lugar de storage pointers

---

## 🔗 Referencias

- [Ethereum Yellow Paper - Gas Costs](https://ethereum.github.io/yellowpaper/paper.pdf)
- [EIP-2200: Structured Definitions for Net Gas Metering](https://eips.ethereum.org/EIPS/eip-2200)
- [Solidity Optimizer](https://docs.soliditylang.org/en/latest/internals/optimizer.html)
- [ETH Gas Station](https://ethgasstation.info/)

---

**Última actualización:** 2025-11-09
**Versión del contrato:** KipuBankV3 v1.0.0
**Solidity:** 0.8.30
**Optimizer:** Enabled (200 runs)
**Autor**: Hernan Herrera
**Organización**: White Paper
