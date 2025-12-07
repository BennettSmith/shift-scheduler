# Troop 900 Tree Lot - Development Environment Setup

**Project:** Troop 900 Tree Lot Shift Scheduler  
**Repository Type:** Mono-repo  
**Version Control:** GitHub (`shift-scheduler` repository)  
**CI/CD:** GitHub Actions

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Repository Structure](#repository-structure)
3. [Initial Setup](#initial-setup)
4. [iOS Development Setup](#ios-development-setup)
5. [Android Development Setup](#android-development-setup)
6. [Firebase & Cloud Functions Setup](#firebase--cloud-functions-setup)
7. [GitHub Repository Setup](#github-repository-setup)
8. [GitHub Actions CI/CD Setup](#github-actions-cicd-setup)
9. [Local Development Workflow](#local-development-workflow)
10. [Team Collaboration](#team-collaboration)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

**For All Developers:**
- Git 2.30+
- Node.js 18+ and npm
- A code editor (VS Code recommended)
- Firebase CLI (`npm install -g firebase-tools`)

**For iOS Development:**
- macOS 13.0+ (Ventura or later)
- Xcode 26 (includes Swift Package Manager and Swift Testing)
- Apple Developer Account ($99/year)

**For Android Development:**
- Android Studio Hedgehog (2023.1.1) or later
- JDK 17+
- Android SDK with API 28+ (included with Android Studio)
- Google Play Developer Account ($25 one-time)

**For Firebase:**
- Firebase account (free tier sufficient)
- Firebase project created (for example: `shift-scheduler-d5a37`)

---

## Repository Structure

The mono-repo will be organized as follows:

```
shift-scheduler/
├── .github/
│   └── workflows/           # GitHub Actions CI/CD
│       ├── ios-ci.yml
│       ├── android-ci.yml
│       └── functions-ci.yml
├── ios/                     # iOS application
│   ├── TreeLot/
│   ├── TreeLot.xcodeproj/
│   ├── TreeLotTests/
│   └── README.md
├── android/                 # Android application
│   ├── app/
│   ├── build.gradle
│   ├── settings.gradle
│   └── README.md
├── functions/               # Firebase Cloud Functions
│   ├── src/
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
├── shared/                  # Shared resources
│   ├── docs/
│   ├── assets/
│   └── configs/
│       ├── firebase-config.json
│       └── GoogleService-Info.plist
├── .gitignore
├── .firebaserc
├── firebase.json
├── package.json             # Root package.json for tooling
└── README.md
```

---

## Initial Setup

### Step 1: Install Core Tools

**1. Install Homebrew (macOS):**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2. Install Node.js and npm:**
```bash
brew install node@18
node --version  # Should be 18.x or higher
npm --version
```

**3. Install Git:**
```bash
brew install git
git --version
```

**4. Install Firebase CLI:**
```bash
npm install -g firebase-tools
firebase --version
```

**5. Verify installations:**
```bash
# Check all tools
node --version
npm --version
git --version
firebase --version
```

### Step 2: Configure Git

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Enable helpful settings
git config --global pull.rebase false
git config --global core.autocrlf input
```

### Step 3: Create GitHub Account & SSH Keys

**1. Create GitHub account:**
- Go to https://github.com
- Sign up for a free account

**2. Generate SSH key:**
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
# Press Enter to accept default location
# Enter a passphrase (optional but recommended)
```

**3. Add SSH key to ssh-agent:**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**4. Add SSH key to GitHub:**
```bash
# Copy the public key
cat ~/.ssh/id_ed25519.pub
# Copy the output

# Go to GitHub → Settings → SSH and GPG keys → New SSH key
# Paste the key and save
```

**5. Test connection:**
```bash
ssh -T git@github.com
# Should see: "Hi username! You've successfully authenticated..."
```

---

## iOS Development Setup

### Step 1: Install Xcode

**1. Install Xcode from App Store:**
- Open App Store
- Search for "Xcode"
- Install (this takes a while, ~15GB download)

**2. Install Command Line Tools:**
```bash
xcode-select --install
```

**3. Verify Xcode installation:**
```bash
xcodebuild -version
# Should show: Xcode 15.x
```

**4. Accept Xcode license:**
```bash
sudo xcodebuild -license accept
```

### Step 3: Configure Xcode Settings

**1. Open Xcode:**
- Launch Xcode
- Go to Xcode → Settings (or Preferences)

**2. Configure Accounts:**
- Settings → Accounts
- Click "+" → Add Apple ID
- Sign in with your Apple Developer account

**3. Configure Teams:**
- Select your Apple ID
- Manage Certificates → "+" → Apple Development
- Note your Team ID (you'll need this)

### Step 4: Add Firebase SDK via Swift Package Manager

**1. Open Xcode project:**
- File → Open → Navigate to `ios/TreeLot.xcodeproj`

**2. Add Firebase package:**
- File → Add Package Dependencies
- Enter URL: `https://github.com/firebase/firebase-ios-sdk`
- Dependency Rule: Up to Next Major Version → 10.18.0
- Click "Add Package"

**3. Select Firebase products:**
- ✓ FirebaseAuth
- ✓ FirebaseFirestore
- ✓ FirebaseMessaging
- ✓ FirebaseFunctions
- Click "Add Package"

**4. Verify installation:**
- Project Navigator → Package Dependencies
- Should see "firebase-ios-sdk" listed

> **Note:** Swift Package Manager will automatically manage dependencies. No need for Podfile or workspace files.

### Step 5: Install iOS Simulators

**1. Open Xcode:**
- Xcode → Settings → Platforms

**2. Download iOS 16+ Simulator:**
- Click "+" button
- Download latest iOS simulator
- Wait for download to complete

---

## Android Development Setup

### Step 1: Install Android Studio

**1. Download Android Studio:**
- Go to https://developer.android.com/studio
- Download Android Studio Hedgehog or later

**2. Install Android Studio:**
- Open the downloaded .dmg file
- Drag Android Studio to Applications
- Launch Android Studio

**3. Complete Setup Wizard:**
- Standard installation
- Select theme (your preference)
- Download SDK components (accept defaults)
- Wait for downloads to complete

### Step 2: Configure Android SDK

**1. Open SDK Manager:**
- Android Studio → Settings → Appearance & Behavior → System Settings → Android SDK

**2. Install Required SDKs:**
- SDK Platforms tab:
  - ✓ Android 14.0 (API 34) - latest
  - ✓ Android 13.0 (API 33)
  - ✓ Android 9.0 (API 28) - minimum required
  
**3. Install SDK Tools:**
- SDK Tools tab:
  - ✓ Android SDK Build-Tools
  - ✓ Android SDK Platform-Tools
  - ✓ Android Emulator
  - ✓ Android SDK Tools
  - ✓ Google Play services

**4. Note SDK location:**
```
Usually: ~/Library/Android/sdk
```

### Step 3: Set Environment Variables

**1. Edit shell profile:**
```bash
# For zsh (default on macOS)
nano ~/.zshrc

# Or for bash
nano ~/.bashrc
```

**2. Add Android environment variables:**
```bash
# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

**3. Apply changes:**
```bash
source ~/.zshrc  # or ~/.bashrc
```

**4. Verify:**
```bash
echo $ANDROID_HOME
adb --version
```

### Step 4: Create Android Emulator

**1. Open AVD Manager:**
- Android Studio → Tools → Device Manager

**2. Create Virtual Device:**
- Click "Create Device"
- Select: Pixel 6 (or similar modern device)
- Download system image: Android 13 (API 33) or later
- Finish setup
- Start the emulator to test

---

## Firebase & Cloud Functions Setup

### Step 1: Install Firebase CLI (Already Done)

Verify Firebase CLI is installed:
```bash
firebase --version
```

### Step 2: Login to Firebase

```bash
# Login to Firebase
firebase login

# Follow the browser authentication flow
# Grant Firebase CLI permissions
```

### Step 3: Set Up Local Firebase Project

**1. Clone repository (we'll create this next):**
```bash
cd ~/Developer  # or your preferred location
git clone git@github.com:YOUR-USERNAME/troop900-tree-lot.git
cd troop900-tree-lot
```

**2. Initialize Firebase (if not already done):**
```bash
firebase init

# Select the following:
# - Firestore
# - Functions
# - Storage
# - Emulators

# Project Setup:
# - Use existing project → troop900-tree-lot

# Firestore Setup:
# - Use default firestore.rules
# - Use default firestore.indexes.json

# Functions Setup:
# - Language: TypeScript
# - ESLint: Yes
# - Install dependencies: Yes

# Storage Setup:
# - Use default storage.rules

# Emulators:
# - Select: Authentication, Firestore, Functions, Storage
# - Accept default ports
# - Enable Emulator UI: Yes
# - Download emulators now: Yes
```

### Step 4: Configure Firebase Functions

**1. Navigate to functions directory:**
```bash
cd functions
```

**2. Install additional dependencies:**
```bash
npm install firebase-admin firebase-functions
npm install -D @types/node typescript
```

**3. Update package.json:**
```json
{
  "name": "functions",
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js",
  "scripts": {
    "lint": "eslint --ext .js,.ts .",
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  }
}
```

### Step 5: Test Firebase Emulators

```bash
# From project root
firebase emulators:start

# You should see:
# ✓ Emulator UI running at http://localhost:4000
# ✓ Authentication Emulator running at http://localhost:9099
# ✓ Firestore Emulator running at http://localhost:8080
# ✓ Functions Emulator running at http://localhost:5001
```

**Stop emulators:** Press Ctrl+C

---

## GitHub Repository Setup

### Step 1: Create GitHub Repository

**1. Go to GitHub:**
- Navigate to https://github.com/new

**2. Create repository:**
- Repository name: `troop900-tree-lot`
- Description: "Mobile shift scheduling app for Troop 900's Christmas tree lot fundraiser"
- Private repository (recommended)
- Do NOT initialize with README (we'll push existing code)

**3. Note the repository URL:**
```
git@github.com:YOUR-USERNAME/troop900-tree-lot.git
```

### Step 2: Initialize Local Repository

**1. Create initial project structure:**
```bash
cd ~/Developer
mkdir troop900-tree-lot
cd troop900-tree-lot

# Create directory structure
mkdir -p ios android functions shared/docs shared/assets shared/configs .github/workflows
```

**2. Create root .gitignore:**
```bash
cat > .gitignore << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Node
node_modules/
npm-debug.log
yarn-error.log

# Firebase
.firebase/
*.cache

# iOS
ios/build/
ios/DerivedData/
ios/.swiftpm/
ios/*.xcworkspace/xcuserdata/

# Android
android/.gradle/
android/build/
android/app/build/
android/local.properties

# Secrets
*.env
*.env.local
google-services.json
GoogleService-Info.plist
firebase-config.json

# Temp
*.tmp
.tmp/
EOF
```

**3. Create README.md:**
```bash
cat > README.md << 'EOF'
# Troop 900 Tree Lot Shift Scheduler

Mobile-first application for managing volunteer scheduling for Troop 900's annual Christmas tree lot fundraiser.

## Tech Stack

- **iOS:** Swift 5.9+, SwiftUI, Firebase iOS SDK
- **Android:** Kotlin 1.9+, Jetpack Compose, Firebase Android SDK
- **Backend:** Firebase (Firestore, Auth, Functions, Cloud Messaging)
- **CI/CD:** GitHub Actions

## Getting Started

See [Development Setup Guide](docs/troop900-dev-setup.md) for detailed setup instructions.

## Repository Structure

- `/ios` - iOS application
- `/android` - Android application
- `/functions` - Firebase Cloud Functions
- `/shared` - Shared resources and documentation

## Development

- [Setup Guide](docs/troop900-dev-setup.md)
- [Architecture](docs/troop900-firebase-architecture.md)
- [Implementation Guide](docs/troop900-firebase-implementation-guide.md)

## License

Private - Troop 900 Internal Use Only
EOF
```

**4. Initialize Git repository:**
```bash
git init
git add .
git commit -m "Initial commit: Project structure"
```

**5. Connect to GitHub:**
```bash
git remote add origin git@github.com:YOUR-USERNAME/troop900-tree-lot.git
git branch -M main
git push -u origin main
```

### Step 3: Set Up Branch Protection

**1. Go to repository settings:**
- GitHub → Your Repository → Settings → Branches

**2. Add branch protection rule:**
- Branch name pattern: `main`
- Enable:
  - ✓ Require pull request reviews before merging
  - ✓ Require status checks to pass before merging
  - ✓ Require branches to be up to date before merging
  - ✓ Include administrators

**3. Save changes**

---

## GitHub Actions CI/CD Setup

### Step 1: Create iOS CI Workflow

**1. Create workflow file:**
```bash
mkdir -p .github/workflows
cat > .github/workflows/ios-ci.yml << 'EOF'
name: iOS CI

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'ios/**'
      - '.github/workflows/ios-ci.yml'
  pull_request:
    branches: [ main, develop ]
    paths:
      - 'ios/**'

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.0'
    
    - name: Build
      run: |
        cd ios
        xcodebuild -project TreeLot.xcodeproj \
                   -scheme TreeLot \
                   -sdk iphonesimulator \
                   -destination 'platform=iOS Simulator,name=iPhone 15' \
                   clean build
    
    - name: Run Tests
      run: |
        cd ios
        xcodebuild test -project TreeLot.xcodeproj \
                       -scheme TreeLot \
                       -sdk iphonesimulator \
                       -destination 'platform=iOS Simulator,name=iPhone 15'
EOF
```

### Step 2: Create Android CI Workflow

**1. Create workflow file:**
```bash
cat > .github/workflows/android-ci.yml << 'EOF'
name: Android CI

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'android/**'
      - '.github/workflows/android-ci.yml'
  pull_request:
    branches: [ main, develop ]
    paths:
      - 'android/**'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: gradle
    
    - name: Grant execute permission for gradlew
      run: chmod +x android/gradlew
    
    - name: Build with Gradle
      run: |
        cd android
        ./gradlew build
    
    - name: Run Tests
      run: |
        cd android
        ./gradlew test
    
    - name: Run Lint
      run: |
        cd android
        ./gradlew lint
EOF
```

### Step 3: Create Firebase Functions CI Workflow

**1. Create workflow file:**
```bash
cat > .github/workflows/functions-ci.yml << 'EOF'
name: Firebase Functions CI

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'functions/**'
      - '.github/workflows/functions-ci.yml'
  pull_request:
    branches: [ main, develop ]
    paths:
      - 'functions/**'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: 'functions/package-lock.json'
    
    - name: Install dependencies
      run: |
        cd functions
        npm ci
    
    - name: Run Lint
      run: |
        cd functions
        npm run lint
    
    - name: Build
      run: |
        cd functions
        npm run build
    
    - name: Run Tests
      run: |
        cd functions
        npm test
EOF
```

### Step 4: Set Up GitHub Secrets

**1. Go to repository settings:**
- GitHub → Your Repository → Settings → Secrets and variables → Actions

**2. Add secrets (you'll add these later as needed):**
- `FIREBASE_TOKEN` - For deploying functions
- `IOS_CERTIFICATE` - For iOS signing
- `ANDROID_KEYSTORE` - For Android signing

**3. Commit and push workflows:**
```bash
git add .github/workflows/
git commit -m "Add GitHub Actions CI/CD workflows"
git push
```

---

## Local Development Workflow

### Daily Development Routine

**1. Start your development session:**
```bash
cd ~/Developer/troop900-tree-lot

# Pull latest changes
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name
```

**2. Start Firebase emulators:**
```bash
# In one terminal window
firebase emulators:start
```

**3. iOS Development:**
```bash
# In another terminal
cd ios
open TreeLot.xcodeproj

# Xcode will open - run from there
# Swift Package Manager will automatically resolve dependencies
```

**4. Android Development:**
```bash
# Open Android Studio
# File → Open → select android/ folder
# Run from Android Studio
```

**5. Firebase Functions Development:**
```bash
cd functions

# Watch for changes and rebuild
npm run build -- --watch

# Test functions in emulator at http://localhost:5001
```

### Testing Changes

**1. Test locally:**
- iOS: Run in Simulator
- Android: Run in Emulator
- Functions: Test with emulator UI

**2. Commit your changes:**
```bash
git add .
git commit -m "feat: Add your feature description"
git push origin feature/your-feature-name
```

**3. Create Pull Request:**
- Go to GitHub
- Click "Pull requests" → "New pull request"
- Select your feature branch
- Add description
- Request review
- Wait for CI checks to pass

**4. Merge after approval:**
- Merge to develop branch
- Delete feature branch

### Deploying to Production

**1. Deploy Firebase Functions:**
```bash
cd functions
npm run deploy

# Or deploy specific function
firebase deploy --only functions:functionName
```

**2. Deploy iOS:**
- Update version number in Xcode
- Archive: Product → Archive
- Upload to App Store Connect
- Submit for review

**3. Deploy Android:**
- Update version in build.gradle
- Build → Generate Signed Bundle
- Upload to Google Play Console
- Submit for review

---

## Team Collaboration

### Branch Strategy

```
main                 (production)
  ↑
develop             (integration)
  ↑
feature/xyz         (your work)
```

**Branch naming conventions:**
- `feature/user-authentication` - New features
- `fix/crash-on-signup` - Bug fixes
- `chore/update-dependencies` - Maintenance
- `docs/setup-guide` - Documentation

### Commit Message Format

Follow conventional commits:

```
type(scope): Short description

Longer description if needed

Fixes #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, missing semicolons
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

**Examples:**
```bash
git commit -m "feat(auth): Add Sign in with Apple"
git commit -m "fix(shifts): Prevent duplicate shift signups"
git commit -m "docs(readme): Update setup instructions"
```

### Code Review Process

**1. Before requesting review:**
- ✓ All tests pass
- ✓ Code is linted
- ✓ Changes tested locally
- ✓ Documentation updated
- ✓ CI checks pass

**2. Pull request template:**
```markdown
## Description
Brief description of changes

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on iOS Simulator
- [ ] Tested on Android Emulator
- [ ] Tested with Firebase Emulator
- [ ] Unit tests added/updated

## Screenshots
(if applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings
```

---

## Troubleshooting

### Common Issues

**Issue: Swift Package Manager dependencies not resolving**
```bash
# Solution: Reset package cache
# In Xcode: File → Packages → Reset Package Caches
# Or via command line:
rm -rf ~/Library/Developer/Xcode/DerivedData
cd ios
xcodebuild -resolvePackageDependencies
```

**Issue: Firebase emulator won't start**
```bash
# Solution: Kill existing processes
lsof -ti:4000,5001,8080,9099 | xargs kill -9

# Clear cache and restart
firebase emulators:start --import=./emulator-data --export-on-exit
```

**Issue: Android Gradle build fails**
```bash
# Solution: Clean and rebuild
cd android
./gradlew clean
./gradlew build --refresh-dependencies
```

**Issue: Xcode build fails with signing errors**
```
# Solution: Check team selection
# Xcode → Project Settings → Signing & Capabilities
# Ensure correct team is selected
```

**Issue: GitHub Actions failing**
```bash
# Solution: Check workflow logs
# GitHub → Actions → Failed workflow → View logs
# Common issues:
# - Secrets not configured
# - Dependencies out of date
# - Tests failing
```

### Getting Help

**1. Check documentation:**
- Firebase: https://firebase.google.com/docs
- iOS: https://developer.apple.com/documentation/
- Android: https://developer.android.com/docs

**2. Team communication:**
- Create issue on GitHub
- Ask in team Slack/Discord
- Schedule pair programming session

**3. Common commands:**
```bash
# Check tool versions
node --version
npm --version
firebase --version
xcodebuild -version

# Reset everything
cd ~/Developer/troop900-tree-lot
git clean -fdx
npm install
cd android && ./gradlew clean
```

---

## Next Steps

After completing this setup:

1. **Review architecture documentation:**
   - Read `troop900-firebase-architecture.md`
   - Read `troop900-firebase-implementation-guide.md`

2. **Set up Firebase project:**
   - Create Firebase project (if not exists)
   - Configure authentication providers
   - Set up Firestore database
   - Deploy initial Cloud Functions

3. **Configure mobile apps:**
   - Add Firebase configuration files
   - Set up app identifiers
   - Configure signing certificates

4. **Start development:**
   - Pick a feature from backlog
   - Create feature branch
   - Implement, test, and deploy

---

## Appendix

### Useful Commands Reference

**Git:**
```bash
git status
git branch
git checkout -b feature/name
git add .
git commit -m "message"
git push origin branch-name
git pull origin develop
```

**Firebase:**
```bash
firebase login
firebase projects:list
firebase use project-name
firebase emulators:start
firebase deploy
firebase deploy --only functions
firebase deploy --only firestore:rules
```

**iOS:**
```bash
cd ios
# Resolve Swift Package dependencies
xcodebuild -resolvePackageDependencies
# Clean build
xcodebuild clean build
# Reset package cache (if needed)
# In Xcode: File → Packages → Reset Package Caches
```

**Android:**
```bash
cd android
./gradlew clean
./gradlew build
./gradlew assembleDebug
./gradlew installDebug
```

**Node/npm:**
```bash
npm install
npm update
npm run build
npm test
npm run lint
```

### Environment Variables Template

Create `.env.local` (NOT committed to git):
```bash
# Firebase
FIREBASE_PROJECT_ID=troop900-tree-lot
FIREBASE_API_KEY=your-api-key

# iOS
IOS_BUNDLE_ID=com.troop900.treelot
IOS_TEAM_ID=your-team-id

# Android
ANDROID_PACKAGE_NAME=com.troop900.treelot
```

---

**End of Setup Guide**

For questions or issues, contact the technical lead or create an issue on GitHub.
