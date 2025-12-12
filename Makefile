.PHONY: test/packages test/applications test help \
	test/DesignSystem test/Domain test/Application \
	test/Data test/Presentation test/Bootstrap \
	coverage/packages coverage/DesignSystem coverage/Domain \
	coverage/Application coverage/Data coverage/Presentation \
	coverage/Bootstrap

# Application schemes
APPS = ShiftScheduler Troop900UIShowcase

# iOS Simulator destination
SIMULATOR_DESTINATION = 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro Max'

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

help:
	@echo "Available targets:"
	@echo "  make test/packages     - Run tests for all Swift packages"
	@echo "  make test/applications - Run tests for all iOS applications"
	@echo "  make test             - Run all tests (packages + applications)"
	@echo ""
	@echo "Individual package test targets:"
	@echo "  make test/DesignSystem"
	@echo "  make test/Domain"
	@echo "  make test/Application"
	@echo "  make test/Data"
	@echo "  make test/Presentation"
	@echo "  make test/Bootstrap"
	@echo ""
	@echo "Coverage report targets:"
	@echo "  make coverage/packages     - Generate coverage reports for all Swift packages"
	@echo "  make coverage/DesignSystem - Generate coverage report for Troop900DesignSystem"
	@echo "  make coverage/Domain       - Generate coverage report for Troop900Domain"
	@echo "  make coverage/Application  - Generate coverage report for Troop900Application"
	@echo "  make coverage/Data         - Generate coverage report for Troop900Data"
	@echo "  make coverage/Presentation - Generate coverage report for Troop900Presentation"
	@echo "  make coverage/Bootstrap    - Generate coverage report for Troop900Bootstrap"

# Individual package test targets
test/DesignSystem:
	@echo "$(YELLOW)Testing Troop900DesignSystem...$(NC)"
	@cd ios/Packages/Troop900DesignSystem && \
	if swift test; then \
		echo "$(GREEN)✅ Troop900DesignSystem - Tests passed$(NC)"; \
	else \
		echo "$(RED)❌ Troop900DesignSystem - Tests failed$(NC)"; \
		exit 1; \
	fi

test/Domain:
	@echo "$(YELLOW)Testing Troop900Domain...$(NC)"
	@cd ios/Packages/Troop900Domain && \
	if swift test; then \
		echo "$(GREEN)✅ Troop900Domain - Tests passed$(NC)"; \
	else \
		echo "$(RED)❌ Troop900Domain - Tests failed$(NC)"; \
		exit 1; \
	fi

test/Application:
	@echo "$(YELLOW)Testing Troop900Application...$(NC)"
	@cd ios/Packages/Troop900Application && \
	if swift test; then \
		echo "$(GREEN)✅ Troop900Application - Tests passed$(NC)"; \
	else \
		echo "$(RED)❌ Troop900Application - Tests failed$(NC)"; \
		exit 1; \
	fi

test/Data:
	@echo "$(YELLOW)Testing Troop900Data...$(NC)"
	@cd ios/Packages/Troop900Data && \
	if swift test; then \
		echo "$(GREEN)✅ Troop900Data - Tests passed$(NC)"; \
	else \
		echo "$(RED)❌ Troop900Data - Tests failed$(NC)"; \
		exit 1; \
	fi

test/Presentation:
	@echo "$(YELLOW)Testing Troop900Presentation...$(NC)"
	@cd ios/Packages/Troop900Presentation && \
	if swift test; then \
		echo "$(GREEN)✅ Troop900Presentation - Tests passed$(NC)"; \
	else \
		echo "$(RED)❌ Troop900Presentation - Tests failed$(NC)"; \
		exit 1; \
	fi

test/Bootstrap:
	@echo "$(YELLOW)Testing Troop900Bootstrap...$(NC)"
	@cd ios/Packages/Troop900Bootstrap && \
	if swift test; then \
		echo "$(GREEN)✅ Troop900Bootstrap - Tests passed$(NC)"; \
	else \
		echo "$(RED)❌ Troop900Bootstrap - Tests failed$(NC)"; \
		exit 1; \
	fi

test/packages: test/DesignSystem test/Domain test/Application test/Data test/Presentation test/Bootstrap
	@echo "$(GREEN)✅ All package tests passed!$(NC)"

test/applications:
	@echo "$(GREEN)Testing iOS Applications...$(NC)"
	@for app in $(APPS); do \
		echo "$(YELLOW)Testing $$app...$(NC)"; \
		cd ios/Apps/$$app && \
		if xcodebuild \
			-scheme $$app \
			-sdk iphonesimulator \
			-destination $(SIMULATOR_DESTINATION) \
			-skip-testing:$$app\UITests \
			test; then \
			echo "$(GREEN)✅ $$app - Tests passed$(NC)"; \
		else \
			echo "$(RED)❌ $$app - Tests failed$(NC)"; \
			cd ../../..; \
			exit 1; \
		fi && \
		cd ../../..; \
	done
	@echo "$(GREEN)✅ All application tests passed!$(NC)"

test: test/packages test/applications
	@echo "$(GREEN)🎉 All tests completed successfully!$(NC)"

# Coverage report targets
coverage/DesignSystem:
	@echo "$(YELLOW)Generating coverage report for Troop900DesignSystem...$(NC)"
	@./scripts/run_coverage.sh Troop900DesignSystem

coverage/Domain:
	@echo "$(YELLOW)Generating coverage report for Troop900Domain...$(NC)"
	@./scripts/run_coverage.sh Troop900Domain

coverage/Application:
	@echo "$(YELLOW)Generating coverage report for Troop900Application...$(NC)"
	@./scripts/run_coverage.sh Troop900Application

coverage/Data:
	@echo "$(YELLOW)Generating coverage report for Troop900Data...$(NC)"
	@./scripts/run_coverage.sh Troop900Data

coverage/Presentation:
	@echo "$(YELLOW)Generating coverage report for Troop900Presentation...$(NC)"
	@./scripts/run_coverage.sh Troop900Presentation

coverage/Bootstrap:
	@echo "$(YELLOW)Generating coverage report for Troop900Bootstrap...$(NC)"
	@./scripts/run_coverage.sh Troop900Bootstrap

coverage/packages: coverage/DesignSystem coverage/Domain coverage/Application coverage/Data coverage/Presentation coverage/Bootstrap
	@echo "$(GREEN)✅ All coverage reports generated!$(NC)"
	@echo "$(GREEN)Reports are available in each package directory:$(NC)"
	@echo "  - COVERAGE_REPORT.md (detailed text report)"
	@echo "  - coverage_report.html (interactive HTML visualization)"
