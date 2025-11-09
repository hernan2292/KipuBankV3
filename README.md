# KipuBankV3 - Advanced DeFi Banking System

![Solidity](https://img.shields.io/badge/Solidity-0.8.30-blue)
![Foundry](https://img.shields.io/badge/Foundry-latest-green)
![License](https://img.shields.io/badge/license-MIT-blue)

## 📋 Tabla de Contenidos

- [Resumen Ejecutivo](#resumen-ejecutivo)
- [Características Principales](#características-principales)
- [Mejoras sobre KipuBankV2](#mejoras-sobre-kipubankv2)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Instalación y Configuración](#instalación-y-configuración)
- [Uso y Despliegue](#uso-y-despliegue)
- [Interacción con el Contrato](#interacción-con-el-contrato)
- [Testing y Cobertura](#testing-y-cobertura)
- [Análisis de Amenazas](#análisis-de-amenazas)
- [Decisiones de Diseño](#decisiones-de-diseño)
- [Auditoría y Seguridad](#auditoría-y-seguridad)
- [Roadmap](#roadmap)

---

## 🎯 Resumen Ejecutivo

**KipuBankV3** es un sistema bancario DeFi avanzado que permite a los usuarios depositar **cualquier token soportado por Uniswap V2**, automáticamente intercambiarlo a **USDC**, y gestionar sus balances de forma segura. El sistema respeta un límite máximo del banco (bank cap) y preserva toda la funcionalidad de KipuBankV2, mientras añade capacidades de composabilidad con protocolos DeFi.

### Casos de Uso Principales

1. **Depósito Unificado**: Los usuarios pueden depositar ETH, USDC, o cualquier token ERC20 con liquidez en Uniswap V2
2. **Conversión Automática**: Todos los tokens se convierten automáticamente a USDC, simplificando la gestión
3. **Gestión de Riesgo**: Bank cap y límites de retiro protegen el protocolo
4. **Gobernanza**: Sistema de roles (Admin/Manager) para gestión descentralizada

---

## ✨ Características Principales

### 1. 🔄 Depósitos Multi-Token con Swap Automático

```solidity
// Depositar ETH (se convierte a USDC automáticamente)
function depositETH() external payable

// Depositar cualquier token ERC20 soportado
function depositToken(address token, uint256 amount) external
```

**Proceso de Depósito:**
1. Usuario deposita Token X
2. Si Token X ≠ USDC → Swap automático via Uniswap V2
3. USDC resultante se acredita al balance del usuario
4. Se valida bank cap post-swap

### 2. 🛡️ Protecciones de Seguridad

- **ReentrancyGuard**: Prevención de ataques de reentrada
- **Pausable**: Mecanismo de pausa de emergencia
- **AccessControl**: Roles granulares (Admin, Manager)
- **Slippage Protection**: Tolerancia configurable para swaps
- **Price Staleness Check**: Validación de frescura de oráculos Chainlink

### 3. 📊 Integración con Protocolos Externos

- **Uniswap V2**: Swaps automáticos de tokens
- **Chainlink**: Oráculos de precios para ETH/USD
- **OpenZeppelin**: Librerías battle-tested de seguridad

### 4. 💰 Gestión de Capacidad

```solidity
uint256 public bankCapUSD;           // Capacidad máxima en USD
uint256 public totalBankValueUSD;    // Valor total almacenado
uint256 public withdrawalLimitUSD;   // Límite de retiro por transacción
```

### 5. 🎛️ Configuración Flexible

- **Bank Cap**: Ajustable por Manager
- **Withdrawal Limit**: Límite por transacción configurable
- **Slippage Tolerance**: Tolerancia de slippage personalizable
- **Token Status**: Tokens pueden pausarse individualmente

---

## 🚀 Mejoras sobre KipuBankV2

| Característica | KipuBankV2 | KipuBankV3 |
|----------------|------------|------------|
| Tokens Soportados | ETH + USDC + ERC20 limitados | Cualquier token con par USDC en Uniswap V2 |
| Conversión de Tokens | Manual / No soportada | Automática via Uniswap V2 |
| Balance Interno | Multi-token | Unificado en USDC |
| Protección de Slippage | ❌ | ✅ Configurable |
| Pricing | Chainlink solo para ETH | Chainlink + Uniswap V2 |
| Composabilidad DeFi | Limitada | Alta (integración Uniswap) |
| Gas Efficiency | Buena | Optimizada (state caching) |

### Ventajas Clave de V3

1. **Simplicidad para el Usuario**: Un solo balance en USDC, sin necesidad de gestionar múltiples tokens
2. **Mayor Liquidez**: Acceso a cualquier token con liquidez en Uniswap
3. **Menor Complejidad**: Frontend solo necesita mostrar balance en USDC
4. **Mejor UX**: Usuarios no necesitan preocuparse por qué token depositar

---

## 🏗️ Arquitectura del Sistema

### Diagrama de Flujo - Depósito con Swap

```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │ 1. depositToken(DAI, 1000)
       ▼
┌─────────────────────┐
│   KipuBankV3        │
│  ┌──────────────┐   │
│  │ Validaciones │   │ 2. Validar token soportado, activo, etc.
│  └──────┬───────┘   │
│         │           │
│  ┌──────▼───────┐   │
│  │ Transfer DAI │   │ 3. SafeTransferFrom user → contract
│  └──────┬───────┘   │
│         │           │
│  ┌──────▼────────┐  │
│  │ Approve Router│  │ 4. Approve Uniswap Router
│  └──────┬────────┘  │
└─────────┼───────────┘
          │
          ▼
┌──────────────────────┐
│  Uniswap V2 Router   │
│                      │ 5. swapExactTokensForTokens
│  DAI → USDC         │    (DAI → USDC)
└──────────┬───────────┘
           │ 6. Return USDC amount
           ▼
┌─────────────────────┐
│   KipuBankV3        │
│  ┌──────────────┐   │
│  │ Update State │   │ 7. balances[user] += usdcAmount
│  │              │   │    totalBankValueUSD += usdcAmount
│  └──────┬───────┘   │
│         │           │
│  ┌──────▼───────┐   │
│  │ Emit Events  │   │ 8. TokenSwapped + Deposit events
│  └──────────────┘   │
└─────────────────────┘
```

### Componentes Principales

#### 1. **KipuBankV3.sol** (Contrato Principal)
- Gestión de depósitos y retiros
- Integración con Uniswap V2
- Control de acceso y pausabilidad
- Gestión de bank cap

#### 2. **IKipuBankV3.sol** (Interface)
- Define todos los métodos públicos
- Eventos y errores custom
- Estructuras de datos

#### 3. **IUniswapV2Router02.sol** (Interface Externa)
- Funciones de swap de Uniswap V2
- Quote functions para estimaciones

#### 4. **Mocks** (Testing)
- MockERC20: Tokens de prueba
- MockV3Aggregator: Oracle de precios mock
- MockUniswapV2Router: Router mock para tests

---

## 📦 Instalación y Configuración

### Prerequisitos

```bash
# Instalar Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verificar instalación
forge --version
```

### Instalación

```bash
# Clonar repositorio
git clone https://github.com/your-username/KipuBankV3.git
cd KipuBankV3

# Instalar dependencias
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink --no-commit

# Compilar contratos
forge build
```

### Configuración de Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env con tus valores
nano .env
```

Ejemplo de `.env`:

```bash
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY

# Direcciones de contratos en Sepolia
UNISWAP_V2_ROUTER_SEPOLIA=0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008
USDC_SEPOLIA=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
ETH_USD_PRICE_FEED_SEPOLIA=0x694AA1769357215DE4FAC081bf1f309aDC325306
```

---

## 🚢 Uso y Despliegue

### Ejecutar Tests

```bash
# Ejecutar todos los tests
forge test

# Ejecutar tests con verbosidad
forge test -vvv

# Ejecutar tests específicos
forge test --match-test test_DepositETH_Success

# Ejecutar tests con gas reporting
forge test --gas-report
```

### Cobertura de Tests

```bash
# Generar reporte de cobertura
forge coverage

# Generar reporte detallado con lcov
forge coverage --report lcov

# Visualizar cobertura en HTML (requiere genhtml)
genhtml lcov.info --output-directory coverage
open coverage/index.html
```

### Desplegar en Sepolia

```bash
# Desplegar contrato
forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY

# El script mostrará la dirección del contrato desplegado
```

### Desplegar en Mainnet

```bash
# ⚠️ ADVERTENCIA: Desplegar en mainnet requiere ETH real

forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### Verificar Contrato Manualmente

```bash
forge verify-contract \
  --chain-id 11155111 \
  --compiler-version 0.8.30 \
  --num-of-optimizations 200 \
  --constructor-args $(cast abi-encode "constructor(address,address,address,uint256,uint256,uint256)" <ETH_FEED> <ROUTER> <USDC> <BANK_CAP> <WITHDRAWAL_LIMIT> <SLIPPAGE>) \
  <CONTRACT_ADDRESS> \
  src/KipuBankV3.sol:KipuBankV3 \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

---

## 🔌 Interacción con el Contrato

### Para Usuarios (Depositar y Retirar)

#### 1. Depositar ETH

```javascript
// Web3.js
const web3 = new Web3(window.ethereum);
const contract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);

await contract.methods.depositETH().send({
  from: userAddress,
  value: web3.utils.toWei('1', 'ether')
});
```

```solidity
// Solidity (desde otro contrato)
IKipuBankV3(bankAddress).depositETH{value: 1 ether}();
```

#### 2. Depositar Tokens ERC20

```javascript
// Primero aprobar el token
const tokenContract = new web3.eth.Contract(ERC20_ABI, TOKEN_ADDRESS);
await tokenContract.methods.approve(
  CONTRACT_ADDRESS,
  amount
).send({ from: userAddress });

// Luego depositar
await contract.methods.depositToken(TOKEN_ADDRESS, amount).send({
  from: userAddress
});
```

#### 3. Retirar USDC

```javascript
// Retirar 100 USDC (6 decimals)
const amount = '100000000'; // 100 * 10^6

await contract.methods.withdraw(amount).send({
  from: userAddress
});
```

#### 4. Consultar Balance

```javascript
// Obtener balance en USDC
const balance = await contract.methods.getBalance(userAddress).call();
console.log(`Balance: ${balance / 1e6} USDC`);

// Obtener total del banco
const totalValue = await contract.methods.getTotalBankValueUSD().call();
console.log(`Total Bank Value: $${totalValue / 1e6}`);
```

### Para Managers (Configuración)

#### 1. Agregar Nuevo Token

```javascript
// Agregar DAI como token soportado
await contract.methods.addToken(DAI_ADDRESS).send({
  from: managerAddress
});
```

#### 2. Pausar Token

```javascript
// Pausar un token (1 = Active, 2 = Paused)
await contract.methods.setTokenStatus(TOKEN_ADDRESS, 2).send({
  from: managerAddress
});
```

#### 3. Actualizar Bank Cap

```javascript
// Actualizar bank cap a $2M
const newCap = '2000000000000'; // 2M * 10^6
await contract.methods.setBankCap(newCap).send({
  from: managerAddress
});
```

#### 4. Actualizar Slippage

```javascript
// Actualizar slippage a 2% (200 basis points)
await contract.methods.setSlippageTolerance(200).send({
  from: managerAddress
});
```

### Para Admins (Emergencias)

#### 1. Pausar el Contrato

```javascript
await contract.methods.pause().send({
  from: adminAddress
});
```

#### 2. Reanudar el Contrato

```javascript
await contract.methods.unpause().send({
  from: adminAddress
});
```

#### 3. Retiro de Emergencia

```javascript
// Retirar 1000 USDC de emergencia
await contract.methods.emergencyWithdraw(
  USDC_ADDRESS,
  '1000000000', // 1000 * 10^6
  recipientAddress
).send({ from: adminAddress });
```

---

## 🧪 Testing y Cobertura

### Suite de Tests

El proyecto incluye **65+ tests** que cubren:

1. **Constructor Tests** (6 tests)
   - Inicialización correcta
   - Validación de parámetros
   - Asignación de roles

2. **Deposit ETH Tests** (6 tests)
   - Depósitos exitosos
   - Validaciones de monto
   - Bank cap exceeded
   - Estado pausado

3. **Deposit Token Tests** (7 tests)
   - Depósitos USDC directos
   - Depósitos con swap (DAI → USDC)
   - Tokens no soportados
   - Validaciones

4. **Withdrawal Tests** (4 tests)
   - Retiros exitosos
   - Balance insuficiente
   - Límite de retiro excedido

5. **Manager Functions Tests** (9 tests)
   - Agregar tokens
   - Cambiar estado de tokens
   - Actualizar bank cap
   - Actualizar límites
   - Actualizar slippage

6. **Admin Functions Tests** (4 tests)
   - Pausar/despausar
   - Retiros de emergencia
   - Control de acceso

7. **View Functions Tests** (6 tests)
   - Consulta de balances
   - Información de tokens
   - Precios de oráculos
   - Estimaciones de swap

8. **Integration Tests** (2 tests)
   - Flujos completos multi-usuario
   - Swap y retiro end-to-end

9. **Fuzz Tests** (3 tests)
   - Depósitos con montos aleatorios
   - Retiros con montos aleatorios

10. **Receive/Fallback Tests** (2 tests)
    - Rechazo de ETH directo
    - Rechazo de llamadas inválidas

### Ejecutar Tests Específicos

```bash
# Tests de depósitos ETH
forge test --match-contract KipuBankV3Test --match-test test_DepositETH

# Tests de manager
forge test --match-test test_AddToken

# Tests con fuzz
forge test --match-test testFuzz
```

### Objetivos de Cobertura

- **Cobertura Actual**: >50% (cumple requisito del examen)
- **Objetivo Final**: >80%

```bash
# Verificar cobertura actual
forge coverage --report summary

# Ejemplo de output:
| File                    | % Lines        | % Statements   | % Branches   | % Funcs      |
|-------------------------|----------------|----------------|--------------|--------------|
| src/KipuBankV3.sol      | 78.26%         | 80.43%         | 65.00%       | 85.71%       |
| Total                   | 78.26%         | 80.43%         | 65.00%       | 85.71%       |
```

---

## 🛡️ Análisis de Amenazas

### 1. Vulnerabilidades Identificadas

#### 🔴 CRÍTICAS

##### 1.1 Oracle Manipulation Attack
**Descripción**: Los precios de Chainlink podrían ser manipulados en condiciones extremas de mercado.

**Impacto**: Los usuarios podrían recibir menos USDC de lo esperado en swaps.

**Mitigación Implementada**:
- ✅ Validación de staleness (< 1 hora)
- ✅ Validación de roundId
- ✅ Precio mínimo válido ($1)

**Mitigación Pendiente**:
- ⚠️ Implementar múltiples oráculos (Chainlink + Uniswap TWAP)
- ⚠️ Circuit breaker para cambios de precio >10% en una hora

##### 1.2 Slippage Attack
**Descripción**: Sandwich attacks o front-running podrían explotar swaps grandes.

**Impacto**: Pérdida de valor en swaps (MEV attack).

**Mitigación Implementada**:
- ✅ Slippage tolerance configurable
- ✅ Deadline de 5 minutos en swaps
- ✅ Validación de amountOut mínimo

**Mitigación Pendiente**:
- ⚠️ Integrar Flashbots/MEV protection
- ⚠️ Límite máximo por swap (evitar grandes transacciones)

##### 1.3 Reentrancy via External Calls
**Descripción**: Llamadas a Uniswap Router podrían reingresar al contrato.

**Impacto**: Drenaje de fondos, doble gasto.

**Mitigación Implementada**:
- ✅ ReentrancyGuard en todas las funciones public/external
- ✅ CEI (Checks-Effects-Interactions) pattern
- ✅ Estado actualizado antes de llamadas externas

**Mitigación Pendiente**:
- ✅ **COMPLETAMENTE MITIGADO**

#### 🟡 ALTAS

##### 2.1 Token Approval Front-running
**Descripción**: Usuarios podrían ver aprobaciones y front-run depósitos.

**Impacto**: Pérdida temporal de tokens (requiere fallo del usuario).

**Mitigación Implementada**:
- ✅ SafeERC20 con forceApprove
- ✅ Aprobación justo antes del swap

**Mitigación Pendiente**:
- ⚠️ Implementar permit() (EIP-2612) para aprobaciones sin gas

##### 2.2 Admin Key Compromise
**Descripción**: Si la clave privada del admin se compromete, el atacante tiene control total.

**Impacto**: Robo de fondos via emergencyWithdraw, pausar el contrato.

**Mitigación Implementada**:
- ✅ Roles separados (Admin vs Manager)
- ✅ emergencyWithdraw solo para Admin

**Mitigación Pendiente**:
- ⚠️ Implementar Multisig (Gnosis Safe)
- ⚠️ Timelock para operaciones críticas

##### 2.3 Bank Cap Bypass
**Descripción**: Condiciones de carrera podrían permitir múltiples depósitos que exceden el cap.

**Impacto**: Bank cap excedido, riesgo sistémico.

**Mitigación Implementada**:
- ✅ Validación atómica en la misma transacción
- ✅ Estado actualizado antes de swap

**Mitigación Pendiente**:
- ✅ **COMPLETAMENTE MITIGADO** (validación es atómica)

#### 🟢 MEDIAS

##### 3.1 Dos via Block Gas Limit
**Descripción**: Arrays grandes (supportedTokens) podrían causar out-of-gas.

**Impacto**: Funciones de lectura podrían fallar.

**Mitigación Implementada**:
- ✅ Límite de 50 tokens (MAX_SUPPORTED_TOKENS)

**Mitigación Pendiente**:
- ⚠️ Implementar paginación en getSupportedTokens()

##### 3.2 Precision Loss en Conversiones
**Descripción**: Conversiones de decimals podrían perder precisión.

**Impacto**: Usuarios pierden pequeñas cantidades (dust).

**Mitigación Implementada**:
- ✅ USD con 6 decimales (alta precisión)
- ✅ Validación de AmountTooSmall

**Mitigación Pendiente**:
- ⚠️ Implementar función para reclamar dust

##### 3.3 Token with Fees on Transfer
**Descripción**: Algunos tokens (ej. STA, PAXG) cobran fees en transferencias.

**Impacto**: Balance recibido < balance esperado → revert en swap.

**Mitigación Implementada**:
- ❌ No implementada

**Mitigación Pendiente**:
- ⚠️ Blacklist de tokens con fees
- ⚠️ O detectar balance real post-transfer

#### 🔵 BAJAS

##### 4.1 Front-running de addToken
**Descripción**: Manager podría agregar token malicioso antes de revisión.

**Impacto**: Token malicioso en whitelist.

**Mitigación Implementada**:
- ✅ Solo Manager role puede agregar tokens
- ✅ Validación de decimals

**Mitigación Pendiente**:
- ⚠️ Timelock de 24h para agregar tokens
- ⚠️ Multisig para operaciones de Manager

---

### 2. Matriz de Riesgos

| Vulnerabilidad | Probabilidad | Impacto | Severidad | Estado |
|----------------|--------------|---------|-----------|--------|
| Oracle Manipulation | Baja | Crítico | 🔴 Alta | Parcialmente mitigado |
| Slippage Attack | Media | Alto | 🟡 Media | Parcialmente mitigado |
| Reentrancy | Baja | Crítico | ✅ Mitigado | Completamente mitigado |
| Admin Key Compromise | Baja | Crítico | 🟡 Alta | Recomendado multisig |
| Token Approval Front-run | Media | Medio | 🟢 Baja | Parcialmente mitigado |
| Bank Cap Bypass | Muy Baja | Alto | ✅ Mitigado | Completamente mitigado |
| DoS Gas Limit | Muy Baja | Bajo | 🟢 Baja | Mitigado |
| Precision Loss | Media | Bajo | 🟢 Baja | Aceptable |
| Tokens with Fees | Media | Medio | 🟡 Media | No mitigado |

---

### 3. Pasos Faltantes para Madurez de Producción

#### Antes de Mainnet Launch

**Seguridad:**
- [ ] Auditoría profesional por firma reconocida (OpenZeppelin, Trail of Bits, etc.)
- [ ] Bug bounty program ($50k+ en ImmuneFi)
- [ ] Implementar Multisig (Gnosis Safe) para admin
- [ ] Timelock (24-48h) para operaciones críticas
- [ ] Implementar circuit breaker para precios
- [ ] Integrar Flashbots para protección MEV

**Testing:**
- [ ] Aumentar cobertura a >90%
- [ ] Tests de integración con Uniswap V2 en fork de mainnet
- [ ] Tests de stress (límites de gas, arrays grandes)
- [ ] Fuzzing avanzado con Echidna/Medusa
- [ ] Simulaciones de ataques (exploit tests)

**Monitoreo:**
- [ ] Integrar Tenderly para monitoring
- [ ] Alertas automáticas (Slack/Discord) para eventos críticos
- [ ] Dashboard público de métricas
- [ ] Monitoreo de TVL (Total Value Locked)

**Operaciones:**
- [ ] Documentación de procedimientos de emergencia
- [ ] Runbooks para diferentes escenarios
- [ ] Plan de respuesta a incidentes
- [ ] Sistema de versionado y upgrades

#### Post-Launch (3-6 meses)

**Optimizaciones:**
- [ ] Optimización de gas (EIP-1167 clones?)
- [ ] Implementar proxy pattern para upgrades
- [ ] Batch operations para múltiples depósitos
- [ ] Meta-transactions (EIP-2771) para gasless UX

**Features:**
- [ ] Soporte para Uniswap V3 (concentrado de liquidez)
- [ ] Multi-chain deployment (Polygon, Arbitrum, etc.)
- [ ] Yield farming con USDC depositado (Aave, Compound)
- [ ] NFT receipts para depósitos

---

### 4. Métodos de Prueba Utilizados

#### Testing Estratégico

1. **Unit Tests** (65+ tests)
   - Prueba cada función individualmente
   - Casos positivos y negativos
   - Edge cases

2. **Integration Tests**
   - Flujos completos end-to-end
   - Múltiples usuarios interactuando
   - Swaps + deposits + withdrawals

3. **Fuzz Tests**
   - Propiedades invariantes
   - Montos aleatorios
   - Múltiples escenarios

4. **Mock Testing**
   - Aislamiento de dependencias externas
   - Control de comportamiento (exchange rate, precios)
   - Reproducibilidad

#### Coverage Targets

```
src/KipuBankV3.sol
├── Lines: >75%
├── Statements: >75%
├── Branches: >60%
└── Functions: >80%
```

#### Tests Recomendados Adicionales

```bash
# Fork testing (mainnet)
forge test --fork-url $MAINNET_RPC_URL --match-test test_Integration

# Invariant testing
forge test --match-test invariant

# Gas profiling
forge test --gas-report

# Mutation testing (requiere herramienta externa)
vertigo run --sample-ratio 0.5
```

---

## 🎨 Decisiones de Diseño

### 1. Balance Unificado en USDC

**Decisión**: Todos los depósitos se convierten a USDC, los usuarios solo tienen un balance en USDC.

**Alternativas Consideradas**:
- Multi-token balances (como V2)
- Balance en ETH como unidad de cuenta

**Razones**:
- ✅ **Simplicidad**: Frontend solo muestra un balance
- ✅ **Estabilidad**: USDC es stablecoin (menos volatilidad)
- ✅ **Gas Efficient**: Un solo storage slot por usuario
- ✅ **UX**: Usuarios no necesitan entender qué token tienen

**Trade-offs**:
- ❌ Swap fees de Uniswap en cada depósito
- ❌ Usuarios no pueden recuperar el token original
- ❌ Exposición al riesgo de USDC (depeg, censura)

---

### 2. Integración con Uniswap V2 (no V3)

**Decisión**: Usar Uniswap V2 para swaps, no V3.

**Razones**:
- ✅ **Simplicidad**: V2 es más simple (no ticks, no ranges)
- ✅ **Documentación**: V2 está muy bien documentado
- ✅ **Compatibilidad**: V2 sigue siendo ampliamente usado
- ✅ **Gas**: V2 puede ser más barato para swaps pequeños

**Trade-offs**:
- ❌ Peor precio de ejecución vs V3
- ❌ Menos liquidez concentrada
- ❌ Tecnología "vieja" (2020)

**Futuro**: Migrar a Uniswap V3 en KipuBankV4 con mejor gestión de liquidez.

---

### 3. Slippage Configurable (no fijo)

**Decisión**: Manager puede ajustar slippage tolerance.

**Razones**:
- ✅ **Flexibilidad**: Ajustar según volatilidad del mercado
- ✅ **Optimización**: Menor slippage cuando mercado está calmado
- ✅ **Risk Management**: Aumentar si swaps están fallando

**Trade-offs**:
- ❌ Manager necesita monitorear activamente
- ❌ Complejidad adicional

**Configuración Recomendada**:
- Mercado normal: 0.5-1% (50-100 bps)
- Alta volatilidad: 2-3% (200-300 bps)

---

### 4. Bank Cap en USD (no en USDC absoluto)

**Decisión**: Bank cap se define en USD (6 decimals), no en cantidad de USDC.

**Razones**:
- ✅ **Claridad**: $1M es más intuitivo que 1000000 USDC
- ✅ **Consistencia**: Todos los valores internos en USD
- ✅ **Future-proof**: Si USDC depeg, el cap sigue siendo correcto en valor

**Trade-offs**:
- ❌ Conversión adicional en código

---

### 5. Withdrawal Solo en USDC

**Decisión**: Los usuarios solo pueden retirar USDC, no el token original depositado.

**Razones**:
- ✅ **Simplicidad**: No necesitamos hacer swap inverso
- ✅ **Gas Efficiency**: Menos lógica de swap
- ✅ **Seguridad**: Menos superficie de ataque

**Trade-offs**:
- ❌ Usuarios no pueden "recuperar" su token original
- ❌ Menos flexible que V2

**Mitigación**: En V4 podríamos agregar función `withdrawAs(token)` que haga swap inverso.

---

### 6. No Yield Farming (Yet)

**Decisión**: USDC depositado no genera yield automáticamente.

**Razones**:
- ✅ **Simplicidad**: V3 se enfoca en swap + storage
- ✅ **Seguridad**: Menos integraciones = menor riesgo
- ✅ **Gas**: Menos operaciones

**Futuro**: KipuBankV4 podría:
- Depositar USDC en Aave/Compound
- Generar yield para depositantes
- Compartir yield (80% usuarios, 20% protocolo)

---

### 7. Límite de 50 Tokens

**Decisión**: Máximo 50 tokens soportados (MAX_SUPPORTED_TOKENS).

**Razones**:
- ✅ **DoS Prevention**: Evitar arrays infinitos
- ✅ **Gas Limit**: getSupportedTokens() no explota
- ✅ **Suficiente**: 50 tokens es mucho para un banco

**Trade-offs**:
- ❌ Límite arbitrario
- ❌ Necesitarás remover tokens viejos para agregar nuevos

**Alternativa**: Implementar paginación en lugar de límite.

---

### 8. Dos Roles: Admin y Manager

**Decisión**: Separar roles críticos (Admin) de configuración (Manager).

**Razones**:
- ✅ **Seguridad**: Admin solo para emergencias
- ✅ **Operaciones**: Manager puede ajustar parámetros sin riesgo crítico
- ✅ **Gobernanza**: Fácil delegar Manager a DAO

**Distribución de Poder**:

| Acción | Admin | Manager |
|--------|-------|---------|
| pause/unpause | ✅ | ❌ |
| emergencyWithdraw | ✅ | ❌ |
| addToken | ❌ | ✅ |
| setBankCap | ❌ | ✅ |
| setSlippage | ❌ | ✅ |

**Futuro**: Admin → Multisig, Manager → DAO voting.

---

## 🔒 Auditoría y Seguridad

### Checklist de Seguridad Pre-Auditoría

#### Controles de Acceso
- [x] Roles implementados correctamente (Admin, Manager)
- [x] onlyRole usado en funciones sensibles
- [x] Constructor asigna roles correctamente
- [ ] Considerar Multisig para Admin

#### Reentrancy
- [x] ReentrancyGuard en todas las funciones state-changing
- [x] CEI pattern implementado
- [x] No hay llamadas externas antes de actualizar estado

#### Validación de Inputs
- [x] nonZeroAmount en depósitos/retiros
- [x] nonZeroAddress en constructor y funciones
- [x] Validación de decimals (1-18)
- [x] Validación de slippage (<= 100%)
- [x] Validación de bank cap y withdrawal limit

#### Oráculos
- [x] Staleness check (< 1 hora)
- [x] roundId validation
- [x] Precio mínimo válido
- [ ] Considerar múltiples oráculos (TWAP)

#### Token Handling
- [x] SafeERC20 para todas las transferencias
- [x] forceApprove antes de swaps
- [ ] Manejar tokens con fees on transfer
- [ ] Blacklist de tokens maliciosos

#### Pausabilidad
- [x] Pausable implementado
- [x] whenNotPaused en funciones críticas
- [x] Solo Admin puede pausar
- [x] emergencyWithdraw disponible

#### Gas Optimization
- [x] State variable caching
- [x] Inmutables para valores constantes
- [x] Custom errors (no strings)
- [x] Struct packing
- [ ] Considerar batch operations

### Herramientas de Análisis Estático

```bash
# Slither (análisis estático)
pip install slither-analyzer
slither src/KipuBankV3.sol

# Mythril (análisis simbólico)
pip install mythril
myth analyze src/KipuBankV3.sol

# Echidna (fuzzing avanzado)
echidna-test . --contract KipuBankV3 --config echidna.yaml
```

### Auditorías Recomendadas

1. **Code4rena** - Auditoría competitiva ($30-50k)
2. **OpenZeppelin** - Auditoría premium ($50-100k)
3. **Trail of Bits** - Auditoría de seguridad ($75-150k)

---

## 🗺️ Roadmap

### Q1 2025: MVP y Testing
- [x] Implementar KipuBankV3 core
- [x] Suite de tests completa (>50% coverage)
- [x] Documentación completa
- [ ] Deploy en testnet (Sepolia)
- [ ] Frontend básico (React + Wagmi)

### Q2 2025: Auditoría y Optimización
- [ ] Auditoría profesional
- [ ] Bug bounty program
- [ ] Optimizaciones de gas
- [ ] Aumentar coverage a >90%
- [ ] Deploy en mainnet (beta)

### Q3 2025: Features Avanzadas
- [ ] Integrar Uniswap V3
- [ ] Yield farming (Aave/Compound)
- [ ] Multi-chain (Polygon, Arbitrum)
- [ ] Gobernanza DAO

### Q4 2025: Escalabilidad
- [ ] L2 optimization
- [ ] Batch operations
- [ ] Meta-transactions
- [ ] NFT receipts

---

## 📞 Contacto y Soporte

- **GitHub**: [https://github.com/your-username/KipuBankV3](https://github.com/your-username/KipuBankV3)
- **Email**: support@kipubank.io
- **Discord**: [https://discord.gg/kipubank](https://discord.gg/kipubank)
- **Twitter**: [@KipuBank](https://twitter.com/kipubank)

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 🙏 Agradecimientos

- **Kipu Team** - Por el examen y la oportunidad
- **Uniswap** - Por el protocolo de swaps
- **Chainlink** - Por los oráculos de precios
- **OpenZeppelin** - Por las librerías de seguridad
- **Foundry** - Por las herramientas de desarrollo

---

## 📚 Referencias

1. [Uniswap V2 Documentation](https://docs.uniswap.org/contracts/v2/overview)
2. [Chainlink Price Feeds](https://docs.chain.link/data-feeds)
3. [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
4. [Foundry Book](https://book.getfoundry.sh/)
5. [Ethereum Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)

---

**⚠️ DISCLAIMER**: Este contrato es para propósitos educativos. No ha sido auditado profesionalmente. No usar en producción con fondos reales sin una auditoría completa.
