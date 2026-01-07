.PHONY: build clean run test help

# Default target
.DEFAULT_GOAL := help

# Build for Intel Mac
build: ## Build the application for Intel Mac (x86_64)
	@echo "Building Pownin Assistant for Intel Mac..."
	swift build -c release --arch x86_64
	@echo "✓ Build completed"

# Build for development
build-debug: ## Build in debug mode
	@echo "Building in debug mode..."
	swift build --arch x86_64
	@echo "✓ Debug build completed"

# Run the application
run: ## Run the application
	@echo "Running Pownin Assistant..."
	swift run

# Run tests
test: ## Run tests
	@echo "Running tests..."
	swift test --arch x86_64

# Clean build artifacts
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf .build
	@echo "✓ Clean completed"

# Verify AI integration
verify-ai: ## Verify AI integration components
	@echo "Verifying AI integration..."
	@test -f PowninAssistant/Services/AIService.swift && echo "✓ AIService.swift found" || (echo "✗ AIService.swift not found" && exit 1)
	@grep -q "processMessage" PowninAssistant/Services/AIService.swift && echo "✓ processMessage method exists"
	@grep -q "gatherContext" PowninAssistant/Services/AIService.swift && echo "✓ gatherContext method exists"
	@grep -q "generateResponse" PowninAssistant/Services/AIService.swift && echo "✓ generateResponse method exists"
	@test -f PowninAssistant/Services/SystemMonitor.swift && echo "✓ SystemMonitor.swift found" || (echo "✗ SystemMonitor.swift not found" && exit 1)
	@grep -q "getCPUUsage" PowninAssistant/Services/SystemMonitor.swift && echo "✓ getCPUUsage method exists"
	@grep -q "getMemoryUsage" PowninAssistant/Services/SystemMonitor.swift && echo "✓ getMemoryUsage method exists"
	@test -f PowninAssistant/Services/ContextAnalyzer.swift && echo "✓ ContextAnalyzer.swift found" || (echo "✗ ContextAnalyzer.swift not found" && exit 1)
	@grep -q "analyzeConversation" PowninAssistant/Services/ContextAnalyzer.swift && echo "✓ analyzeConversation method exists"
	@echo "✓ All AI integration components verified"

# Check architecture
check-arch: ## Display system architecture information
	@echo "System Architecture Information:"
	@echo "================================"
	@uname -m
	@sw_vers 2>/dev/null || echo "Not on macOS"

# Package for distribution
package: build ## Create distribution package
	@echo "Creating distribution package..."
	@mkdir -p dist
	@cp -r .build/release/PowninAssistant dist/ 2>/dev/null || echo "Binary not found, run 'make build' first"
	@tar -czf PowninAssistant-Intel-Mac.tar.gz -C dist . 2>/dev/null && echo "✓ Package created: PowninAssistant-Intel-Mac.tar.gz" || echo "✗ Package creation failed"
	@rm -rf dist

# Display help
help: ## Display this help message
	@echo "Pownin Assistant - Makefile Commands"
	@echo "====================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Example: make build"
