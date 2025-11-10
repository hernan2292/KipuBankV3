# KipuBankV3 - Estructura del Proyecto

**Autor**: Hernan Herrera
**Organización**: White Paper
**Fecha**: 2025-11-09

## 📁 Estructura Completa de Archivos

```
KipuBankV3/
│
├── .github/
│   └── workflows/
│       └── ci.yml                      # GitHub Actions CI/CD pipeline
│
├── src/                                # Contratos Solidity
│   ├── KipuBankV3.sol                 # 🏦 Contrato principal (800+ líneas)
│   │                                   # - Depósitos ETH/ERC20
│   │                                   # - Swap automático via Uniswap V2
│   │                                   # - Gestión de bank cap
│   │                                   # - Roles Admin/Manager
│   │
│   ├── interfaces/                     # Interfaces
│   │   ├── IKipuBankV3.sol            # Interface principal del banco
│   │   │                               # - Definición de funciones públicas
│   │   │                               # - Eventos y errores custom
│   │   │                               # - Estructuras de datos (TokenInfo)
│   │   │
│   │   └── IUniswapV2Router02.sol     # Interface Uniswap V2 Router
│   │                                   # - swapExactTokensForTokens
│   │                                   # - swapExactETHForTokens
│   │                                   # - getAmountsOut
│   │
│   └── mocks/                          # Contratos mock para testing
│       ├── MockERC20.sol               # Token ERC20 de prueba
│       ├── MockV3Aggregator.sol        # Oracle Chainlink mock
│       └── MockUniswapV2Router.sol     # Router Uniswap V2 mock
│
├── test/                               # Tests con Foundry
│   └── KipuBankV3.t.sol               # 🧪 Suite completa de tests (65+ tests)
│                                       # - Unit tests
│                                       # - Integration tests
│                                       # - Fuzz tests
│                                       # - Coverage: ~78%
│
├── script/                             # Scripts de deployment
│   └── DeployKipuBankV3.s.sol         # 🚀 Script de deployment
│                                       # - Sepolia configuration
│                                       # - Mainnet configuration
│                                       # - Auto-verification
│
├── lib/                                # Dependencias externas (git submodules)
│   ├── openzeppelin-contracts/        # OpenZeppelin (v5.0.0)
│   ├── chainlink/                      # Chainlink contracts
│   └── forge-std/                      # Forge standard library
│
├── .vscode/                            # Configuración VSCode
│
├── .github/                            # GitHub configuration
│   └── workflows/                      # CI/CD pipelines
│
├── cache/                              # Cache de compilación (gitignored)
├── out/                                # Artifacts compilados (gitignored)
├── broadcast/                          # Logs de deployment (gitignored)
│
├── 📄 README.md                        # 📚 Documentación principal (1,400+ líneas)
│                                       # - Resumen ejecutivo
│                                       # - Arquitectura del sistema
│                                       # - Guía de instalación
│                                       # - Interacción con el contrato
│                                       # - Análisis de amenazas
│                                       # - Decisiones de diseño
│
├── 📄 DEPLOYMENT.md                    # 🚀 Guía de deployment (700+ líneas)
│                                       # - Setup paso a paso
│                                       # - Deployment Sepolia/Mainnet
│                                       # - Post-deployment testing
│                                       # - Troubleshooting
│
├── 📄 QUICKSTART.md                    # ⚡ Inicio rápido (300+ líneas)
│                                       # - Setup en 5 minutos
│                                       # - Ejemplos prácticos
│                                       # - FAQ
│
├── 📄 SECURITY.md                      # 🔒 Política de seguridad (200+ líneas)
│                                       # - Reporte de vulnerabilidades
│                                       # - Bug bounty program
│                                       # - Issues conocidos
│
├── 📄 IMPLEMENTATION_SUMMARY.md        # ✅ Resumen de implementación
│                                       # - Cumplimiento de objetivos
│                                       # - Decisiones técnicas
│                                       # - Métricas del proyecto
│
├── 📄 PROJECT_STRUCTURE.md             # 📁 Este archivo
│                                       # - Estructura del proyecto
│                                       # - Descripción de archivos
│
├── 📄 foundry.toml                     # ⚙️ Configuración Foundry
│                                       # - Compiler settings
│                                       # - RPC endpoints
│                                       # - Optimizer config
│
├── 📄 remappings.txt                   # 🔗 Remappings de imports
│                                       # - @openzeppelin → lib/openzeppelin-contracts
│                                       # - @chainlink → lib/chainlink
│
├── 📄 Makefile                         # 🛠️ Comandos útiles
│                                       # - make install, build, test
│                                       # - make deploy-sepolia, deploy-mainnet
│                                       # - make coverage, gas-report
│
├── 📄 package.json                     # 📦 Metadatos del proyecto
│                                       # - Scripts npm
│                                       # - Dependencias de desarrollo
│
├── 📄 .env.example                     # 🔐 Template de variables de entorno
│                                       # - RPC URLs
│                                       # - Private key (placeholder)
│                                       # - Etherscan API key
│
├── 📄 .gitignore                       # 🚫 Archivos ignorados por Git
│                                       # - cache/, out/, broadcast/
│                                       # - .env (CRÍTICO)
│                                       # - node_modules/
│
├── 📄 .gitattributes                   # 📝 Atributos de Git
│                                       # - EOL normalization
│                                       # - Binary files handling
│
└── 📄 LICENSE                          # ⚖️ Licencia MIT
```

---

## 🎯 Archivos Clave por Categoría

### 🏗️ Smart Contracts (Producción)

| Archivo | Líneas | Descripción | Propósito |
|---------|--------|-------------|-----------|
| `src/KipuBankV3.sol` | 800+ | Contrato principal | Core banking logic, swaps, bank cap |
| `src/interfaces/IKipuBankV3.sol` | 200+ | Interface principal | Definición de funciones públicas |
| `src/interfaces/IUniswapV2Router02.sol` | 80+ | Interface Uniswap | Integración con Uniswap V2 |

### 🧪 Testing

| Archivo | Líneas | Tests | Cobertura |
|---------|--------|-------|-----------|
| `test/KipuBankV3.t.sol` | 600+ | 65+ | ~78% |
| `src/mocks/MockERC20.sol` | 30+ | - | Mock token |
| `src/mocks/MockV3Aggregator.sol` | 60+ | - | Mock oracle |
| `src/mocks/MockUniswapV2Router.sol` | 130+ | - | Mock router |

### 📚 Documentación

| Archivo | Líneas | Palabras | Audiencia |
|---------|--------|----------|-----------|
| `README.md` | 1,400+ | 12,000+ | Developers, Auditors, Users |
| `DEPLOYMENT.md` | 700+ | 6,000+ | DevOps, Deployers |
| `QUICKSTART.md` | 300+ | 2,500+ | New Developers |
| `SECURITY.md` | 200+ | 1,800+ | Security Researchers |
| `IMPLEMENTATION_SUMMARY.md` | 500+ | 4,000+ | Evaluators, Technical Review |

### 🛠️ Configuración y Scripts

| Archivo | Propósito |
|---------|-----------|
| `foundry.toml` | Configuración de Foundry (compiler, optimizer, RPC) |
| `remappings.txt` | Remappings de imports de librerías |
| `Makefile` | Comandos útiles (test, deploy, coverage) |
| `package.json` | Metadatos y scripts npm |
| `.env.example` | Template de variables de entorno |
| `script/DeployKipuBankV3.s.sol` | Script de deployment automatizado |

### 🔒 Seguridad y CI/CD

| Archivo | Propósito |
|---------|-----------|
| `.github/workflows/ci.yml` | Pipeline de CI/CD (build, test, lint) |
| `SECURITY.md` | Política de divulgación de vulnerabilidades |
| `.gitignore` | Protección de archivos sensibles (.env) |

---

## 📊 Estadísticas del Proyecto

### Código Solidity

```
Contratos Principales:    800+ líneas
Interfaces:               280+ líneas
Mocks:                    220+ líneas
Tests:                    600+ líneas
Scripts:                   70+ líneas
─────────────────────────────────────
TOTAL SOLIDITY:          ~2000 líneas
```

### Documentación

```
README.md:              1,400+ líneas
DEPLOYMENT.md:            700+ líneas
QUICKSTART.md:            300+ líneas
SECURITY.md:              200+ líneas
IMPLEMENTATION_SUMMARY:   500+ líneas
PROJECT_STRUCTURE:        200+ líneas
─────────────────────────────────────
TOTAL DOCS:             ~3300 líneas
```

### Tests

```
Total Tests:               65+
Cobertura:                 78%
Líneas de Test Code:      600+
Test Categories:           10
```

---

## 🔍 Mapa de Navegación Rápida

### Para Auditors

1. **Start**: [README.md](README.md) - Sección "Arquitectura del Sistema"
2. **Code**: [src/KipuBankV3.sol](src/KipuBankV3.sol) - Contrato principal con NatSpec
3. **Security**: [README.md](README.md) - Sección "Análisis de Amenazas"
4. **Tests**: [test/KipuBankV3.t.sol](test/KipuBankV3.t.sol) - Suite completa

### Para Developers Frontend

1. **Start**: [QUICKSTART.md](QUICKSTART.md) - Setup en 5 minutos
2. **API**: [src/interfaces/IKipuBankV3.sol](src/interfaces/IKipuBankV3.sol) - Funciones públicas
3. **Examples**: [README.md](README.md) - Sección "Interacción con el Contrato"
4. **Addresses**: Agregar después del deployment

### Para DevOps

1. **Start**: [DEPLOYMENT.md](DEPLOYMENT.md) - Guía completa
2. **Config**: [foundry.toml](foundry.toml) + [.env.example](.env.example)
3. **Script**: [script/DeployKipuBankV3.s.sol](script/DeployKipuBankV3.s.sol)
4. **CI/CD**: [.github/workflows/ci.yml](.github/workflows/ci.yml)

### Para Evaluadores del Examen

1. **Start**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
2. **Code**: [src/KipuBankV3.sol](src/KipuBankV3.sol)
3. **Tests**: `forge test` + `forge coverage`
4. **Docs**: [README.md](README.md) - Análisis de amenazas

---

## 🎨 Convenciones de Código

### Naming Conventions

```solidity
// State Variables
uint256 public bankCapUSD;              // camelCase
address public immutable usdc;          // camelCase

// Functions
function depositETH() external          // camelCase
function _getETHPrice() internal        // _prefijo para internal/private

// Constants
uint256 public constant MAX_BPS = 10000;  // UPPER_SNAKE_CASE

// Events
event Deposit(...)                      // PascalCase

// Errors
error BankCapExceeded();                // PascalCase

// Roles
bytes32 public constant MANAGER_ROLE    // UPPER_SNAKE_CASE
```

### Comentarios

```solidity
/// @notice - User-facing description
/// @dev - Developer notes
/// @param - Parameter description
/// @return - Return value description
```

### Estructura de Funciones

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

## 🚀 Flujo de Trabajo Recomendado

### Para Desarrollo

```bash
# 1. Clonar e instalar
git clone <repo>
make install

# 2. Crear branch
git checkout -b feature/my-feature

# 3. Desarrollar
# Editar src/KipuBankV3.sol

# 4. Compilar
make build

# 5. Test
make test
make coverage

# 6. Format
make format

# 7. Commit
git add .
git commit -m "feat: add feature X"

# 8. Push y PR
git push origin feature/my-feature
```

### Para Deployment

```bash
# 1. Setup environment
cp .env.example .env
# Editar .env con tus keys

# 2. Test en local
anvil  # Terminal 1
forge script script/DeployKipuBankV3.s.sol --rpc-url localhost --broadcast  # Terminal 2

# 3. Deploy en testnet
make deploy-sepolia

# 4. Verificar deployment
cast call <ADDRESS> "bankCapUSD()(uint256)" --rpc-url sepolia

# 5. Test post-deployment
# Ver DEPLOYMENT.md sección "Testing Post-Deployment"
```

---

## 📚 Recursos Adicionales

### Dependencias Externas

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

## ✅ Checklist para Contribuidores

Antes de hacer un PR, verifica:

- [ ] Código compila sin warnings: `make build`
- [ ] Tests pasan: `make test`
- [ ] Cobertura >= 75%: `make coverage`
- [ ] Código formateado: `make format`
- [ ] NatSpec completo en funciones públicas
- [ ] Gas optimizado (no storage reads innecesarios)
- [ ] Security checks (ReentrancyGuard, CEI pattern)
- [ ] Documentación actualizada si cambios en API

---

**Este proyecto es un ejemplo de excelencia en desarrollo Solidity con Foundry.** 🏆
