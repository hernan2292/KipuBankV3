#!/bin/bash
# Quick test para verificar que todo pasa antes del deployment

echo "Ejecutando tests rápidos..."
forge test --match-test "test_DepositETH_RevertsOnBankCapExceeded|test_Withdraw_RevertsOnWithdrawalLimitExceeded" -vv

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Tests corregidos - Ahora ejecutando todos los tests..."
    forge test

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅✅✅ TODOS LOS TESTS PASARON ✅✅✅"
        echo ""
        echo "Listo para deployment!"
    fi
fi
