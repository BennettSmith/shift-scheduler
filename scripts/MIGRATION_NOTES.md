# Coverage Scripts Migration Notes

## Summary

The coverage analysis scripts have been refactored and moved from the Troop900Application package to a top-level `scripts/` folder. They are now **generic and reusable** across all Swift packages in the project.

## Changes Made

### 1. Created Generic Scripts

**New Location:** `/scripts/`

- ✅ `analyze_swift_coverage.py` - Generic text report generator
- ✅ `generate_html_coverage.py` - Generic HTML report generator
- ✅ `README.md` - Comprehensive documentation

**Key Improvements:**
- Accept package path as command-line argument
- Support `--filter` option to analyze specific file types
- Support `--output` option for custom report locations
- Automatic detection of coverage data files
- Work with any Swift package structure
- Better error handling and user guidance

### 2. Removed Package-Specific Scripts

**Deleted from Troop900Application:**
- ❌ `analyze_coverage.py` (replaced by generic version)
- ❌ `generate_html_coverage_report.py` (replaced by generic version)

**Updated in Troop900Application:**
- ✅ `README_COVERAGE.md` - Updated to reference new scripts
- ✅ `COVERAGE_ANALYSIS_SUMMARY.md` - Updated with new instructions

## Usage Comparison

### Before (Package-Specific)

```bash
cd ios/Packages/Troop900Application
swift test --enable-code-coverage
python3 analyze_coverage.py
python3 generate_html_coverage_report.py
open coverage_report.html
```

**Limitations:**
- Only worked for Troop900Application
- Scripts had to be copied to use with other packages
- Hardcoded paths
- Not flexible

### After (Generic & Reusable)

```bash
# From repository root
cd ios/Packages/Troop900Application
swift test --enable-code-coverage
cd ../../..

python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application
open ios/Packages/Troop900Application/coverage_report.html
```

**Benefits:**
- Works with ALL packages
- Single source of truth
- Flexible filtering options
- Custom output locations
- Better maintained

## Available for All Packages

The scripts now work with:

1. **Troop900Application** - Use case implementations (47 files)
2. **Troop900Domain** - Domain entities and models
3. **Troop900Data** - Data layer and repositories
4. **Troop900Presentation** - UI/Presentation layer
5. **Troop900DesignSystem** - Design system components
6. **Troop900Bootstrap** - App bootstrap/configuration

## Examples with Different Packages

### Analyze Use Cases (Application)

```bash
python3 scripts/analyze_swift_coverage.py \
  ios/Packages/Troop900Application \
  --filter "UseCases"
```

### Analyze Entities (Domain)

```bash
python3 scripts/analyze_swift_coverage.py \
  ios/Packages/Troop900Domain \
  --filter "Entities"
```

### Analyze Repositories (Data)

```bash
python3 scripts/analyze_swift_coverage.py \
  ios/Packages/Troop900Data \
  --filter "Repositories"
```

### Generate HTML for Any Package

```bash
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Domain
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Presentation
```

## Script Features

### Command-Line Options

Both scripts support:

- **Required:** Package path (e.g., `ios/Packages/Troop900Application`)
- **Optional:** `--filter <pattern>` - Only analyze files containing pattern
- **Optional:** `--output <path>` - Custom output location
- **Optional:** `--help` - Show usage information

### Automatic Detection

Scripts automatically:
- Find coverage data in `.build` directories
- Handle different architectures (arm64, x86_64)
- Detect package names
- Validate inputs
- Provide helpful error messages

### Intelligent Filtering

The `--filter` option allows focusing on:
- `UseCases` - Application use cases
- `Entities` - Domain entities
- `Repositories` - Data repositories
- `ViewModels` - Presentation view models
- Any folder or file pattern

## Migration Checklist

- ✅ Created generic scripts in `scripts/` folder
- ✅ Made scripts executable (`chmod +x`)
- ✅ Added comprehensive README with examples
- ✅ Tested with Troop900Application package
- ✅ Removed old package-specific scripts
- ✅ Updated documentation in Troop900Application
- ✅ Created migration notes (this file)

## Next Steps

### For Users

1. Start using the new scripts from repository root
2. Explore filtering options for focused analysis
3. Try with different packages in the project
4. Share HTML reports with team

### For Future Development

1. Consider adding these to CI/CD pipeline
2. Create convenience shell scripts for common workflows
3. Add support for comparing coverage over time
4. Consider coverage thresholds and quality gates

## Documentation

Full documentation is available in:
- `scripts/README.md` - Complete usage guide and examples
- `ios/Packages/Troop900Application/README_COVERAGE.md` - Quick reference

## Testing

The generic scripts have been tested with:
- ✅ Troop900Application (all files)
- ✅ Troop900Application (filtered by UseCases)
- 🔄 Other packages pending test data generation

## Benefits Summary

1. **Reusability** - One set of scripts for all packages
2. **Maintainability** - Single source to update
3. **Flexibility** - Filter, customize, extend easily
4. **Consistency** - Same reporting format across packages
5. **Documentation** - Comprehensive guides and examples
6. **User-Friendly** - Better error messages and guidance

## Migration Date

**December 7, 2025**

Scripts migrated and made generic for use across all Swift packages in the project.
