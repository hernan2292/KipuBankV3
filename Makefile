# KipuBankV3 Makefile
# Simplifies common development tasks

.PHONY: help install build test coverage deploy-sepolia deploy-mainnet verify clean format lint

# Default target
help:
	@echo "KipuBankV3 - Makefile Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make install          Install dependencies"
	@echo ""
	@echo "Development:"
	@echo "  make build            Compile contracts"
	@echo "  make test             Run all tests"
	@echo "  make test-v           Run tests with verbose output"
	@echo "  make coverage         Generate coverage report"
	@echo "  make format           Format code with forge fmt"
	@echo "  make lint             Run linter (slither)"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-sepolia   Deploy to Sepolia testnet"
	@echo "  make deploy-mainnet   Deploy to Mainnet (WARNING: real ETH)"
	@echo "  make verify           Verify contract on Etherscan"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean            Clean build artifacts"
	@echo "  make gas-report       Generate gas usage report"

# Install dependencies
install:
	@echo "Installing Foundry dependencies..."
	forge install OpenZeppelin/openzeppelin-contracts --no-commit
	forge install smartcontractkit/chainlink --no-commit
	forge install foundry-rs/forge-std --no-commit
	@echo "Dependencies installed!"

# Build contracts
build:
	@echo "Building contracts..."
	forge build

# Run tests
test:
	@echo "Running tests..."
	forge test

# Run tests with verbose output
test-v:
	@echo "Running tests (verbose)..."
	forge test -vvv

# Run specific test
test-%:
	@echo "Running test: $*"
	forge test --match-test $* -vvv

# Generate coverage report
coverage:
	@echo "Generating coverage report..."
	forge coverage
	@echo ""
	@echo "For detailed HTML report, run:"
	@echo "  forge coverage --report lcov"
	@echo "  genhtml lcov.info --output-directory coverage"

# Gas report
gas-report:
	@echo "Generating gas report..."
	forge test --gas-report

# Format code
format:
	@echo "Formatting code..."
	forge fmt

# Run static analysis
lint:
	@echo "Running Slither..."
	@command -v slither >/dev/null 2>&1 || { echo "Slither not installed. Install with: pip install slither-analyzer"; exit 1; }
	slither src/KipuBankV3.sol

# Deploy to Sepolia
deploy-sepolia:
	@echo "Deploying to Sepolia..."
	@test -f .env || { echo "Error: .env file not found"; exit 1; }
	forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
		--rpc-url sepolia \
		--broadcast \
		--verify

# Deploy to Mainnet (WARNING)
deploy-mainnet:
	@echo "WARNING: Deploying to MAINNET with real ETH!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	forge script script/DeployKipuBankV3.s.sol:DeployKipuBankV3 \
		--rpc-url mainnet \
		--broadcast \
		--verify

# Verify contract
verify:
	@echo "Usage: make verify CONTRACT=0xYourContractAddress NETWORK=sepolia"
	@test -n "$(CONTRACT)" || { echo "Error: CONTRACT address not provided"; exit 1; }
	@test -n "$(NETWORK)" || { echo "Error: NETWORK not provided (sepolia/mainnet)"; exit 1; }
	forge verify-contract \
		--chain-id $$([ "$(NETWORK)" = "mainnet" ] && echo 1 || echo 11155111) \
		--compiler-version 0.8.30 \
		--num-of-optimizations 200 \
		$(CONTRACT) \
		src/KipuBankV3.sol:KipuBankV3

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	forge clean
	rm -rf cache out

# Snapshot gas usage
snapshot:
	@echo "Creating gas snapshot..."
	forge snapshot

# Run fork tests
fork-test:
	@echo "Running fork tests on Mainnet..."
	forge test --fork-url mainnet

# Local node
anvil:
	@echo "Starting local Anvil node..."
	anvil

# Interactive console
console:
	@echo "Starting Foundry console..."
	forge console

# Update dependencies
update:
	@echo "Updating dependencies..."
	forge update
