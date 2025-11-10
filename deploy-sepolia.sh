#!/bin/bash
# Script de deployment para Sepolia
# Uso: ./deploy-sepolia.sh

set -e

echo "=========================================="
echo "  KipuBankV3 - Deployment en Sepolia"
echo "=========================================="
echo ""

# Cargar variables de entorno
if [ -f .env ]; then
    source .env
    echo "✓ Variables de entorno cargadas"
else
    echo "❌ Error: Archivo .env no encontrado"
    exit 1
fi

# Validar que las variables existen
if [ -z "$SEPOLIA_RPC_URL" ]; then
    echo "❌ Error: SEPOLIA_RPC_URL no configurado"
    exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: PRIVATE_KEY no configurado"
    exit 1
fi

if [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "❌ Error: ETHERSCAN_API_KEY no configurado"
    exit 1
fi

echo ""
echo "Configuración:"
echo "- RPC: $SEPOLIA_RPC_URL"
echo "- Chain: Sepolia (ID: 11155111)"
echo ""

# Compilar contratos
echo "[1/3] Compilando contratos..."
forge build
if [ $? -ne 0 ]; then
    echo "❌ Error en compilación"
    exit 1
fi
echo "✓ Compilación exitosa"
echo ""

# Ejecutar tests
echo "[2/3] Ejecutando tests..."
forge test
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ ERROR: Tests fallaron"
    echo "❌ NO SE PUEDE DESPLEGAR con tests fallando"
    echo ""
    echo "Por favor revisa los errores arriba y corrígelos antes de desplegar."
    exit 1
fi
echo "✓ Todos los tests pasaron (49/49)"
echo ""

# Deploy
echo "[3/3] Desplegando en Sepolia..."
echo ""

forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    -vvv

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "  ✓ Deployment Exitoso!"
    echo "=========================================="
    echo ""
    echo "Próximos pasos:"
    echo "1. Copia la dirección del contrato del output"
    echo "2. URL de Etherscan:"
    echo "   https://sepolia.etherscan.io/address/<CONTRACT_ADDRESS>#code"
    echo ""
else
    echo ""
    echo "❌ Error en deployment"
    exit 1
fi
