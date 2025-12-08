# GitHub Actions Workflows

This directory contains CI/CD workflows for the Shift Scheduler project.

## Workflows

### 1. iOS CI (`ios-ci.yml`)
**Trigger:** Push/PR to main branch with iOS app changes

**Purpose:** Build and test the main iOS application

**What it does:**
- Checks out code
- Selects latest Xcode
- Builds and tests the ShiftScheduler app
- Runs on iOS Simulator

**Usage:** Automatic on iOS app changes

---

### 2. Swift Packages - Tests & Coverage (`swift-packages-coverage.yml`)
**Trigger:** Push/PR to main/develop branch with package changes

**Purpose:** Test all Swift packages and collect code coverage

**What it does:**
- Tests all 6 Swift packages in parallel:
  - Troop900Application
  - Troop900Domain
  - Troop900Data
  - Troop900Presentation
  - Troop900DesignSystem
  - Troop900Bootstrap
- Runs tests with code coverage enabled
- Generates coverage reports using our Python scripts
- Extracts coverage metrics (overall, line, branch)
- Posts coverage summary to PR (if applicable)
- Uploads coverage reports as artifacts

**Artifacts Generated:**
- `coverage-{PackageName}/COVERAGE_REPORT.md` - Detailed text report
- `coverage-{PackageName}/coverage_report.html` - Interactive HTML report
- `coverage-{PackageName}/COVERAGE_ANALYSIS_SUMMARY.md` - Executive summary

**Retention:** 30 days

**Usage:** 
- Automatic on package changes
- View coverage in PR comments
- Download artifacts for detailed analysis

---

### 3. Generate Coverage Report (`coverage-report.yml`)
**Trigger:** 
- Manual workflow dispatch
- Weekly schedule (Sunday at midnight UTC)
- Push to main with Swift file changes

**Purpose:** Generate comprehensive coverage report for all packages

**What it does:**
- Tests all packages sequentially
- Generates coverage reports for each package
- Creates a combined summary with coverage table
- Calculates average coverage across all packages
- Uploads all reports as a single artifact

**Artifacts Generated:**
- `complete-coverage-reports/` - All reports in one bundle
  - Individual package reports (MD & HTML)
  - Combined summary with coverage table
  - Average coverage calculation

**Retention:** 90 days

**Usage:**
- Run manually when needed
- Automatic weekly reports
- Historical coverage tracking

---

## Coverage Metrics

All workflows report three key metrics:

1. **Overall Coverage** - Weighted average (50% line + 50% branch)
2. **Line Coverage** - Percentage of code lines executed by tests
3. **Branch Coverage** - Percentage of conditional branches tested

### Coverage Levels

| Level | Range | Status | Description |
|-------|-------|--------|-------------|
| 🎯 Excellent | 95%+ | Production Ready | Minor gaps, excellent coverage |
| ✅ Good | 85-95% | Solid | Good coverage, some edge cases missing |
| ⚠️ Fair | 70-85% | Needs Work | Adequate but needs improvement |
| 🔴 Poor | <70% | Critical | Significant gaps, urgent attention needed |

---

## Viewing Coverage Reports

### In Pull Requests

Coverage metrics are automatically posted as PR comments for each package tested.

### From Workflow Runs

1. Go to **Actions** tab in GitHub
2. Select a workflow run
3. Scroll to **Artifacts** section
4. Download coverage reports
5. Open HTML files in browser for interactive view

### Locally

```bash
# Test a package
cd ios/Packages/Troop900Application
swift test --enable-code-coverage
cd ../../..

# Generate reports
python3 scripts/analyze_swift_coverage.py ios/Packages/Troop900Application
python3 scripts/generate_html_coverage.py ios/Packages/Troop900Application

# View HTML report
open ios/Packages/Troop900Application/coverage_report.html
```

---

## Manual Workflow Triggers

### Run Coverage Report Manually

1. Go to **Actions** tab
2. Select "Generate Coverage Report" workflow
3. Click **Run workflow**
4. Select branch
5. Click **Run workflow** button
6. Wait for completion
7. Download artifacts

---

## Workflow Status Badges

Add these badges to your README:

```markdown
![iOS CI](https://github.com/YOUR_ORG/shift-scheduler/workflows/iOS%20CI/badge.svg)
![Swift Packages](https://github.com/YOUR_ORG/shift-scheduler/workflows/Swift%20Packages%20-%20Tests%20%26%20Coverage/badge.svg)
```

---

## Environment & Requirements

### Required

- **OS:** macOS (latest)
- **Xcode:** Latest stable version
- **Python:** 3.11+
- **Swift:** Via Xcode

### Caching

Workflows cache Swift Package Manager builds for faster execution:
- Cache key includes Package.swift and Package.resolved
- Helps reduce build times on subsequent runs
- Automatically invalidated when dependencies change

---

## Customization

### Adjust Coverage Thresholds

Edit the coverage level checks in the workflows:

```yaml
# In swift-packages-coverage.yml or coverage-report.yml
if (( $(echo "$OVERALL_NUM >= 95" | bc -l) )); then
  STATUS="🎯 Excellent"
```

### Change Trigger Conditions

Modify the `on:` section:

```yaml
on:
  push:
    branches: [ main, develop, feature/* ]
    paths:
      - 'ios/Packages/**'
```

### Add/Remove Packages

Update the matrix or array in workflows:

```yaml
matrix:
  package:
    - Troop900Application
    - Troop900Domain
    - YourNewPackage  # Add here
```

---

## Troubleshooting

### Tests Fail But Pass Locally

- Check Xcode version match
- Verify package dependencies are resolved
- Review workflow logs for specific errors
- Ensure tests don't depend on local state

### Coverage Reports Not Generated

- Verify tests completed successfully
- Check that Python scripts are in `scripts/` folder
- Ensure coverage data exists in `.build/` directory
- Review script error messages in logs

### PR Comments Not Posted

- Verify GitHub Actions permissions
- Check `GITHUB_TOKEN` has write access
- Ensure workflow has `pull_request` trigger
- Review GitHub script step for errors

### Artifacts Not Found

- Confirm tests ran and generated coverage data
- Check artifact upload step completed
- Verify retention period hasn't expired
- Ensure file paths are correct

---

## Best Practices

1. **Monitor Coverage Trends** - Download weekly reports to track progress
2. **Set Team Goals** - Aim for 90%+ overall coverage
3. **Review PR Coverage** - Check coverage changes in PRs
4. **Fix Failing Tests** - Don't merge PRs with test failures
5. **Update Documentation** - Keep this README current

---

## Cost Considerations

GitHub Actions minutes are consumed by these workflows:

- **Swift Packages Coverage:** ~5-10 minutes per package (parallel)
- **Full Coverage Report:** ~30-45 minutes (sequential)
- **iOS CI:** ~10-15 minutes

**Optimization Tips:**
- Caching reduces build times significantly
- Parallel execution saves time
- Manual triggers prevent unnecessary runs
- Consider limiting to main branch for weekly reports

---

## Future Enhancements

Potential improvements:

- [ ] Coverage trend graphs
- [ ] Integration with code coverage services (Codecov, Coveralls)
- [ ] Slack/Discord notifications
- [ ] Coverage diff between base and PR
- [ ] Automatic PR reviews based on coverage
- [ ] Historical coverage database
- [ ] Coverage badges in README

---

## Support

For issues or questions:
- Check workflow logs first
- Review this documentation
- See `scripts/README.md` for script details
- Create an issue with relevant logs
