# Coverage Analysis - Quick Reference

## 🚀 Running Coverage Locally

### Easiest Way (One Command)
```bash
# All packages
./scripts/run_coverage.sh

# Specific package with browser
./scripts/run_coverage.sh Troop900Application --open

# Get help
./scripts/run_coverage.sh --help
```

### Manual Way
```bash
cd ios/Packages/Troop900Application
swift test --enable-code-coverage
cd ../../..
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application
open ios/Packages/Troop900Application/coverage_report.html
```

---

## 🤖 GitHub Actions

### Automatic on PRs
- Tests run when you push changes to packages
- Coverage posted as PR comment
- Reports available as artifacts (30 days)

### Manual Full Report
1. Go to **Actions** tab
2. Select "Generate Coverage Report"
3. Click **Run workflow**
4. Download artifacts when done

### Weekly Reports
- Runs every Sunday at midnight UTC
- Complete report for all packages
- Available as artifacts (90 days)

---

## 📊 Understanding Coverage

### Metrics
- **Overall** = 50% line + 50% branch (most important)
- **Line** = % of code lines tested
- **Branch** = % of decision paths tested

### Levels
- 🎯 **95%+** = Excellent
- ✅ **85-95%** = Good
- ⚠️ **70-85%** = Fair
- 🔴 **<70%** = Poor

---

## 📁 Where to Find Reports

### Local
```
ios/Packages/YourPackage/
├── COVERAGE_REPORT.md              # Detailed text
├── coverage_report.html            # Interactive HTML
└── COVERAGE_ANALYSIS_SUMMARY.md    # Summary
```

### GitHub Actions
- **Actions tab** → Select workflow run → **Artifacts** section

---

## 🔧 Available Scripts

| Script | Purpose |
|--------|---------|
| `run_coverage.sh` | All-in-one coverage tool (recommended) |
| `analyze_swift_coverage.py` | Generate text report |
| `generate_html_coverage.py` | Generate HTML report |

---

## 📦 Packages Covered

✅ Troop900Application  
✅ Troop900Domain  
✅ Troop900Data  
✅ Troop900Presentation  
✅ Troop900DesignSystem  
✅ Troop900Bootstrap  

---

## 📚 Full Documentation

- **Setup Guide:** [GITHUB_ACTIONS_COVERAGE_SETUP.md](GITHUB_ACTIONS_COVERAGE_SETUP.md)
- **Workflows:** [.github/workflows/README.md](.github/workflows/README.md)
- **Scripts:** [scripts/README.md](scripts/README.md)

---

## 💡 Pro Tips

1. Run coverage before pushing: `./scripts/run_coverage.sh YourPackage --open`
2. Check PR coverage comments before merging
3. Aim for 90%+ overall coverage
4. Use `--no-test` flag to regenerate reports without re-running tests
5. Download weekly reports to track progress over time

---

## 🆘 Quick Troubleshooting

**Tests fail locally:**
- Clean build: `swift package clean`
- Update dependencies: `swift package resolve`

**No coverage data:**
- Verify tests passed
- Check `.build/` directory exists
- Ensure using `--enable-code-coverage` flag

**CI failing:**
- Check workflow logs in Actions tab
- Compare Xcode versions (local vs CI)
- Verify recent pushes didn't break tests

---

**Last Updated:** December 7, 2025
