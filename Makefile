.PHONY: build build-universal build-intel build-arm clean run test help

# Default target
.DEFAULT_GOAL := help

# Build Universal Binary (Intel + Apple Silicon)
build: build-universal ## Build Universal binary (default)

build-universal: ## Build Universal binary for both Intel and Apple Silicon
	@echo "Building Pownin Assistant Universal Binary..."
	@echo "Building for Intel (x86_64)..."
	swift build -c release --arch x86_64
	@echo "Building for Apple Silicon (arm64)..."
	swift build -c release --arch arm64
	@echo "Creating Universal Binary..."
	@mkdir -p .build/universal
	lipo -create \
		.build/arm64-apple-macosx/release/PowninAssistant \
		.build/x86_64-apple-macosx/release/PowninAssistant \
		-output .build/universal/PowninAssistant
	@echo "Verifying Universal Binary..."
	@lipo -info .build/universal/PowninAssistant
	@echo "✓ Universal build completed"

# Build for Intel Mac only
build-intel: ## Build for Intel Mac (x86_64) only
	@echo "Building Pownin Assistant for Intel Mac..."
	swift build -c release --arch x86_64
	@echo "✓ Intel build completed"

# Build for Apple Silicon only
build-arm: ## Build for Apple Silicon (arm64) only
	@echo "Building Pownin Assistant for Apple Silicon..."
	swift build -c release --arch arm64
	@echo "✓ Apple Silicon build completed"

# Build for development
build-debug: ## Build in debug mode (native architecture)
	@echo "Building in debug mode..."
	swift build
	@echo "✓ Debug build completed"

# Run the application
run: ## Run the application
	@echo "Running Pownin Assistant..."
	swift run

# Run tests
test: ## Run tests
	@echo "Running tests..."
	swift test

# Clean build artifacts
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf .build
	rm -rf dist
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
	@echo "Current architecture: $$(uname -m)"
	@sw_vers 2>/dev/null || echo "Not on macOS"
	@echo ""
	@if [ -f ".build/universal/PowninAssistant" ]; then \
		echo "Universal binary info:"; \
		lipo -info .build/universal/PowninAssistant; \
	fi

# Package for distribution
package: build-universal ## Create Universal distribution package
	@echo "Creating Universal distribution package..."
	@mkdir -p dist
	@cp .build/universal/PowninAssistant dist/
	@tar -czf PowninAssistant-macOS-Universal.tar.gz -C dist .
	@echo "✓ Package created: PowninAssistant-macOS-Universal.tar.gz"
	@rm -rf dist

# Package Intel only
package-intel: build-intel ## Create Intel-only distribution package
	@echo "Creating Intel distribution package..."
	@mkdir -p dist
	@cp .build/x86_64-apple-macosx/release/PowninAssistant dist/
	@tar -czf PowninAssistant-macOS-Intel.tar.gz -C dist .
	@echo "✓ Package created: PowninAssistant-macOS-Intel.tar.gz"
	@rm -rf dist

# Package Apple Silicon only
package-arm: build-arm ## Create Apple Silicon distribution package
	@echo "Creating Apple Silicon distribution package..."
	@mkdir -p dist
	@cp .build/arm64-apple-macosx/release/PowninAssistant dist/
	@tar -czf PowninAssistant-macOS-AppleSilicon.tar.gz -C dist .
	@echo "✓ Package created: PowninAssistant-macOS-AppleSilicon.tar.gz"
	@rm -rf dist

# Display help
help: ## Display this help message
	@echo "Pownin Assistant - Makefile Commands"
	@echo "====================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Example: make build-universal"
