# Code Coverage Analysis

## Quick Start

The coverage analysis scripts have been moved to the top-level `scripts/` folder and are now reusable across all Swift packages in the project.

### Generate Coverage Reports

```bash
# From repository root:

# 1. Run tests with coverage
cd ios/Packages/Troop900Application
swift test --enable-code-coverage
cd ../../..

# 2. Generate text report
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application

# 3. Generate interactive HTML report
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application

# 4. Open the HTML report
open ios/Packages/Troop900Application/coverage_report.html
```

### Analyze Only Use Cases

```bash
python3 scripts/analyze_swift_coverage.py \
  ios/Packages/Troop900Application \
  --filter "UseCases"

python3 scripts/generate_html_coverage.py \
  ios/Packages/Troop900Application \
  --filter "UseCases"
```

## Available Reports

When you run the scripts, they generate:

- **COVERAGE_REPORT.md** - Detailed text report with statistics
- **coverage_report.html** - Interactive HTML visualization

## Coverage Levels

- 🎯 **Perfect (100%)** - All code paths covered
- ✅ **Excellent (95-99%)** - Minor gaps, production-ready
- 👍 **Good (85-94%)** - Solid coverage
- ⚠️ **Fair (70-84%)** - Needs improvement
- 🔴 **Poor (<70%)** - Significant gaps

## Current Status

Last analysis showed:
- **Overall Coverage:** 91.2%
- **Use Cases Analyzed:** 47
- **Excellent Coverage:** 6 use cases (95%+)
- **Good Coverage:** 36 use cases (85-95%)
- **Fair Coverage:** 5 use cases (70-85%)

## Documentation

For complete documentation, usage examples, and advanced features, see:

**📚 [scripts/README.md](../../../scripts/README.md)**

## Tips

- Run coverage analysis after adding new tests
- Use the `--filter` option to focus on specific components
- The HTML report allows filtering by coverage level
- Share the HTML report with your team for review
