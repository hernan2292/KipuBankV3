# Guía de Testing - KipuBankV3

Esta guía te ayudará a ejecutar todos los tests y análisis de gas del proyecto.

---

## 📋 Prerequisitos

### 1. Instalar Foundry

```bash
# Instalar Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verificar instalación
forge --version
cast --version
anvil --version
```

---

## 🧪 Ejecutar Tests

### Tests Básicos

```bash
# Ejecutar todos los tests
forge test

# Output esperado:
# Running 65 tests for test/KipuBankV3.t.sol:KipuBankV3Test
# [PASS] test_AddToken_Success() (gas: 54432)
# [PASS] test_Constructor_Success() (gas: 1234567)
# ...
# Test result: ok. 65 passed; 0 failed; finished in 1.23s
```

### Tests con Verbosidad

```bash
# Nivel 1: Mostrar errores
forge test -v

# Nivel 2: Mostrar logs
forge test -vv

# Nivel 3: Mostrar stack traces
forge test -vvv

# Nivel 4: Mostrar setup traces
forge test -vvvv

# Nivel 5: Mostrar todo
forge test -vvvvv
```

### Tests Específicos

```bash
# Ejecutar solo tests de depósitos
forge test --match-test "Deposit"

# Ejecutar solo tests de retiros
forge test --match-test "Withdraw"

# Ejecutar un test específico
forge test --match-test "test_DepositETH_Success"

# Ejecutar tests que NO contengan un patrón
forge test --no-match-test "Fuzz"
```

### Tests por Contrato

```bash
# Ejecutar solo tests de KipuBankV3Test
forge test --match-contract KipuBankV3Test

# Ejecutar tests de múltiples contratos
forge test --match-contract "KipuBank|Mock"
```

---

## ⛽ Análisis de Gas

### Reporte Básico de Gas

```bash
# Generar reporte de gas
forge test --gas-report

# Output esperado:
# ╭─────────────────────────────────────────────────────────────╮
# │ KipuBankV3 contract                                         │
# ├─────────────────────────────┬─────────────────────────────┤
# │ Function Name               │ Gas                         │
# ├─────────────────────────────┼─────────────────────────────┤
# │ depositETH                  │ 213045                      │
# │ depositToken                │ 250123 / 81523              │
# │ withdraw                    │ 58234                       │
# │ ...                         │                             │
# ╰─────────────────────────────┴─────────────────────────────╯
```

### Reporte de Gas en Archivo

```bash
# Guardar reporte completo
forge test --gas-report > gas-report.txt

# Ver reporte
cat gas-report.txt

# O con paginación
less gas-report.txt
```

### Gas Snapshot

```bash
# Crear snapshot de gas
forge snapshot

# Esto crea .gas-snapshot con:
# test_DepositETH_Success() (gas: 213045)
# test_DepositToken_USDC_Success() (gas: 81523)
# ...

# Ver snapshot
cat .gas-snapshot

# Comparar con cambios
forge snapshot --diff

# Output muestra cambios:
# test_DepositETH_Success() (gas: 213045 → 210123) [-2922]
# test_Withdraw_Success() (gas: 58234 → 57123) [-1111]
```

### Gas con Diferentes Optimizaciones

```bash
# Sin optimizer
forge test --gas-report --no-optimizer

# Con optimizer (200 runs) - DEFAULT
forge test --gas-report --optimizer-runs 200

# Con optimizer (1000 runs) - Para production
forge test --gas-report --optimizer-runs 1000

# Con optimizer (1 run) - Para deployment barato
forge test --gas-report --optimizer-runs 1
```

---

## 📊 Coverage (Cobertura de Tests)

### Generar Reporte de Cobertura

```bash
# Cobertura básica
forge coverage

# Output esperado:
# ╭─────────────────────────────────────────────────────────╮
# │ File                    │ % Lines  │ % Statements │ ...│
# ├─────────────────────────┼──────────┼──────────────┼────┤
# │ src/KipuBankV3.sol      │ 78.26%   │ 80.43%       │... │
# │ Total                   │ 78.26%   │ 80.43%       │... │
# ╰─────────────────────────┴──────────┴──────────────┴────╯
```

### Cobertura Detallada con LCOV

```bash
# Generar archivo LCOV
forge coverage --report lcov

# Esto crea lcov.info

# Generar HTML (requiere lcov/genhtml)
genhtml lcov.info --output-directory coverage

# Abrir en browser
open coverage/index.html  # macOS
xdg-open coverage/index.html  # Linux
start coverage/index.html  # Windows
```

### Cobertura por Archivo

```bash
# Ver cobertura solo de KipuBankV3.sol
forge coverage --report summary --match-path "src/KipuBankV3.sol"

# Ver cobertura de tests específicos
forge coverage --match-test "Deposit"
```

---

## 🔍 Debugging

### Tests con Traces

```bash
# Ver traces de ejecución
forge test --match-test "test_DepositETH_Success" -vvvv

# Ver traces con opcodes
forge test --match-test "test_DepositETH_Success" --debug

# Esto abre debugger interactivo:
# - Enter: siguiente step
# - 'q': quit
# - 'c': continue
# - 'j/k': navegar stack
```

### Tests con Fork

```bash
# Ejecutar tests en fork de mainnet
forge test --fork-url $MAINNET_RPC_URL

# Ejecutar tests en fork de Sepolia
forge test --fork-url $SEPOLIA_RPC_URL

# Fork en block específico
forge test --fork-url $MAINNET_RPC_URL --fork-block-number 18000000
```

### Tests con Logs

```bash
# En tus tests, agregar:
# import "forge-std/console.sol";
# console.log("Balance:", balance);
# console.log("User:", user);

# Ejecutar con -vv para ver logs
forge test -vv
```

---

## 🚀 Script de Análisis Completo

Usa el script incluido para análisis completo:

```bash
# Hacer ejecutable
chmod +x test-gas.sh

# Ejecutar
./test-gas.sh

# Output:
# ======================================
#   KipuBankV3 - Análisis de Gas
# ======================================
#
# [1/5] Compilando contratos...
# ✓ Compilación exitosa
#
# [2/5] Ejecutando tests...
# ✓ Tests exitosos
#
# [3/5] Generando reporte de gas...
# ✓ Reporte generado: gas-report-full.txt
#
# [4/5] Generando snapshot de gas...
# ✓ Snapshot generado: .gas-snapshot
#
# [5/5] Resumen de Gas por Función
# ...
```

---

## 📈 Tests de Integración

### Test con Anvil (Local)

```bash
# Terminal 1: Iniciar Anvil
anvil

# Output:
# Listening on 127.0.0.1:8545
# Chain ID: 31337
# Available Accounts:
# (0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
# Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Terminal 2: Deploy y test
forge script script/DeployKipuBankV3.s.sol \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

### Test en Sepolia

```bash
# Asegúrate de tener .env configurado
source .env

# Ejecutar tests en fork de Sepolia
forge test --fork-url $SEPOLIA_RPC_URL -vv
```

---

## 🎯 Tests Específicos por Funcionalidad

### Tests de Depósitos

```bash
# Todos los tests de depósitos
forge test --match-test "Deposit" --gas-report

# Solo depósitos ETH
forge test --match-test "DepositETH" -vv

# Solo depósitos Token
forge test --match-test "DepositToken" -vv

# Tests de fuzz para depósitos
forge test --match-test "testFuzz_Deposit" -vv
```

### Tests de Retiros

```bash
# Todos los tests de retiros
forge test --match-test "Withdraw" --gas-report

# Con verbosidad
forge test --match-test "Withdraw" -vv
```

### Tests de Manager

```bash
# Funciones de manager
forge test --match-test "AddToken|SetToken|SetBank|SetWithdrawal|SetSlippage" --gas-report
```

### Tests de Admin

```bash
# Funciones de admin
forge test --match-test "Pause|Emergency" --gas-report
```

### Tests de View Functions

```bash
# Funciones view
forge test --match-test "GetBalance|GetTotal|GetSupported|GetToken|GetETH|GetExpected" -vv
```

---

## 🔄 Workflow de Desarrollo

### 1. Hacer Cambios al Código

```bash
# Editar src/KipuBankV3.sol
vim src/KipuBankV3.sol
```

### 2. Compilar y Verificar

```bash
# Compilar
forge build

# Verificar warnings
forge build --force 2>&1 | grep -i warning
```

### 3. Ejecutar Tests

```bash
# Tests básicos
forge test

# Si fallan, ejecutar con verbosidad
forge test -vvv
```

### 4. Verificar Gas

```bash
# Comparar gas antes/después
forge snapshot --diff
```

### 5. Verificar Cobertura

```bash
# Asegurar >= 50% coverage
forge coverage
```

### 6. Commit Cambios

```bash
git add .
git commit -m "feat: mejora X con ahorro de Y gas"
```

---

## 📊 Benchmarks Esperados

### Resultados Esperados de Tests

```
Running 65 tests for test/KipuBankV3.t.sol:KipuBankV3Test

Constructor Tests (6):
✓ test_Constructor_Success
✓ test_Constructor_GrantsRoles
✓ test_Constructor_AddsDefaultTokens
✓ test_Constructor_RevertsOnZeroAddress
✓ test_Constructor_RevertsOnInvalidBankCap
✓ test_Constructor_RevertsOnInvalidWithdrawalLimit

Deposit ETH Tests (6):
✓ test_DepositETH_Success (gas: 213045)
✓ test_DepositETH_MultipleDeposits
✓ test_DepositETH_RevertsOnZeroAmount
✓ test_DepositETH_RevertsWhenPaused
✓ test_DepositETH_RevertsOnBankCapExceeded

Deposit Token Tests (7):
✓ test_DepositToken_USDC_Success (gas: 81523)
✓ test_DepositToken_DAI_WithSwap (gas: 250123)
✓ test_DepositToken_RevertsOnZeroAmount
✓ test_DepositToken_RevertsOnTokenNotSupported
✓ test_DepositToken_RevertsOnNativeToken

... (resto de tests)

Test result: ok. 65 passed; 0 failed; finished in 2.34s
```

### Gas Esperado

```
Deployment Cost: 2,345,678 gas

Function Gas Costs:
- depositETH(): ~213,000 gas
- depositToken() [USDC]: ~81,500 gas
- depositToken() [swap]: ~250,000 gas
- withdraw(): ~58,000 gas
- addToken(): ~54,400 gas
- setBankCap(): ~11,200 gas
- setWithdrawalLimit(): ~11,200 gas
- pause(): ~10,200 gas
```

### Cobertura Esperada

```
src/KipuBankV3.sol:
- Lines: 78%+
- Statements: 80%+
- Branches: 65%+
- Functions: 85%+
```

---

## ❓ Troubleshooting

### Error: "forge: command not found"

```bash
# Reinstalar Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Error: "Failed to resolve imports"

```bash
# Instalar dependencias
forge install

# O manualmente:
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink --no-commit
```

### Error: "Stack too deep"

```bash
# Compilar con via-ir
forge build --via-ir

# O ajustar optimizer runs
forge build --optimizer-runs 1
```

### Tests Fallan Aleatoriamente

```bash
# Ejecutar con seed fijo
forge test --fuzz-seed 42

# Aumentar fuzz runs
forge test --fuzz-runs 1000
```

---

## 📚 Recursos Adicionales

- [Foundry Book](https://book.getfoundry.sh/)
- [Forge Testing Cheatsheet](https://github.com/dabit3/foundry-cheatsheet)
- [Foundry Discord](https://discord.gg/foundry)
- [GitHub Issues](https://github.com/foundry-rs/foundry/issues)

---

## ✅ Checklist de Testing

Antes de hacer deploy o PR:

- [ ] `forge build` compila sin errores
- [ ] `forge test` - todos los tests pasan
- [ ] `forge test --gas-report` - gas es razonable
- [ ] `forge coverage` - cobertura >= 50%
- [ ] `forge snapshot --diff` - cambios de gas son esperados
- [ ] `slither .` - sin vulnerabilidades críticas
- [ ] Tests de integración en fork pasan
- [ ] Documentación actualizada

---

**Happy Testing!** 🧪✨
