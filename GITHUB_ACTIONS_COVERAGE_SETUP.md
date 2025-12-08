# GitHub Actions Coverage Setup - Summary

## 🎉 What's Been Set Up

Your repository now has **comprehensive automated testing and code coverage analysis** for all Swift packages with GitHub Actions integration!

---

## 📦 New Workflows

### 1. **Swift Packages - Tests & Coverage** (`.github/workflows/swift-packages-coverage.yml`)

**Triggers on:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Changes to any files in `ios/Packages/**` or `scripts/**`

**What it does:**
- ✅ Tests all 6 Swift packages **in parallel** (fast!)
- ✅ Collects code coverage for each package
- ✅ Generates detailed coverage reports (text + HTML)
- ✅ Posts coverage summary as PR comment
- ✅ Uploads reports as downloadable artifacts (30-day retention)
- ✅ Shows coverage in PR checks

**Packages tested:**
- Troop900Application
- Troop900Domain
- Troop900Data
- Troop900Presentation
- Troop900DesignSystem
- Troop900Bootstrap

---

### 2. **Generate Coverage Report** (`.github/workflows/coverage-report.yml`)

**Triggers on:**
- Manual workflow dispatch (run anytime you want)
- Weekly schedule (Sunday at midnight UTC)
- Push to `main` with Swift file changes

**What it does:**
- ✅ Tests all packages sequentially
- ✅ Generates comprehensive coverage reports
- ✅ Creates combined summary with coverage table
- ✅ Calculates average coverage across all packages
- ✅ Uploads complete report bundle (90-day retention)
- ✅ Perfect for historical tracking

---

## 🚀 How It Works

### Automatic on Pull Requests

When you create a PR that changes any package code:

1. **Tests run automatically** for all affected packages
2. **Coverage is collected** during test execution
3. **Reports are generated** using your Python scripts
4. **Coverage metrics appear** as PR comment:
   ```
   📊 Coverage Report: Troop900Application
   
   | Metric | Coverage |
   |--------|----------|
   | Overall | 91.2% |
   | Line | 86.1% |
   | Branch | 96.4% |
   ```
5. **Artifacts are uploaded** for detailed review

### Manual Run

Want a comprehensive coverage report right now?

1. Go to **Actions** tab in GitHub
2. Select "Generate Coverage Report"
3. Click **Run workflow**
4. Wait for completion (~30-45 minutes)
5. Download complete report bundle

### Weekly Reports

Every Sunday, a complete coverage report is automatically generated and saved for historical tracking.

---

## 📊 Coverage Reports Available

### Per Package (from `swift-packages-coverage.yml`)

Each package gets its own artifact with:
- `COVERAGE_REPORT.md` - Detailed text report
- `coverage_report.html` - Interactive HTML visualization
- `COVERAGE_ANALYSIS_SUMMARY.md` - Executive summary

### Combined Report (from `coverage-report.yml`)

One artifact with everything:
- All individual package reports
- `COMBINED_COVERAGE_SUMMARY.md` - Table comparing all packages
- Average coverage calculation
- Coverage level indicators

---

## 🎯 Coverage Metrics Explained

### Three Key Metrics

1. **Overall Coverage** (Most Important)
   - Weighted average: 50% line + 50% branch
   - Best indicator of overall test quality

2. **Line Coverage**
   - Percentage of code lines executed by tests
   - Shows how much code is tested

3. **Branch Coverage**
   - Percentage of decision branches tested
   - Shows how well edge cases are covered

### Coverage Levels

| Icon | Level | Range | Meaning |
|------|-------|-------|---------|
| 🎯 | Excellent | 95%+ | Production ready |
| ✅ | Good | 85-95% | Solid coverage |
| ⚠️ | Fair | 70-85% | Needs improvement |
| 🔴 | Poor | <70% | Critical gaps |

---

## 💻 Local Development

### Quick Coverage Check

Use the new convenience script:

```bash
# Run for all packages
./scripts/run_coverage.sh

# Run for specific package and open report
./scripts/run_coverage.sh Troop900Application --open

# Show help
./scripts/run_coverage.sh --help
```

### Manual Steps

```bash
# 1. Run tests with coverage
cd ios/Packages/Troop900Application
swift test --enable-code-coverage
cd ../../..

# 2. Generate reports
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application

# 3. View report
open ios/Packages/Troop900Application/coverage_report.html
```

---

## 📁 File Structure

```
shift-scheduler/
├── .github/
│   └── workflows/
│       ├── ios-ci.yml                        # Existing iOS app CI
│       ├── swift-packages-coverage.yml       # 🆕 Package testing (parallel)
│       ├── coverage-report.yml               # 🆕 Comprehensive report
│       └── README.md                         # 🆕 Workflow documentation
├── scripts/
│   ├── analyze_swift_coverage.py             # Generic text report generator
│   ├── generate_html_coverage.py             # Generic HTML report generator
│   ├── run_coverage.sh                       # 🆕 Convenience script
│   ├── README.md                             # Scripts documentation
│   └── MIGRATION_NOTES.md                    # Migration history
└── ios/Packages/
    ├── Troop900Application/
    │   ├── COVERAGE_REPORT.md               # Generated by CI
    │   ├── coverage_report.html             # Generated by CI
    │   └── README_COVERAGE.md               # Usage instructions
    └── [other packages...]
```

---

## 🔍 Viewing Coverage in GitHub

### In Pull Requests

1. **Check Status** - Look for "Swift Packages - Tests & Coverage" check
2. **Read Comment** - Coverage metrics posted automatically
3. **Review Details** - Click check to see workflow run
4. **Download Reports** - Get detailed HTML/MD reports from artifacts

### In Actions Tab

1. Go to **Actions** tab
2. Select a workflow run
3. View **Summary** for quick metrics
4. Download **Artifacts** for detailed reports
5. Check **Logs** for any issues

---

## 🎓 Best Practices

### For Developers

1. **Run coverage locally** before pushing
   ```bash
   ./scripts/run_coverage.sh Troop900Application --open
   ```

2. **Check coverage in PRs** - Don't merge if coverage drops significantly

3. **Fix failing tests** immediately - Don't merge failing PRs

4. **Target 90%+ overall coverage** - Especially for critical code

### For Code Reviews

1. **Review coverage report** in PR comment
2. **Check if coverage decreased** - Ask why if significant drop
3. **Look for untested code** - Download artifacts to see details
4. **Ensure new code is tested** - New features should have tests

### For Team Leads

1. **Monitor weekly reports** - Track coverage trends over time
2. **Set coverage goals** - Team-wide targets (e.g., 90%+)
3. **Review artifacts** - Deep dive into problem areas
4. **Celebrate wins** - Recognize coverage improvements

---

## ⚡ Performance & Optimization

### Parallel Execution

The `swift-packages-coverage.yml` workflow tests all 6 packages **in parallel**, making it very fast:
- Sequential: ~30-45 minutes
- Parallel: ~5-10 minutes ✨

### Caching

Workflows cache Swift Package Manager builds:
- First run: ~5-10 minutes
- Cached runs: ~3-5 minutes
- Cache invalidates when dependencies change

### Cost Considerations

GitHub Actions minutes consumed:
- **Per PR:** ~5-10 minutes (all packages, parallel)
- **Weekly report:** ~30-45 minutes (sequential, more thorough)
- **Manual runs:** ~30-45 minutes

**Optimization tips:**
- ✅ Already using caching
- ✅ Already using parallel execution
- ✅ Triggers only on relevant file changes
- ✅ Manual trigger prevents unnecessary runs

---

## 🐛 Troubleshooting

### Tests Pass Locally But Fail in CI

**Causes:**
- Xcode version mismatch
- Dependency resolution issues
- Local state dependencies

**Solutions:**
1. Check Xcode version in workflow vs local
2. Clean build folder: `swift package clean`
3. Ensure tests don't depend on local files
4. Review workflow logs for specific errors

### Coverage Reports Not Generated

**Causes:**
- Tests failed before coverage collection
- Python scripts not found
- Coverage data missing

**Solutions:**
1. Verify tests pass first
2. Check `scripts/` folder exists
3. Ensure coverage data in `.build/` directory
4. Review Python script error messages

### PR Comments Not Posted

**Causes:**
- GitHub token permissions
- Workflow trigger conditions

**Solutions:**
1. Verify `GITHUB_TOKEN` has write access
2. Check workflow has `pull_request` trigger
3. Review GitHub script step logs

### Artifacts Not Found

**Causes:**
- Retention period expired (30 days for package reports)
- Tests didn't complete
- Upload step failed

**Solutions:**
1. Check artifact retention settings
2. Verify tests completed successfully
3. Review artifact upload step logs

---

## 🚦 Status Checks

Add these to your branch protection rules:

1. Go to **Settings** → **Branches**
2. Edit branch protection for `main`
3. Enable "Require status checks to pass before merging"
4. Add these checks:
   - `Test & Coverage - Troop900Application`
   - `Test & Coverage - Troop900Domain`
   - `Test & Coverage - Troop900Data`
   - (Add others as needed)

This ensures PRs can't merge without passing tests!

---

## 📈 Future Enhancements

Potential improvements to consider:

- [ ] **Coverage badges** in README
- [ ] **Codecov/Coveralls integration** for trends
- [ ] **Slack/Discord notifications** for coverage changes
- [ ] **Coverage diff** showing change from base branch
- [ ] **Automatic PR reviews** based on coverage thresholds
- [ ] **Historical database** for long-term tracking
- [ ] **Custom coverage thresholds** per package

---

## 📚 Documentation

### Complete Documentation Available

- **Workflows:** `.github/workflows/README.md`
- **Scripts:** `scripts/README.md`
- **Package-specific:** `ios/Packages/Troop900Application/README_COVERAGE.md`
- **This guide:** `GITHUB_ACTIONS_COVERAGE_SETUP.md`

### Quick Links

- [Workflow Documentation](.github/workflows/README.md)
- [Script Usage Guide](scripts/README.md)
- [Coverage Script Help](scripts/run_coverage.sh) (`--help`)

---

## ✅ Verification Checklist

Verify your setup works:

- [ ] Push a change to any package
- [ ] Verify workflow runs automatically
- [ ] Check coverage metrics appear
- [ ] Download and view artifacts
- [ ] Try manual coverage report run
- [ ] Test local coverage script
- [ ] Review PR with coverage comment
- [ ] Verify weekly schedule is set

---

## 🎊 Summary

You now have:

✅ **Automated testing** for all 6 Swift packages  
✅ **Code coverage collection** with every test run  
✅ **Beautiful reports** (text + interactive HTML)  
✅ **PR integration** with coverage comments  
✅ **Weekly reports** for historical tracking  
✅ **Local tools** for development  
✅ **Comprehensive documentation**  
✅ **Optimized performance** (parallel, cached)  

---

## 🆘 Need Help?

1. **Check logs** in GitHub Actions
2. **Review documentation** in workflow README
3. **Run locally** with `./scripts/run_coverage.sh`
4. **Check this guide** for troubleshooting
5. **Open an issue** with relevant logs

---

**Setup Date:** December 7, 2025  
**Status:** ✅ Ready to Use  
**Coverage Tool:** Swift Package Manager + Custom Python Scripts  
**CI Platform:** GitHub Actions
