# Swift Code Coverage Analysis Scripts

This directory contains reusable Python scripts for analyzing code coverage in Swift packages.

## Scripts

### 1. `run_coverage.sh` (Recommended)
**Convenient shell script to run coverage analysis with one command.**

This is the easiest way to run coverage locally. It handles running tests, generating reports, and displaying summaries.

```bash
# Run for all packages
./scripts/run_coverage.sh

# Run for specific package
./scripts/run_coverage.sh Troop900Application

# Generate and open HTML report
./scripts/run_coverage.sh Troop900Application --open

# See all options
./scripts/run_coverage.sh --help
```

### 2. `analyze_swift_coverage.py`
Generates a detailed text report of code coverage for any Swift package.

### 3. `generate_html_coverage.py`
Creates an interactive HTML report with visual charts and filtering capabilities.

## Prerequisites

- Python 3.6+
- Swift Package Manager
- Your Swift package must have tests

## Quick Start

### Easy Way (Recommended)

Use the convenience script to do everything in one command:

```bash
# From repository root - run for all packages
./scripts/run_coverage.sh

# Or run for a specific package
./scripts/run_coverage.sh Troop900Application --open
```

This script automatically:
1. Runs tests with coverage
2. Generates both text and HTML reports
3. Shows a summary
4. Optionally opens the HTML report

### Manual Way

If you prefer to run steps individually:

**Step 1: Run Tests with Coverage**
```bash
cd <path-to-your-swift-package>
swift test --enable-code-coverage
```

**Step 2: Generate Reports**
```bash
# From repository root
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application

# Open the HTML report
open ios/Packages/Troop900Application/coverage_report.html
```

## Usage Examples

### Analyze All Files in a Package

```bash
# Text report
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Domain

# HTML report
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Domain
```

### Filter by Pattern

Analyze only specific types of files (e.g., UseCases, Entities, etc.):

```bash
# Only analyze UseCase files
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application --filter "UseCases"

# Only analyze Entity files
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Domain --filter "Entities"

# Generate HTML for filtered results
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application --filter "UseCases"
```

### Custom Output Location

```bash
# Save to specific location
python3 scripts/analyze_swift_coverage.py \
  ios/Packages/Troop900Application \
  --output reports/application_coverage.md

# HTML to custom location
python3 scripts/generate_html_coverage.py \
  ios/Packages/Troop900Domain \
  --output reports/domain_coverage.html
```

## Available Packages

Use these scripts with any of the project's Swift packages:

- `ios/Packages/Troop900Application` - Use case implementations
- `ios/Packages/Troop900Domain` - Domain entities and models
- `ios/Packages/Troop900Data` - Data layer and repositories
- `ios/Packages/Troop900Presentation` - UI/Presentation layer
- `ios/Packages/Troop900DesignSystem` - Design system components
- `ios/Packages/Troop900Bootstrap` - App bootstrap/configuration

## Script Options

### `analyze_swift_coverage.py`

```
Usage: python3 analyze_swift_coverage.py <package_path> [options]

Arguments:
  package_path          Path to the Swift package directory (required)

Options:
  --filter <pattern>    Only analyze files containing this pattern
  --output <path>       Output file path (default: COVERAGE_REPORT.md in package dir)
  --help               Show help message
```

### `generate_html_coverage.py`

```
Usage: python3 generate_html_coverage.py <package_path> [options]

Arguments:
  package_path          Path to the Swift package directory (required)

Options:
  --filter <pattern>    Only analyze files containing this pattern
  --output <path>       Output HTML file path (default: coverage_report.html in package dir)
  --help               Show help message
```

## Understanding the Reports

### Coverage Levels

Reports categorize files by coverage quality:

- 🎯 **Perfect (100%)** - All code paths covered
- ✅ **Excellent (95-99%)** - Minor gaps, production-ready
- 👍 **Good (85-94%)** - Solid coverage, some edge cases missing
- ⚠️ **Fair (70-84%)** - Adequate but needs improvement
- 🔴 **Poor (<70%)** - Significant gaps, needs attention

### Metrics

- **Line Coverage** - Percentage of code lines executed by tests
- **Branch Coverage** - Percentage of conditional branches tested
- **Overall Score** - Weighted average (50% line + 50% branch)

### HTML Report Features

The HTML report includes:

- Interactive filtering by coverage level
- Expandable/collapsible categories
- Visual progress bars
- Color-coded indicators
- Detailed uncovered region listings with line numbers
- Summary statistics

## Workflow Examples

### Analyze a Single Package

```bash
cd ios/Packages/Troop900Application
swift test --enable-code-coverage
cd ../../../..
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application
open ios/Packages/Troop900Application/coverage_report.html
```

### Analyze All Packages

```bash
#!/bin/bash
# Run this from repository root

PACKAGES=(
  "ios/Packages/Troop900Application"
  "ios/Packages/Troop900Domain"
  "ios/Packages/Troop900Data"
  "ios/Packages/Troop900Presentation"
)

for package in "${PACKAGES[@]}"; do
  echo "Analyzing $package..."
  cd "$package"
  swift test --enable-code-coverage
  cd -
  python3 scripts/analyze_swift_coverage.py "$package"
  python3 scripts/generate_html_coverage.py "$package"
done

echo "Coverage reports generated for all packages!"
```

### Focus on Specific Components

```bash
# Analyze only UseCases in Application package
python3 scripts/analyze_swift_coverage.py \
  ios/Packages/Troop900Application \
  --filter "UseCases" \
  --output reports/usecases_coverage.md

# Analyze only Entities in Domain package
python3 scripts/analyze_swift_coverage.py \
  ios/Packages/Troop900Domain \
  --filter "Entities" \
  --output reports/entities_coverage.md

# Generate HTML for UseCases
python3 scripts/generate_html_coverage.py \
  ios/Packages/Troop900Application \
  --filter "UseCases" \
  --output reports/usecases_coverage.html
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Code Coverage

on: [push, pull_request]

jobs:
  coverage:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run tests with coverage
      run: |
        cd ios/Packages/Troop900Application
        swift test --enable-code-coverage
    
    - name: Generate coverage reports
      run: |
        python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application
        python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application
    
    - name: Upload coverage reports
      uses: actions/upload-artifact@v3
      with:
        name: coverage-reports
        path: |
          ios/Packages/Troop900Application/COVERAGE_REPORT.md
          ios/Packages/Troop900Application/coverage_report.html
```

## Troubleshooting

### "Coverage data not found"

**Problem:** Script can't find the coverage JSON file.

**Solution:** 
1. Make sure you ran `swift test --enable-code-coverage` first
2. Check that tests completed successfully
3. Verify the package path is correct

### "No files found matching the criteria"

**Problem:** Filter is too restrictive or package structure differs.

**Solution:**
1. Try without the `--filter` option first
2. Check the actual file structure in `Sources/<PackageName>/`
3. Use a broader filter pattern

### "Invalid JSON in coverage data"

**Problem:** Coverage file is corrupted or incomplete.

**Solution:**
1. Delete the `.build` directory
2. Re-run `swift test --enable-code-coverage`
3. Try again

## Tips

1. **Run coverage regularly** - After adding new tests or changing code
2. **Use filters** - Focus on specific areas when analyzing large packages
3. **Set coverage goals** - Aim for 90%+ overall, 95%+ for critical code
4. **Track progress** - Compare reports over time to see improvements
5. **Share HTML reports** - Easy for team review and discussions

## Contributing

These scripts are generic and reusable. If you find issues or want to add features:

1. Test with multiple packages
2. Ensure backward compatibility
3. Update this README with new examples

## License

These scripts are part of the shift-scheduler project and follow the same license.
