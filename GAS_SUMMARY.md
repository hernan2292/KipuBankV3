# 📊 Resumen Ejecutivo - Costos de Gas KipuBankV3

**Versión:** 1.0.0
**Fecha:** 2025-11-09
**Solidity:** 0.8.30 (Optimizer: 200 runs)
**Autor**: Hernan Herrera
**Organización**: White Paper

---

## 💰 Costos Principales (50 gwei, ETH = $3000)

```
┌─────────────────────────────────────────────────────────────────┐
│                    OPERACIONES DE USUARIO                        │
├─────────────────────────────────┬──────────┬─────────────────────┤
│ Función                         │ Gas      │ Costo USD           │
├─────────────────────────────────┼──────────┼─────────────────────┤
│ 💸 depositETH()                 │ 213,000  │ $31.95              │
│ 💸 depositToken() [con swap]    │ 250,000  │ $37.50              │
│ 💸 depositToken() [USDC]        │  81,500  │ $12.24              │
│ 💵 withdraw()                   │  58,000  │  $8.70              │
└─────────────────────────────────┴──────────┴─────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    OPERACIONES DE GESTIÓN                        │
├─────────────────────────────────┬──────────┬─────────────────────┤
│ Función                         │ Gas      │ Costo USD           │
├─────────────────────────────────┼──────────┼─────────────────────┤
│ ⚙️  addToken()                  │  54,400  │  $8.16              │
│ ⚙️  setTokenStatus()            │   8,100  │  $1.22              │
│ ⚙️  setBankCap()                │  11,200  │  $1.68              │
│ ⚙️  setWithdrawalLimit()        │  11,200  │  $1.68              │
│ ⚙️  setSlippageTolerance()      │   8,600  │  $1.29              │
└─────────────────────────────────┴──────────┴─────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    OPERACIONES DE ADMIN                          │
├─────────────────────────────────┬──────────┬─────────────────────┤
│ Función                         │ Gas      │ Costo USD           │
├─────────────────────────────────┼──────────┼─────────────────────┤
│ 🛑 pause()                      │  10,200  │  $1.53              │
│ ▶️  unpause()                   │  10,200  │  $1.53              │
│ 🚨 emergencyWithdraw() [ETH]    │  15,700  │  $2.36              │
│ 🚨 emergencyWithdraw() [Token]  │  35,700  │  $5.36              │
└─────────────────────────────────┴──────────┴─────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    FUNCIONES VIEW (GRATIS)*                      │
├─────────────────────────────────┬──────────┬─────────────────────┤
│ Función                         │ Gas**    │ Costo USD           │
├─────────────────────────────────┼──────────┼─────────────────────┤
│ 👁️  getBalance()                │   2,100  │  $0.00 (view)       │
│ 👁️  getTotalBankValueUSD()      │   2,100  │  $0.00 (view)       │
│ 👁️  getSupportedTokens()        │   3,100  │  $0.00 (view)       │
│ 👁️  getTokenInfo()              │   2,600  │  $0.00 (view)       │
│ 👁️  getETHPriceUSD()            │   6,000  │  $0.00 (view)       │
│ 👁️  getExpectedUSDC()           │   9,000  │  $0.00 (view)       │
└─────────────────────────────────┴──────────┴─────────────────────┘
```

*View functions son gratis cuando se llaman con `eth_call` (no en transacciones)
**Gas estimado si se llamaran en una transacción

---

## 📈 Comparativa por Escenario de Gas Price

### Depósito de ETH (213,000 gas)

| Gas Price | Costo en ETH | Costo en USD (ETH=$3000) |
|-----------|--------------|--------------------------|
| 20 gwei   | 0.00426 ETH  | **$12.78** 🟢           |
| 30 gwei   | 0.00639 ETH  | **$19.17** 🟢           |
| 50 gwei   | 0.01065 ETH  | **$31.95** 🟡           |
| 100 gwei  | 0.02130 ETH  | **$63.90** 🔴           |
| 200 gwei  | 0.04260 ETH  | **$127.80** 🔴          |

### Retiro de USDC (58,000 gas)

| Gas Price | Costo en ETH | Costo en USD (ETH=$3000) |
|-----------|--------------|--------------------------|
| 20 gwei   | 0.00116 ETH  | **$3.48** 🟢            |
| 30 gwei   | 0.00174 ETH  | **$5.22** 🟢            |
| 50 gwei   | 0.00290 ETH  | **$8.70** 🟡            |
| 100 gwei  | 0.00580 ETH  | **$17.40** 🔴           |
| 200 gwei  | 0.01160 ETH  | **$34.80** 🔴           |

---

## 🎯 Consejos para Minimizar Costos

### 1. 💡 Depositar USDC Directamente

```
❌ depositToken(DAI, 1000) → Swap → 250,000 gas → $37.50
✅ depositToken(USDC, 1000) → Directo → 81,500 gas → $12.24

💰 AHORRO: ~$25.26 (67% menos gas)
```

### 2. ⏰ Esperar a Gas Price Bajo

```
Gas Price Promedio por Hora del Día (UTC):
- 00:00 - 06:00: 20-40 gwei  ← MEJOR MOMENTO 🌙
- 06:00 - 12:00: 40-80 gwei
- 12:00 - 18:00: 60-120 gwei ← EVITAR ☀️
- 18:00 - 24:00: 50-90 gwei
```

**Herramientas:**
- [ETH Gas Station](https://ethgasstation.info/)
- [Gas Now](https://www.gasnow.org/)
- [Blocknative Gas Estimator](https://www.blocknative.com/gas-estimator)

### 3. 📦 Agrupar Operaciones

```
❌ 10 depósitos de $100 = 10 × 213,000 gas = 2,130,000 gas
✅ 1 depósito de $1000 = 1 × 213,000 gas = 213,000 gas

💰 AHORRO: ~90% en costos de gas por usar batch
```

### 4. 🌐 Usar Layer 2 (Futuro)

Cuando KipuBankV3 se despliegue en L2:

| Network | Gas Cost vs L1 | depositETH() Cost |
|---------|----------------|-------------------|
| Ethereum L1 | 1x | $31.95 |
| **Polygon** | **~100x cheaper** | **~$0.32** 🎉 |
| **Arbitrum** | **~10x cheaper** | **~$3.20** 🎉 |
| **Optimism** | **~10x cheaper** | **~$3.20** 🎉 |
| **zkSync** | **~50x cheaper** | **~$0.64** 🎉 |

---

## 📊 Distribución de Costos en depositETH()

```
Total: 213,000 gas ($31.95)

┌─────────────────────────────────────────┐
│  Uniswap Swap: 160,000 gas (75%)        │ ████████████████████████████
│  Storage Writes: 32,100 gas (15%)       │ ██████
│  Storage Reads: 10,500 gas (5%)         │ ██
│  Validaciones: 7,400 gas (3%)           │ █
│  Eventos: 3,000 gas (2%)                │ █
└─────────────────────────────────────────┘
```

**Conclusión:** El 75% del costo es por el swap de Uniswap V2 (inevitable).

---

## ✅ Optimizaciones Aplicadas

### Antes vs Después de Optimizaciones

```
┌────────────────────┬─────────────┬──────────────┬──────────┐
│ Función            │ Antes (gas) │ Después (gas)│ Ahorro   │
├────────────────────┼─────────────┼──────────────┼──────────┤
│ depositETH()       │ 230,000     │ 213,000      │ -7.4%    │
│ depositToken()     │ 265,000     │ 250,000      │ -5.7%    │
│ withdraw()         │  75,000     │  58,000      │ -22.7%   │
│ setBankCap()       │  13,300     │  11,200      │ -15.8%   │
└────────────────────┴─────────────┴──────────────┴──────────┘

📉 Ahorro promedio: 12-15%
💰 Ahorro en USD: ~$3-6 por transacción
```

### Técnicas Aplicadas:

✅ **State Variable Caching** - Una sola lectura de storage
✅ **Single SSTORE per Variable** - Una sola escritura
✅ **Unchecked Arithmetic** - Donde matemáticamente seguro
✅ **Memory Structs** - En lugar de storage pointers
✅ **No Emit Immutables** - No cachear valores constantes

---

## 🚀 Caso de Uso Real

### Usuario Promedio (10 operaciones/mes)

```
Operaciones:
- 5 depósitos ETH      → 5 × $31.95 = $159.75
- 3 depósitos USDC     → 3 × $12.24 = $36.72
- 2 retiros            → 2 × $8.70  = $17.40
────────────────────────────────────────────
TOTAL MES:                           $213.87

En gas bajo (30 gwei):              $128.32 💰 40% ahorro
En L2 (Polygon):                      $2.14 💰 99% ahorro
```

### Power User (50 operaciones/mes)

```
Operaciones:
- 25 depósitos ETH     → 25 × $31.95 = $798.75
- 15 depósitos USDC    → 15 × $12.24 = $183.60
- 10 retiros           → 10 × $8.70  = $87.00
────────────────────────────────────────────
TOTAL MES:                         $1,069.35

En gas bajo (30 gwei):              $641.61 💰 40% ahorro
En L2 (Polygon):                     $10.69 💰 99% ahorro
```

---

## 📖 Cómo Leer Este Reporte

### Símbolos

- 💸 = Operaciones de depósito
- 💵 = Operaciones de retiro
- ⚙️ = Operaciones de configuración
- 🛑 = Operaciones de pausa
- 🚨 = Operaciones de emergencia
- 👁️ = Funciones de consulta (view)
- 🟢 = Costo bajo (< $20)
- 🟡 = Costo medio ($20-$50)
- 🔴 = Costo alto (> $50)

### Términos

- **Gas:** Unidad de cómputo en Ethereum
- **gwei:** 1 gwei = 0.000000001 ETH (10^-9)
- **SLOAD:** Operación de lectura de storage (~2,100 gas)
- **SSTORE:** Operación de escritura de storage (~5,000-22,100 gas)
- **View function:** Función que solo lee (gratis fuera de tx)

---

## 🔗 Recursos

- **Monitorear Gas en Tiempo Real:**
  - https://etherscan.io/gastracker
  - https://ultrasound.money/#gas

- **Ejecutar Análisis Local:**
  ```bash
  forge test --gas-report
  ./test-gas.sh
  ```

- **Documentación Completa:**
  - [GAS_ANALYSIS.md](GAS_ANALYSIS.md) - Análisis detallado

---

## 📝 Notas Finales

1. **Costos son estimaciones** - Pueden variar ±5-10% según estado de la red
2. **View functions SON GRATIS** cuando se usan para consultar (no en tx)
3. **Uniswap swap domina el costo** - ~75% del gas en depósitos con swap
4. **Depositar USDC ahorra 67%** vs depositar otros tokens
5. **Gas price varía mucho** - Monitorear antes de hacer operaciones grandes

---

**💡 Tip Final:** Para operaciones grandes (>$1000), espera a gas < 30 gwei. El ahorro puede ser > $20 por transacción.

---

**Versión:** 1.0.0
**Última Actualización:** 2025-11-09
**Generado por:** KipuBankV3 Gas Analyzer
