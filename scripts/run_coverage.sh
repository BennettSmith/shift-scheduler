#!/bin/bash

# Script to run coverage analysis for Swift packages
# Usage:
#   ./scripts/run_coverage.sh                    # Run for all packages
#   ./scripts/run_coverage.sh Troop900Application # Run for specific package
#   ./scripts/run_coverage.sh --help             # Show help

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$PROJECT_ROOT/ios/Packages"

# Available packages
PACKAGES=(
    "Troop900Application"
    "Troop900Domain"
    "Troop900Data"
    "Troop900Presentation"
    "Troop900DesignSystem"
    "Troop900Bootstrap"
)

# Show help
show_help() {
    cat << EOF
${BLUE}Swift Package Coverage Analysis Tool${NC}

${GREEN}USAGE:${NC}
    $0 [PACKAGE_NAME] [OPTIONS]

${GREEN}EXAMPLES:${NC}
    $0                           # Run coverage for all packages
    $0 Troop900Application       # Run coverage for specific package
    $0 --all                     # Run coverage for all packages (explicit)
    $0 --list                    # List available packages

${GREEN}OPTIONS:${NC}
    --help, -h                   Show this help message
    --all, -a                    Run for all packages
    --list, -l                   List available packages
    --html-only                  Generate only HTML reports
    --text-only                  Generate only text reports
    --no-test                    Skip running tests (use existing coverage data)
    --open                       Open HTML reports in browser after generation

${GREEN}AVAILABLE PACKAGES:${NC}
$(for pkg in "${PACKAGES[@]}"; do echo "    - $pkg"; done)

${GREEN}COVERAGE LEVELS:${NC}
    🎯 Excellent (95%+)         Production ready
    ✅ Good (85-95%)            Solid coverage
    ⚠️  Fair (70-85%)           Needs improvement
    🔴 Poor (<70%)              Significant gaps

${GREEN}OUTPUT:${NC}
    Reports are generated in each package directory:
    - COVERAGE_REPORT.md                 Detailed text report
    - coverage_report.html               Interactive HTML visualization
    - COVERAGE_ANALYSIS_SUMMARY.md       Executive summary (Application only)

${GREEN}EXAMPLES:${NC}
    # Quick coverage check for Application package
    $0 Troop900Application --open

    # Generate all reports
    $0 --all

    # Only generate HTML reports for Domain
    $0 Troop900Domain --html-only --open

    # Use existing coverage data without re-running tests
    $0 --all --no-test

EOF
}

# List packages
list_packages() {
    echo -e "${BLUE}Available Swift Packages:${NC}"
    echo ""
    for pkg in "${PACKAGES[@]}"; do
        if [ -d "$PACKAGES_DIR/$pkg" ]; then
            echo -e "  ${GREEN}✓${NC} $pkg"
        else
            echo -e "  ${RED}✗${NC} $pkg (not found)"
        fi
    done
    echo ""
}

# Check if package exists
package_exists() {
    local pkg=$1
    for p in "${PACKAGES[@]}"; do
        if [ "$p" = "$pkg" ]; then
            return 0
        fi
    done
    return 1
}

# Run tests with coverage for a package
run_tests() {
    local pkg=$1
    local pkg_dir="$PACKAGES_DIR/$pkg"
    
    echo -e "${BLUE}Running tests with coverage for ${pkg}...${NC}"
    
    cd "$pkg_dir"
    
    if swift test --enable-code-coverage; then
        echo -e "${GREEN}✓ Tests passed for ${pkg}${NC}"
        cd "$PROJECT_ROOT"
        return 0
    else
        echo -e "${RED}✗ Tests failed for ${pkg}${NC}"
        cd "$PROJECT_ROOT"
        return 1
    fi
}

# Generate coverage reports
generate_reports() {
    local pkg=$1
    local html_only=$2
    local text_only=$3
    
    echo -e "${BLUE}Generating coverage reports for ${pkg}...${NC}"
    
    local success=0
    
    # Generate text report
    if [ "$html_only" != "true" ]; then
        if python3 "$PROJECT_ROOT/scripts/analyze_swift_coverage.py" "$PACKAGES_DIR/$pkg" 2>/dev/null; then
            echo -e "${GREEN}✓ Text report generated${NC}"
        else
            echo -e "${YELLOW}⚠ Text report generation failed or no coverage data${NC}"
            success=1
        fi
    fi
    
    # Generate HTML report
    if [ "$text_only" != "true" ]; then
        if python3 "$PROJECT_ROOT/scripts/generate_html_coverage.py" "$PACKAGES_DIR/$pkg" 2>/dev/null; then
            echo -e "${GREEN}✓ HTML report generated${NC}"
        else
            echo -e "${YELLOW}⚠ HTML report generation failed or no coverage data${NC}"
            success=1
        fi
    fi
    
    return $success
}

# Extract and display coverage summary
show_summary() {
    local pkg=$1
    local report_file="$PACKAGES_DIR/$pkg/COVERAGE_REPORT.md"
    
    if [ -f "$report_file" ]; then
        echo ""
        echo -e "${BLUE}Coverage Summary for ${pkg}:${NC}"
        
        # Extract coverage metrics
        local overall=$(grep "Combined Coverage Score:" "$report_file" | head -1 | grep -oE '[0-9]+\.[0-9]+%' | head -1 || echo "N/A")
        local line=$(grep "Overall Line Coverage:" "$report_file" | head -1 | grep -oE '[0-9]+\.[0-9]+%' | head -1 || echo "N/A")
        local branch=$(grep "Overall Branch Coverage:" "$report_file" | head -1 | grep -oE '[0-9]+\.[0-9]+%' | head -1 || echo "N/A")
        
        # Determine status emoji
        local overall_num=$(echo "$overall" | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "0")
        local status_emoji="❓"
        
        if [ ! -z "$overall_num" ]; then
            if (( $(echo "$overall_num >= 95" | bc -l) )); then
                status_emoji="🎯"
            elif (( $(echo "$overall_num >= 85" | bc -l) )); then
                status_emoji="✅"
            elif (( $(echo "$overall_num >= 70" | bc -l) )); then
                status_emoji="⚠️"
            else
                status_emoji="🔴"
            fi
        fi
        
        echo -e "  Overall:  ${status_emoji} ${GREEN}${overall}${NC}"
        echo -e "  Line:     ${line}"
        echo -e "  Branch:   ${branch}"
        echo ""
    fi
}

# Open HTML report in browser
open_report() {
    local pkg=$1
    local html_file="$PACKAGES_DIR/$pkg/coverage_report.html"
    
    if [ -f "$html_file" ]; then
        echo -e "${BLUE}Opening HTML report for ${pkg}...${NC}"
        if command -v open &> /dev/null; then
            open "$html_file"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$html_file"
        else
            echo -e "${YELLOW}Could not open browser. View report at: $html_file${NC}"
        fi
    else
        echo -e "${YELLOW}HTML report not found for ${pkg}${NC}"
    fi
}

# Process a single package
process_package() {
    local pkg=$1
    local run_tests_flag=$2
    local html_only=$3
    local text_only=$4
    local open_report_flag=$5
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Processing: ${pkg}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Check if package exists
    if [ ! -d "$PACKAGES_DIR/$pkg" ]; then
        echo -e "${RED}✗ Package not found: $pkg${NC}"
        return 1
    fi
    
    # Run tests if needed
    if [ "$run_tests_flag" = "true" ]; then
        if ! run_tests "$pkg"; then
            echo -e "${RED}✗ Failed to run tests for ${pkg}${NC}"
            return 1
        fi
    fi
    
    # Generate reports
    generate_reports "$pkg" "$html_only" "$text_only"
    
    # Show summary
    show_summary "$pkg"
    
    # Open report if requested
    if [ "$open_report_flag" = "true" ]; then
        open_report "$pkg"
    fi
    
    echo -e "${GREEN}✓ Completed processing ${pkg}${NC}"
    return 0
}

# Main function
main() {
    local packages_to_process=()
    local run_tests_flag="true"
    local html_only="false"
    local text_only="false"
    local open_report_flag="false"
    local all_packages="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --list|-l)
                list_packages
                exit 0
                ;;
            --all|-a)
                all_packages="true"
                shift
                ;;
            --no-test)
                run_tests_flag="false"
                shift
                ;;
            --html-only)
                html_only="true"
                shift
                ;;
            --text-only)
                text_only="true"
                shift
                ;;
            --open)
                open_report_flag="true"
                shift
                ;;
            *)
                if package_exists "$1"; then
                    packages_to_process+=("$1")
                else
                    echo -e "${RED}Unknown package: $1${NC}"
                    echo "Use --list to see available packages"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Determine which packages to process
    if [ "$all_packages" = "true" ] || [ ${#packages_to_process[@]} -eq 0 ]; then
        packages_to_process=("${PACKAGES[@]}")
    fi
    
    # Validate options
    if [ "$html_only" = "true" ] && [ "$text_only" = "true" ]; then
        echo -e "${RED}Error: Cannot use both --html-only and --text-only${NC}"
        exit 1
    fi
    
    # Start processing
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Swift Package Coverage Analysis      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Processing ${#packages_to_process[@]} package(s)..."
    
    local failed_packages=()
    local success_count=0
    
    # Process each package
    for pkg in "${packages_to_process[@]}"; do
        if process_package "$pkg" "$run_tests_flag" "$html_only" "$text_only" "$open_report_flag"; then
            ((success_count++))
        else
            failed_packages+=("$pkg")
        fi
    done
    
    # Final summary
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Final Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Processed: ${#packages_to_process[@]} packages"
    echo -e "${GREEN}Success: ${success_count}${NC}"
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        echo -e "${RED}Failed: ${#failed_packages[@]}${NC}"
        echo -e "${RED}Failed packages:${NC}"
        for pkg in "${failed_packages[@]}"; do
            echo -e "  ${RED}✗${NC} $pkg"
        done
        exit 1
    else
        echo -e "${GREEN}All packages processed successfully!${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}Reports generated in each package's directory${NC}"
    echo -e "View HTML reports by opening coverage_report.html files"
    echo ""
}

# Run main function
main "$@"
