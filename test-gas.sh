#!/bin/bash
# Script para ejecutar análisis de gas de KipuBankV3
# Uso: ./test-gas.sh

echo "======================================"
echo "  KipuBankV3 - Análisis de Gas"
echo "======================================"
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Compilar contrato
echo -e "${BLUE}[1/5] Compilando contratos...${NC}"
forge build
if [ $? -ne 0 ]; then
    echo "Error al compilar. Abortando."
    exit 1
fi
echo -e "${GREEN}✓ Compilación exitosa${NC}"
echo ""

# 2. Ejecutar tests
echo -e "${BLUE}[2/5] Ejecutando tests...${NC}"
forge test
if [ $? -ne 0 ]; then
    echo "Error en tests. Abortando."
    exit 1
fi
echo -e "${GREEN}✓ Tests exitosos${NC}"
echo ""

# 3. Generar reporte de gas
echo -e "${BLUE}[3/5] Generando reporte de gas...${NC}"
forge test --gas-report > gas-report-full.txt
echo -e "${GREEN}✓ Reporte generado: gas-report-full.txt${NC}"
echo ""

# 4. Generar snapshot de gas
echo -e "${BLUE}[4/5] Generando snapshot de gas...${NC}"
forge snapshot
echo -e "${GREEN}✓ Snapshot generado: .gas-snapshot${NC}"
echo ""

# 5. Mostrar resumen
echo -e "${BLUE}[5/5] Resumen de Gas por Función${NC}"
echo "======================================"
echo ""

# Parsear y mostrar funciones principales
echo -e "${YELLOW}DEPÓSITOS:${NC}"
grep -E "depositETH|depositToken" gas-report-full.txt | head -5
echo ""

echo -e "${YELLOW}RETIROS:${NC}"
grep -E "withdraw" gas-report-full.txt | head -3
echo ""

echo -e "${YELLOW}GESTIÓN:${NC}"
grep -E "addToken|setTokenStatus|setBankCap|setWithdrawalLimit|setSlippage" gas-report-full.txt | head -5
echo ""

echo -e "${YELLOW}ADMIN:${NC}"
grep -E "pause|unpause|emergencyWithdraw" gas-report-full.txt | head -5
echo ""

# Mostrar archivo de snapshot
echo "======================================"
echo -e "${GREEN}Snapshot guardado en: .gas-snapshot${NC}"
echo "Para comparar cambios futuros, usa:"
echo "  forge snapshot --diff"
echo ""

# Calcular costos en USD
echo "======================================"
echo -e "${BLUE}Cálculo de Costos (ETH = \$3000, Gas = 50 gwei)${NC}"
echo "======================================"
echo ""

# Función para calcular costo
calculate_cost() {
    local gas=$1
    local eth_price=3000
    local gas_price=50  # gwei

    # Convertir gwei a ETH y multiplicar por precio
    # gas * 50 gwei * 1e-9 (gwei to ETH) * 3000 USD/ETH
    cost=$(echo "scale=2; $gas * $gas_price * 0.000000001 * $eth_price" | bc)
    echo "$cost"
}

# Leer valores del snapshot si existe
if [ -f ".gas-snapshot" ]; then
    echo "Función                          | Gas      | Costo USD"
    echo "--------------------------------|----------|----------"

    while IFS=: read -r func gas; do
        # Limpiar espacios
        func=$(echo "$func" | xargs)
        gas=$(echo "$gas" | xargs)

        # Calcular costo
        if [[ "$gas" =~ ^[0-9]+$ ]]; then
            cost=$(calculate_cost $gas)
            printf "%-30s | %-8s | \$%-7s\n" "$func" "$gas" "$cost"
        fi
    done < .gas-snapshot
fi

echo ""
echo -e "${GREEN}✓ Análisis completo${NC}"
echo ""
echo "Archivos generados:"
echo "  - gas-report-full.txt  (reporte completo)"
echo "  - .gas-snapshot        (snapshot para comparaciones)"
echo ""
