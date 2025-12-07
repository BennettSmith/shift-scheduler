# Troop 900 Firebase Implementation Guide
## Practical Guide to Building Your Tree Lot Shift Scheduler

**Version:** 1.1  
**Date:** December 2024  
**Audience:** Developers new to Firebase  
**Companion Document:** troop900-firebase-architecture.md

---

## Table of Contents

1. [Introduction](#introduction)
2. [Firebase Project Setup](#firebase-project-setup)
3. [Firebase Authentication Deep Dive](#firebase-authentication-deep-dive)
4. [Cloud Firestore Implementation](#cloud-firestore-implementation)
5. [Real-Time Data Synchronization](#real-time-data-synchronization)
6. [Firestore Schema Versioning](#firestore-schema-versioning)
7. [Cloud Functions Development](#cloud-functions-development)
8. [Firebase Cloud Messaging](#firebase-cloud-messaging)
9. [Security Rules Implementation](#security-rules-implementation)
10. [Mobile App Integration](#mobile-app-integration)
11. [Testing Strategy](#testing-strategy)
12. [Deployment & Monitoring](#deployment--monitoring)
13. [Common Patterns & Best Practices](#common-patterns--best-practices)
14. [Troubleshooting Guide](#troubleshooting-guide)

---

## Introduction

### What is Firebase?

Firebase is a Backend-as-a-Service (BaaS) platform by Google that provides everything you need to build a mobile app without managing your own servers. Think of it as getting a complete backend infrastructure without writing server code or managing databases.

**Key Benefits for This Project:**
- **No Server Management:** Firebase handles all infrastructure
- **Real-time Updates:** Changes sync instantly across all devices
- **Built-in Authentication:** No password management needed
- **Generous Free Tier:** Perfect for a small troop (40-50 users)
- **Automatic Scaling:** Handles traffic spikes without configuration
- **Native Mobile SDKs:** First-class iOS and Android support

### What You'll Build

You'll create a mobile app that uses Firebase for:
1. **Authentication:** Sign in with Apple/Google (no passwords to manage)
2. **Database:** Store families, shifts, assignments, messages
3. **Business Logic:** Cloud Functions for complex operations
4. **Notifications:** Push notifications for new shifts and reminders
5. **File Storage:** (Future) Store photos and documents

### Prerequisites

Before starting, you should have:
- Basic understanding of mobile development (iOS/Android)
- Node.js installed (v18 or higher)
- A Google account (for Firebase Console access)
- An Apple Developer account ($99/year - for iOS)
- A Google Play Developer account ($25 one-time - for Android)

---

## Firebase Project Setup

### Step 1: Create Firebase Project

1. **Go to Firebase Console:**
   - Visit https://console.firebase.google.com
   - Click "Add project"

2. **Configure Project:**
   - **Project name:** `troop900-tree-lot` (or your choice)
   - **Google Analytics:** Enable (recommended for tracking usage)
   - **Analytics location:** United States
   - **Accept terms** and click "Create project"

3. **Select Spark Plan (Free Tier):**
   - After project creation, verify you're on the free "Spark Plan"
   - Check under Project Settings > Usage and billing

### Step 2: Enable Firebase Services

In the Firebase Console, enable these services:

#### Authentication
```
Firebase Console > Build > Authentication > Get Started

Enabled Providers:
✅ Google
✅ Apple

Leave disabled:
❌ Email/Password (not needed)
❌ Phone (not needed)
❌ Anonymous (not needed)
```

#### Cloud Firestore
```
Firebase Console > Build > Firestore Database > Create database

Settings:
- Start in: Production mode (we'll add security rules later)
- Location: us-central1 (or closest to your users)
- Type: Native mode (not Datastore mode)
```

#### Cloud Functions
```
Firebase Console > Build > Functions > Get Started

This will be set up via Firebase CLI later
```

#### Cloud Messaging
```
Firebase Console > Build > Cloud Messaging > Get Started

No configuration needed initially
```

### Step 3: Install Firebase CLI

The Firebase CLI lets you deploy functions and manage your project from the command line.

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Verify installation
firebase --version

# Login to your Google account
firebase login

# This opens a browser for authentication
# Select the account you used to create the Firebase project
```

### Step 4: Initialize Firebase in Your Project

Create a new directory for your backend code:

```bash
# Create project directory
mkdir troop900-backend
cd troop900-backend

# Initialize Firebase
firebase init

# Select these features (use spacebar to select):
# ◉ Firestore: Configure security rules and indexes
# ◉ Functions: Configure a Cloud Functions directory
# ◯ Hosting (not needed)
# ◯ Storage (not needed initially)

# Follow prompts:
# - Select your Firebase project from the list
# - Use default names for files (firestore.rules, firestore.indexes.json)
# - Choose JavaScript or TypeScript (recommend TypeScript)
# - Install dependencies with npm: Yes
```

This creates:
```
troop900-backend/
├── firebase.json          # Firebase configuration
├── firestore.rules        # Security rules for Firestore
├── firestore.indexes.json # Database indexes
├── functions/             # Cloud Functions code
│   ├── src/
│   │   └── index.ts      # Your functions go here
│   ├── package.json
│   └── tsconfig.json
└── .firebaserc            # Project aliases
```

### Step 5: Add iOS App

```
Firebase Console > Project Overview > Add app > iOS

Settings:
- iOS bundle ID: com.troop900.treelot
- App nickname: Troop900 iOS
- Download GoogleService-Info.plist
- Add this file to your Xcode project
```

### Step 6: Add Android App

```
Firebase Console > Project Overview > Add app > Android

Settings:
- Android package name: com.troop900.treelot
- App nickname: Troop900 Android
- Download google-services.json
- Add this file to your Android project (app/ directory)
```

---

## Firebase Authentication Deep Dive

### What Authentication Provides

Firebase Authentication handles:
- **User sign-in/sign-up** via Apple or Google
- **Token management** (you never handle tokens directly)
- **Session persistence** (users stay logged in)
- **Security** (tokens are cryptographically signed)

**What you DON'T need to build:**
- Password storage or hashing
- "Forgot password" flows
- Email verification
- Session management
- Token refresh logic

### How Passwordless Auth Works

**Sign in with Apple/Google Flow:**

```
1. User taps "Sign in with Apple"
2. iOS/Android system handles authentication
3. Firebase gets a user token from Apple
4. Firebase creates a user account (or logs in existing user)
5. Your app gets a Firebase User object with:
   - uid: unique user ID (e.g., "abc123def456")
   - email: user's email
   - displayName: user's name
   - photoURL: profile picture URL
```

### iOS Implementation

#### 1. Install Firebase SDK via Swift Package Manager

```
In Xcode:
1. File > Add Package Dependencies...
2. Enter: https://github.com/firebase/firebase-ios-sdk
3. Select "Up to Next Major Version" (recommend 10.0.0 or higher)
4. Click "Add Package"
5. Select these products:
   ✅ FirebaseAuth
   ✅ FirebaseFirestore
   ✅ FirebaseMessaging
6. Click "Add Package"

For Google Sign-In:
1. File > Add Package Dependencies...
2. Enter: https://github.com/google/GoogleSignIn-iOS
3. Select "Up to Next Major Version" (recommend 7.0.0 or higher)
4. Click "Add Package"
5. Select "GoogleSignIn"
6. Click "Add Package"
```

**Note:** With SPM, you work directly with your .xcodeproj file (no .xcworkspace needed).

#### 2. Configure Firebase in AppDelegate

```swift
// AppDelegate.swift
import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Firebase (REQUIRED - do this first!)
        FirebaseApp.configure()
        
        return true
    }
}
```

#### 3. Enable Sign in with Apple

```
Xcode:
1. Select your project in navigator
2. Select your app target
3. Signing & Capabilities tab
4. Click "+ Capability"
5. Add "Sign in with Apple"
```

#### 4. Implement Sign in with Apple

```swift
// AuthenticationViewModel.swift
import SwiftUI
import AuthenticationServices
import Firebase
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // Check if user is already signed in
        self.user = Auth.auth().currentUser
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    func signInWithApple() {
        isLoading = true
        errorMessage = nil
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
}

// Handle Apple Sign-In callbacks
extension AuthenticationViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                  didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Failed to get Apple ID credential"
            isLoading = false
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            errorMessage = "Failed to get ID token"
            isLoading = false
            return
        }
        
        // Create Firebase credential
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nil // We're not using nonce for simplicity
        )
        
        // Sign in to Firebase
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Sign in failed: \(error.localizedDescription)"
                    return
                }
                
                // Success! User is now signed in
                self?.user = result?.user
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                  didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
    }
}
```

#### 5. Create Sign-In View

```swift
// SignInView.swift
import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tree.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Troop 900")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tree Lot Shift Scheduler")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                // Apple Sign-In Button
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    viewModel.signInWithApple()
                }
                .frame(height: 50)
                .cornerRadius(8)
                
                // Google Sign-In Button (implement similarly)
                Button(action: {
                    // Implement Google Sign-In
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Sign in with Google")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
```

### Android Implementation

#### 1. Add Firebase SDK to build.gradle

```kotlin
// Project-level build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

// App-level build.gradle
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'com.google.gms.google-services'  // Add this
}

dependencies {
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth-ktx'
    implementation 'com.google.firebase:firebase-firestore-ktx'
    implementation 'com.google.firebase:firebase-messaging-ktx'
    
    // Google Sign-In
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

#### 2. Initialize Firebase in Application Class

```kotlin
// Troop900Application.kt
import android.app.Application
import com.google.firebase.Firebase
import com.google.firebase.initialize

class Troop900Application : Application() {
    override fun onCreate() {
        super.onCreate()
        Firebase.initialize(this)  // Initialize Firebase
    }
}

// AndroidManifest.xml
<application
    android:name=".Troop900Application"
    ...>
```

#### 3. Implement Google Sign-In

```kotlin
// AuthViewModel.kt
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

class AuthViewModel : ViewModel() {
    private val auth = FirebaseAuth.getInstance()
    
    private val _user = MutableStateFlow<FirebaseUser?>(auth.currentUser)
    val user: StateFlow<FirebaseUser?> = _user
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading
    
    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error
    
    init {
        // Listen for auth state changes
        auth.addAuthStateListener { firebaseAuth ->
            _user.value = firebaseAuth.currentUser
        }
    }
    
    fun getGoogleSignInClient(context: Context): GoogleSignInClient {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(context.getString(R.string.default_web_client_id))
            .requestEmail()
            .build()
        
        return GoogleSignIn.getClient(context, gso)
    }
    
    fun signInWithGoogle(account: GoogleSignInAccount) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            
            try {
                val credential = GoogleAuthProvider.getCredential(account.idToken, null)
                auth.signInWithCredential(credential).await()
                // Success! _user will be updated via auth state listener
            } catch (e: Exception) {
                _error.value = "Sign in failed: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun signOut(context: Context) {
        auth.signOut()
        getGoogleSignInClient(context).signOut()
    }
}
```

#### 4. Create Sign-In Screen with Jetpack Compose

```kotlin
// SignInScreen.kt
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.common.api.ApiException

@Composable
fun SignInScreen(viewModel: AuthViewModel) {
    val context = LocalContext.current
    val user by viewModel.user.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()
    
    // Launcher for Google Sign-In
    val launcher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
        try {
            val account = task.getResult(ApiException::class.java)
            viewModel.signInWithGoogle(account)
        } catch (e: ApiException) {
            // Handle error
        }
    }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            painter = painterResource(id = R.drawable.ic_tree),
            contentDescription = null,
            modifier = Modifier.size(80.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Text(
            text = "Troop 900",
            style = MaterialTheme.typography.headlineLarge
        )
        
        Text(
            text = "Tree Lot Shift Scheduler",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        
        Spacer(modifier = Modifier.weight(1f))
        
        if (isLoading) {
            CircularProgressIndicator()
        } else {
            Button(
                onClick = {
                    val signInIntent = viewModel.getGoogleSignInClient(context).signInIntent
                    launcher.launch(signInIntent)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Icon(
                        painter = painterResource(id = R.drawable.ic_google),
                        contentDescription = null,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Sign in with Google")
                }
            }
        }
        
        error?.let { errorMessage ->
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = errorMessage,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall
            )
        }
    }
}
```

### Key Authentication Concepts

#### 1. User UID
Every authenticated user gets a unique ID (UID):
```swift
// Get current user's UID
let uid = Auth.auth().currentUser?.uid

// This UID is:
// - Permanent (never changes)
// - Unique (no two users have the same UID)
// - Used as the document ID in Firestore
```

#### 2. Authentication State
Your app should respond to authentication changes:
```swift
Auth.auth().addStateDidChangeListener { auth, user in
    if let user = user {
        // User is signed in
        print("Signed in as: \(user.uid)")
    } else {
        // User is signed out
        print("No user signed in")
    }
}
```

#### 3. Checking Auth Status
On app launch, check if user is already signed in:
```swift
if let user = Auth.auth().currentUser {
    // User is signed in, show main app
    showMainView()
} else {
    // No user, show sign-in screen
    showSignInView()
}
```

---

## Cloud Firestore Implementation

### What is Firestore?

Firestore is a **NoSQL document database** that syncs data in real-time across all connected devices. Unlike traditional SQL databases with tables and rows, Firestore uses **collections** and **documents**.

**Key Concepts:**
- **Document:** A single record (like a JSON object)
- **Collection:** A group of documents (like a table)
- **Real-time:** Changes sync instantly to all listeners
- **Offline:** Works offline, syncs when back online

### Database Structure Overview

Your app uses 10 collections:

```
firestore-root/
├── families/              # Household groups
├── family-units/          # Family unit groupings for leaderboards
├── household-links/       # Codes for linking scouts to multiple households
├── users/                 # All people (parents and scouts)
├── invite-codes/          # One-time codes for family signup
├── shifts/                # Work shifts at the tree lot
├── shift-templates/       # Reusable shift templates
├── assignments/           # Who's signed up for which shift
├── attendance/            # Check-in/check-out records
└── messages/              # Announcements from committee
```

### Understanding Documents & Collections

**Example Document Structure:**

```javascript
// Collection: users
// Document ID: "abc123def456" (the user's UID)
{
  uid: "abc123def456",
  email: "john@example.com",
  firstName: "John",
  lastName: "Smith",
  role: "parent",
  householdIds: ["household-1"],
  familyUnitId: "family-unit-1",
  canManageFamily: true,
  isActive: true,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Collection Details

#### 1. families Collection

Represents a household (e.g., "Smith Household" or "Mom's House").

**Document ID:** Auto-generated (e.g., "household-abc123")

**Document Structure:**
```javascript
{
  familyName: string,           // "Smith Household"
  inviteCodeId: string,          // Reference to invite-codes doc
  primaryParentId: string,       // UID of account holder
  familyUnitId: string,          // Reference to family-units doc
  members: [                     // Array of member references
    {
      userId: string,            // UID of user
      role: string,              // "parent" or "scout"
      addedBy: string,           // UID who added them
      addedAt: Timestamp
    }
  ],
  isActive: boolean,             // Can this family use the app?
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Why it's needed:**
- Groups users into households
- Tracks who belongs to which household
- Supports multi-household membership (divorced parents)

**Example Code:**

```swift
// iOS: Create a new household
func createHousehold(familyName: String, primaryParentId: String) async throws {
    let db = Firestore.firestore()
    
    let familyData: [String: Any] = [
        "familyName": familyName,
        "primaryParentId": primaryParentId,
        "familyUnitId": "", // Will be set when family unit is created
        "members": [],
        "isActive": true,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp()
    ]
    
    try await db.collection("families").addDocument(data: familyData)
}

// iOS: Get all members of a household
func getHouseholdMembers(householdId: String) async throws -> [User] {
    let db = Firestore.firestore()
    
    // Get the household document
    let householdDoc = try await db.collection("families").document(householdId).getDocument()
    guard let members = householdDoc.data()?["members"] as? [[String: Any]] else {
        return []
    }
    
    // Get user documents for each member
    var users: [User] = []
    for member in members {
        if let userId = member["userId"] as? String {
            let userDoc = try await db.collection("users").document(userId).getDocument()
            if let user = try? userDoc.data(as: User.self) {
                users.append(user)
            }
        }
    }
    
    return users
}
```

#### 2. family-units Collection

Groups multiple households that represent the same family (for leaderboards).

**Document ID:** Auto-generated (e.g., "family-unit-123")

**Document Structure:**
```javascript
{
  unitName: string,              // "Smith Family"
  householdIds: [string],        // ["household-1", "household-2"]
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Why it's needed:**
- Combines divorced parents' households for leaderboard purposes
- Example: "Mom's House" + "Dad's House" = "Smith Family Unit"

**Example Code:**

```kotlin
// Android: Get family unit with all households
suspend fun getFamilyUnitDetails(familyUnitId: String): FamilyUnitDetails {
    val db = Firebase.firestore
    
    // Get family unit
    val unitDoc = db.collection("family-units")
        .document(familyUnitId)
        .get()
        .await()
    
    val householdIds = unitDoc.get("householdIds") as? List<String> ?: emptyList()
    
    // Get all households in this family unit
    val households = householdIds.map { householdId ->
        db.collection("families")
            .document(householdId)
            .get()
            .await()
            .toObject(Household::class.java)
    }
    
    return FamilyUnitDetails(
        id = familyUnitId,
        name = unitDoc.getString("unitName") ?: "",
        households = households
    )
}
```

#### 3. users Collection

Stores information about every person (both parents and scouts).

**Document ID:** The user's Firebase Auth UID

**Document Structure:**
```javascript
{
  uid: string,                   // Same as document ID
  email: string,                 // From Firebase Auth
  firstName: string,
  lastName: string,
  phoneNumber: string,           // Optional
  role: string,                  // "admin", "committee", "parent", "scout"
  householdIds: [string],        // Can be in multiple households!
  familyUnitId: string,          // Reference to family-units doc
  canManageFamily: boolean,      // Can add/remove family members?
  profileClaimCode: string,      // For unclaimed scouts
  isClaimed: boolean,            // Has scout claimed their profile?
  isActive: boolean,
  fcmTokens: [string],           // Device tokens for push notifications
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Key Points:**
- **Document ID = UID** makes queries efficient
- **householdIds array** allows multi-household membership
- **isClaimed** distinguishes between parent-managed and self-managed scouts

**Example Code:**

```swift
// iOS: Get user by UID
func getUser(uid: String) async throws -> User {
    let db = Firestore.firestore()
    let doc = try await db.collection("users").document(uid).getDocument()
    return try doc.data(as: User.self)
}

// iOS: Get all scouts in a household
func getScoutsInHousehold(householdId: String) async throws -> [User] {
    let db = Firestore.firestore()
    
    let snapshot = try await db.collection("users")
        .whereField("householdIds", arrayContains: householdId)
        .whereField("role", isEqualTo: "scout")
        .getDocuments()
    
    return snapshot.documents.compactMap { doc in
        try? doc.data(as: User.self)
    }
}

// iOS: Update user's FCM token for push notifications
func updateFCMToken(uid: String, token: String) async throws {
    let db = Firestore.firestore()
    try await db.collection("users").document(uid).updateData([
        "fcmTokens": FieldValue.arrayUnion([token])
    ])
}
```

#### 4. shifts Collection

Represents work shifts at the tree lot.

**Document ID:** Auto-generated (e.g., "shift-xyz789")

**Document Structure:**
```javascript
{
  date: Timestamp,               // When the shift occurs
  startTime: Timestamp,          // Shift start
  endTime: Timestamp,            // Shift end
  title: string,                 // "Friday Evening" or "Holiday Special"
  description: string,           // "Setup and tree sales"
  requiredVolunteers: number,    // How many people needed
  assignedCount: number,         // How many signed up (calculated)
  shiftType: string,             // "regular", "setup", "teardown", "special"
  templateId: string,            // Reference to shift-templates (if used)
  isDraft: boolean,              // Is this published yet?
  createdBy: string,             // UID of admin/committee who created it
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Why we track assignedCount:**
- Allows quick "is this shift full?" checks
- Updated automatically by Cloud Functions

**Example Code:**

```kotlin
// Android: Get all published shifts for a date range
suspend fun getShiftsForWeek(startDate: Date, endDate: Date): List<Shift> {
    val db = Firebase.firestore
    
    val snapshot = db.collection("shifts")
        .whereEqualTo("isDraft", false)
        .whereGreaterThanOrEqualTo("date", Timestamp(startDate))
        .whereLessThanOrEqualTo("date", Timestamp(endDate))
        .orderBy("date")
        .orderBy("startTime")
        .get()
        .await()
    
    return snapshot.documents.mapNotNull { doc ->
        doc.toObject(Shift::class.java)
    }
}

// Android: Listen to shift changes in real-time
fun observeShift(shiftId: String, onUpdate: (Shift?) -> Unit): ListenerRegistration {
    val db = Firebase.firestore
    
    return db.collection("shifts")
        .document(shiftId)
        .addSnapshotListener { snapshot, error ->
            if (error != null) {
                onUpdate(null)
                return@addSnapshotListener
            }
            
            val shift = snapshot?.toObject(Shift::class.java)
            onUpdate(shift)
        }
}
```

#### 5. shift-templates Collection

Reusable templates for creating shifts (weekdays, weekends, etc.).

**Document ID:** Auto-generated (e.g., "template-abc123")

**Document Structure:**
```javascript
{
  name: string,                  // "Friday Evening Template"
  dayOfWeek: number,             // 0=Sunday, 1=Monday, ..., 5=Friday
  startTimeOffset: number,       // Hours from midnight (e.g., 17 = 5 PM)
  duration: number,              // Hours (e.g., 4 = 4-hour shift)
  requiredVolunteers: number,    // Default capacity
  shiftType: string,             // "regular", "setup", etc.
  description: string,
  isActive: boolean,             // Can this template be used?
  createdBy: string,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**How it works:**
- Committee creates templates once
- Cloud Function generates multiple shifts from templates
- Example: "Friday Evening" template generates a shift for every Friday

**Example Code:**

```swift
// iOS: Get all active templates
func getActiveTemplates() async throws -> [ShiftTemplate] {
    let db = Firestore.firestore()
    
    let snapshot = try await db.collection("shift-templates")
        .whereField("isActive", isEqualTo: true)
        .order(by: "dayOfWeek")
        .order(by: "startTimeOffset")
        .getDocuments()
    
    return snapshot.documents.compactMap { doc in
        try? doc.data(as: ShiftTemplate.self)
    }
}
```

#### 6. assignments Collection

Tracks who is signed up for which shifts.

**Document ID:** Auto-generated (e.g., "assignment-123")

**Document Structure:**
```javascript
{
  shiftId: string,               // Reference to shifts doc
  userId: string,                // Who is assigned
  assignedBy: string,            // Who made the assignment
  householdId: string,           // Which household made the assignment
  status: string,                // "confirmed", "cancelled"
  checkInTime: Timestamp,        // When they checked in (null if not checked in)
  checkOutTime: Timestamp,       // When they checked out
  hoursWorked: number,           // Calculated from check-in/out
  wasWalkIn: boolean,            // Did they sign up on the spot?
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Important Fields:**
- **assignedBy**: Tracks who made the assignment (for permission checks)
- **householdId**: Tracks which household made the assignment
- **wasWalkIn**: Distinguishes pre-planned vs. on-the-spot signups

**Example Code:**

```swift
// iOS: Get all assignments for a shift
func getShiftAssignments(shiftId: String) async throws -> [Assignment] {
    let db = Firestore.firestore()
    
    let snapshot = try await db.collection("assignments")
        .whereField("shiftId", isEqualTo: shiftId)
        .whereField("status", isEqualTo: "confirmed")
        .getDocuments()
    
    return snapshot.documents.compactMap { doc in
        try? doc.data(as: Assignment.self)
    }
}

// iOS: Get user's upcoming shifts
func getUserUpcomingShifts(userId: String) async throws -> [(Shift, Assignment)] {
    let db = Firestore.firestore()
    
    // Get assignments
    let assignmentSnapshot = try await db.collection("assignments")
        .whereField("userId", isEqualTo: userId)
        .whereField("status", isEqualTo: "confirmed")
        .getDocuments()
    
    var results: [(Shift, Assignment)] = []
    
    for doc in assignmentSnapshot.documents {
        let assignment = try doc.data(as: Assignment.self)
        
        // Get the shift details
        let shiftDoc = try await db.collection("shifts")
            .document(assignment.shiftId)
            .getDocument()
        
        if let shift = try? shiftDoc.data(as: Shift.self),
           shift.date.dateValue() > Date() {  // Only future shifts
            results.append((shift, assignment))
        }
    }
    
    return results.sorted { $0.0.date.dateValue() < $1.0.date.dateValue() }
}
```

#### 7. attendance Collection

Records check-ins and check-outs for accountability.

**Document ID:** `{shiftId}_{userId}` (composite key)

**Document Structure:**
```javascript
{
  shiftId: string,
  userId: string,
  checkInTime: Timestamp,
  checkInBy: string,             // Who checked them in
  checkOutTime: Timestamp,
  checkOutBy: string,            // Who checked them out
  hoursWorked: number,           // Auto-calculated
  notes: string,                 // Optional notes
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Composite Key Benefits:**
- Prevents duplicate check-ins
- Easy to query by shift or user
- Efficient lookups

**Example Code:**

```kotlin
// Android: Check in a user
suspend fun checkInUser(shiftId: String, userId: String, checkInBy: String) {
    val db = Firebase.firestore
    val docId = "${shiftId}_${userId}"
    
    val attendanceData = hashMapOf(
        "shiftId" to shiftId,
        "userId" to userId,
        "checkInTime" to FieldValue.serverTimestamp(),
        "checkInBy" to checkInBy,
        "createdAt" to FieldValue.serverTimestamp(),
        "updatedAt" to FieldValue.serverTimestamp()
    )
    
    db.collection("attendance")
        .document(docId)
        .set(attendanceData)
        .await()
}

// Android: Check out a user and calculate hours
suspend fun checkOutUser(shiftId: String, userId: String, checkOutBy: String) {
    val db = Firebase.firestore
    val docId = "${shiftId}_${userId}"
    
    // Get check-in time
    val doc = db.collection("attendance").document(docId).get().await()
    val checkInTime = doc.getTimestamp("checkInTime")
    
    if (checkInTime != null) {
        val now = Timestamp.now()
        val hoursWorked = (now.seconds - checkInTime.seconds) / 3600.0
        
        db.collection("attendance")
            .document(docId)
            .update(
                mapOf(
                    "checkOutTime" to now,
                    "checkOutBy" to checkOutBy,
                    "hoursWorked" to hoursWorked,
                    "updatedAt" to FieldValue.serverTimestamp()
                )
            )
            .await()
    }
}

// Android: Get attendance for a shift
suspend fun getShiftAttendance(shiftId: String): List<AttendanceRecord> {
    val db = Firebase.firestore
    
    val snapshot = db.collection("attendance")
        .whereEqualTo("shiftId", shiftId)
        .orderBy("checkInTime")
        .get()
        .await()
    
    return snapshot.documents.mapNotNull { doc ->
        doc.toObject(AttendanceRecord::class.java)
    }
}
```

#### 8. messages Collection

Committee announcements and notifications.

**Document ID:** Auto-generated

**Document Structure:**
```javascript
{
  title: string,
  body: string,
  sentBy: string,                // UID of sender
  sentAt: Timestamp,
  targetAudience: string,        // "all", "parents", "scouts", "committee"
  priority: string,              // "normal", "high"
  readBy: [string],              // Array of UIDs who have read it
}
```

**Example Code:**

```swift
// iOS: Get unread messages for user
func getUnreadMessages(userId: String) async throws -> [Message] {
    let db = Firestore.firestore()
    
    let snapshot = try await db.collection("messages")
        .order(by: "sentAt", descending: true)
        .limit(to: 50)
        .getDocuments()
    
    return snapshot.documents.compactMap { doc -> Message? in
        guard let message = try? doc.data(as: Message.self) else { return nil }
        
        // Check if user has read it
        let readBy = message.readBy ?? []
        if !readBy.contains(userId) {
            return message
        }
        return nil
    }
}

// iOS: Mark message as read
func markMessageAsRead(messageId: String, userId: String) async throws {
    let db = Firestore.firestore()
    try await db.collection("messages").document(messageId).updateData([
        "readBy": FieldValue.arrayUnion([userId])
    ])
}
```

### Firestore Best Practices

#### 1. Always Use Timestamps

```javascript
// ✅ GOOD: Let Firestore set server timestamp
{
  createdAt: FieldValue.serverTimestamp(),
  updatedAt: FieldValue.serverTimestamp()
}

// ❌ BAD: Client timestamps can be wrong (wrong timezone, manipulated clock)
{
  createdAt: Date.now()
}
```

#### 2. Denormalize When Needed

```javascript
// Instead of this (requires extra query):
assignments: {
  shiftId: "shift-123",
  // Need to query shifts collection to get shift details
}

// Do this (faster reads, some data duplication):
assignments: {
  shiftId: "shift-123",
  shiftDate: Timestamp,      // Denormalized for faster queries
  shiftTitle: "Friday Evening" // Denormalized for display
}
```

#### 3. Use Composite Indexes

For complex queries, you need indexes. Firestore will tell you when:

```swift
// This query needs a composite index:
try await db.collection("shifts")
    .whereField("isDraft", isEqualTo: false)
    .whereField("date", isGreaterThan: Date())
    .order(by: "date")
    .getDocuments()

// Firestore error will give you the index creation link
// Click the link, it auto-creates the index
```

---

## Real-Time Data Synchronization

### Understanding Real-Time Updates

One of Firebase's most powerful features is **real-time data synchronization**. When one user makes a change (like signing up for a shift), all other users see that change instantly without refreshing or pulling to update.

**How It Works:**

```
User A's Phone              Firestore Cloud              User B's Phone
     │                            │                            │
     │  1. User A signs up       │                            │
     │     for shift             │                            │
     ├────────────────────────────>                           │
     │  writes assignment doc    │                            │
     │                            │                            │
     │  2. Firestore stores      │                            │
     │     and broadcasts        │                            │
     │                            ├────────────────────────────>
     │                            │  3. User B's listener      │
     │                            │     receives update        │
     │                            │                            │
     │                            │     UI automatically       │
     │                            │     refreshes!             │
```

**Key Concepts:**

1. **Snapshots:** A snapshot is the current state of data at a point in time
2. **Listeners:** Code that watches for changes and gets notified automatically
3. **Document Changes:** Firestore tracks what changed (added, modified, removed)
4. **Offline Support:** Changes cached locally and synced when connection returns

### Setting Up Real-Time Listeners

#### iOS (Swift) Implementation

**Basic Listener Pattern:**

```swift
import FirebaseFirestore

class ShiftsViewModel: ObservableObject {
    @Published var shifts: [Shift] = []
    private var listener: ListenerRegistration?
    
    func startListening() {
        let db = Firestore.firestore()
        
        // Create listener that watches the shifts collection
        listener = db.collection("shifts")
            .whereField("status", isEqualTo: "published")
            .whereField("date", isGreaterThan: Date())
            .order(by: "date")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error fetching shifts: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                // Process changes incrementally for better performance
                snapshot.documentChanges.forEach { change in
                    switch change.type {
                    case .added:
                        if let shift = try? change.document.data(as: Shift.self) {
                            self?.shifts.append(shift)
                        }
                    case .modified:
                        if let shift = try? change.document.data(as: Shift.self) {
                            if let index = self?.shifts.firstIndex(where: { $0.id == shift.id }) {
                                self?.shifts[index] = shift
                            }
                        }
                    case .removed:
                        let shiftId = change.document.documentID
                        self?.shifts.removeAll { $0.id == shiftId }
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}

// Usage in SwiftUI View
struct ShiftsListView: View {
    @StateObject private var viewModel = ShiftsViewModel()
    
    var body: some View {
        List(viewModel.shifts) { shift in
            ShiftRow(shift: shift)
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}
```

**Listening to a Single Document:**

```swift
class ShiftDetailViewModel: ObservableObject {
    @Published var shift: Shift?
    private var listener: ListenerRegistration?
    
    func observeShift(shiftId: String) {
        let db = Firestore.firestore()
        
        listener = db.collection("shifts")
            .document(shiftId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot,
                      let shift = try? snapshot.data(as: Shift.self) else {
                    return
                }
                
                self?.shift = shift
                
                // Check for specific field changes
                if snapshot.metadata.hasPendingWrites {
                    // This change is local (not yet confirmed by server)
                    print("Updating locally...")
                } else {
                    // This change came from the server
                    print("Updated from server")
                }
            }
    }
}
```

#### Android (Kotlin) Implementation

**Basic Listener Pattern:**

```kotlin
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class ShiftsViewModel : ViewModel() {
    private val _shifts = MutableStateFlow<List<Shift>>(emptyList())
    val shifts: StateFlow<List<Shift>> = _shifts
    
    private var listener: ListenerRegistration? = null
    
    fun startListening() {
        val db = FirebaseFirestore.getInstance()
        
        listener = db.collection("shifts")
            .whereEqualTo("status", "published")
            .whereGreaterThan("date", Timestamp.now())
            .orderBy("date")
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    Log.e("ShiftsViewModel", "Listen failed", error)
                    return@addSnapshotListener
                }
                
                if (snapshot != null) {
                    val currentShifts = _shifts.value.toMutableList()
                    
                    // Process each change
                    snapshot.documentChanges.forEach { change ->
                        val shift = change.document.toObject(Shift::class.java)
                        
                        when (change.type) {
                            DocumentChange.Type.ADDED -> {
                                currentShifts.add(shift)
                            }
                            DocumentChange.Type.MODIFIED -> {
                                val index = currentShifts.indexOfFirst { it.id == shift.id }
                                if (index != -1) {
                                    currentShifts[index] = shift
                                }
                            }
                            DocumentChange.Type.REMOVED -> {
                                currentShifts.removeAll { it.id == shift.id }
                            }
                        }
                    }
                    
                    _shifts.value = currentShifts.sortedBy { it.date }
                }
            }
    }
    
    fun stopListening() {
        listener?.remove()
        listener = null
    }
    
    override fun onCleared() {
        super.onCleared()
        stopListening()
    }
}

// Usage in Compose
@Composable
fun ShiftsListScreen(viewModel: ShiftsViewModel = viewModel()) {
    val shifts by viewModel.shifts.collectAsState()
    
    LaunchedEffect(Unit) {
        viewModel.startListening()
    }
    
    DisposableEffect(Unit) {
        onDispose {
            viewModel.stopListening()
        }
    }
    
    LazyColumn {
        items(shifts) { shift ->
            ShiftRow(shift = shift)
        }
    }
}
```

### Real-Time Update Scenarios

#### Scenario 1: User Signs Up for Shift

**What Happens:**

1. **User A (Sarah) taps "Sign Up" on her phone**
   - App creates assignment document in Firestore
   - Firestore immediately returns success to Sarah
   - Sarah's UI updates instantly (optimistic update)

2. **Firestore receives the write**
   - Document created in `assignments` collection
   - Triggers `currentScouts` increment on shift document
   - Cloud Function may trigger for notifications

3. **User B (John) sees the update**
   - John's app has a listener on the shift document
   - Firestore pushes the updated shift to John's device
   - John's UI automatically refreshes showing: "2/3 scouts signed up"
   - No manual refresh needed!

4. **Committee Member sees the update**
   - Committee member's app listening to assignments for this shift
   - New assignment appears in the roster automatically
   - Counter updates: "Now showing 2 assignments"

**Code Example:**

```swift
// Sarah's device - Signing up
func signUpForShift(shiftId: String) async throws {
    let db = Firestore.firestore()
    
    // Create assignment
    let assignment = Assignment(
        shiftId: shiftId,
        userId: Auth.auth().currentUser!.uid,
        userName: "Sarah Smith",
        userRole: "parent",
        status: "confirmed",
        signupTime: Date()
    )
    
    // Write to Firestore
    try await db.collection("assignments").addDocument(from: assignment)
    
    // Update shift counts (via transaction to prevent race conditions)
    let shiftRef = db.collection("shifts").document(shiftId)
    try await db.runTransaction { transaction, errorPointer in
        let shiftDoc = try transaction.getDocument(shiftRef)
        let currentCount = shiftDoc.data()?["currentParents"] as? Int ?? 0
        transaction.updateData(["currentParents": currentCount + 1], forDocument: shiftRef)
        return nil
    }
}

// John's device - Listener automatically receives update
class ShiftDetailViewModel: ObservableObject {
    @Published var currentScouts: Int = 0
    @Published var currentParents: Int = 0
    
    func observeShift(shiftId: String) {
        db.collection("shifts").document(shiftId)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data() else { return }
                
                // UI updates automatically when these values change!
                self.currentScouts = data["currentScouts"] as? Int ?? 0
                self.currentParents = data["currentParents"] as? Int ?? 0
            }
    }
}
```

#### Scenario 2: Committee Creates New Shift

**What Happens:**

1. **Committee member creates shift**
   - Writes to `shifts` collection with `status: "published"`
   - Cloud Function triggers to send notifications

2. **All parents' devices receive update**
   - Parents have listeners on shifts collection with `status == "published"`
   - New shift document pushed to all listening devices
   - New shift appears in everyone's list immediately

3. **Push notification sent (optional)**
   - FCM notification sent to users who enabled "New Shift" notifications
   - Users can tap notification to open the new shift

**Code Example:**

```kotlin
// Committee device - Creating shift
suspend fun createShift(shift: Shift) {
    val db = FirebaseFirestore.getInstance()
    
    val shiftData = hashMapOf(
        "date" to shift.date,
        "startTime" to shift.startTime,
        "endTime" to shift.endTime,
        "requiredScouts" to shift.requiredScouts,
        "requiredParents" to shift.requiredParents,
        "currentScouts" to 0,
        "currentParents" to 0,
        "status" to "published",  // Important: makes it visible
        "createdAt" to FieldValue.serverTimestamp()
    )
    
    db.collection("shifts").add(shiftData).await()
    // All listening devices receive this immediately!
}

// Parent's device - Listener receives the new shift
class ShiftsViewModel : ViewModel() {
    private var listener: ListenerRegistration? = null
    
    init {
        listener = db.collection("shifts")
            .whereEqualTo("status", "published")
            .orderBy("date")
            .addSnapshotListener { snapshot, error ->
                snapshot?.documentChanges?.forEach { change ->
                    if (change.type == DocumentChange.Type.ADDED) {
                        val newShift = change.document.toObject(Shift::class.java)
                        // newShift automatically appears in UI!
                        Log.d("Shifts", "New shift added: ${newShift.id}")
                    }
                }
            }
    }
}
```

#### Scenario 3: Multi-Household Update (Divorced Parents)

**What Happens:**

1. **Mom signs up Alex for a shift**
   - Creates assignment with `households: ["mom_household", "dad_household"]`
   - Assignment visible to both households

2. **Dad's device automatically shows update**
   - Dad has listener with `.whereArrayContains("households", "dad_household")`
   - New assignment pushed to Dad's device
   - Dad sees: "Alex Smith - Dec 15, 2pm (Signed up by Sarah)"

3. **Both parents see the same assignment**
   - Prevents double-booking
   - Both parents aware of Alex's schedule

**Code Example:**

```swift
// Mom's device - Signs up Alex
func signUpChild(childId: String, shiftId: String) async throws {
    let db = Firestore.firestore()
    
    // Get child's households
    let childDoc = try await db.collection("users").document(childId).getDocument()
    let households = childDoc.data()?["households"] as? [String] ?? []
    
    // Create assignment visible to all households
    let assignment = Assignment(
        shiftId: shiftId,
        userId: childId,
        userName: "Alex Smith",
        households: households,  // Both mom's and dad's households
        primaryHouseholdId: "mom_household",
        assignedBy: Auth.auth().currentUser!.uid
    )
    
    try await db.collection("assignments").addDocument(from: assignment)
}

// Dad's device - Listener catches assignment for his household
func observeHouseholdAssignments(householdId: String) {
    db.collection("assignments")
        .whereField("households", arrayContains: householdId)
        .whereField("status", isEqualTo: "confirmed")
        .addSnapshotListener { snapshot, error in
            // Receives assignment even though mom created it!
            snapshot?.documentChanges.forEach { change in
                if change.type == .added {
                    let assignment = try? change.document.data(as: Assignment.self)
                    print("Alex has a new shift assignment!")
                }
            }
        }
}
```

### Performance Optimization

#### 1. Use Targeted Listeners

**Bad: Listen to everything**
```swift
// DON'T DO THIS - Listens to ALL shifts
db.collection("shifts")
    .addSnapshotListener { ... }
```

**Good: Filter what you need**
```swift
// DO THIS - Only published, future shifts
db.collection("shifts")
    .whereField("status", isEqualTo: "published")
    .whereField("date", isGreaterThan: Date())
    .addSnapshotListener { ... }
```

#### 2. Process Document Changes Incrementally

```swift
// GOOD: Only update what changed
snapshot?.documentChanges.forEach { change in
    switch change.type {
    case .added:    // Only process new documents
    case .modified: // Only update changed documents
    case .removed:  // Only remove deleted documents
    }
}

// AVOID: Replacing entire array on every change
self.shifts = snapshot?.documents.compactMap { ... } ?? []
```

#### 3. Cleanup Listeners

**Always remove listeners when done:**

```swift
// iOS
var listener: ListenerRegistration?

func startListening() {
    listener = db.collection("shifts").addSnapshotListener { ... }
}

deinit {
    listener?.remove()  // Prevents memory leaks!
}
```

```kotlin
// Android
private var listener: ListenerRegistration? = null

override fun onStart() {
    super.onStart()
    listener = db.collection("shifts").addSnapshotListener { ... }
}

override fun onStop() {
    super.onStop()
    listener?.remove()  // Prevents memory leaks!
}
```

### Handling Offline/Online Transitions

Firebase automatically handles offline scenarios:

```swift
// iOS - Detect online/offline status
db.collection("shifts")
    .addSnapshotListener { snapshot, error in
        guard let snapshot = snapshot else { return }
        
        if snapshot.metadata.isFromCache {
            // Data loaded from local cache (offline)
            print("📱 Showing cached data")
        } else {
            // Data loaded from server (online)
            print("☁️ Updated from server")
        }
        
        // Handle pending writes
        if snapshot.metadata.hasPendingWrites {
            print("⏳ Changes not yet saved to server")
        }
    }
```

```kotlin
// Android - Detect online/offline status
db.collection("shifts")
    .addSnapshotListener { snapshot, error ->
        if (snapshot != null) {
            val source = if (snapshot.metadata.isFromCache) "local cache" else "server"
            Log.d("Shifts", "Data loaded from: $source")
            
            if (snapshot.metadata.hasPendingWrites()) {
                Log.d("Shifts", "Changes pending upload to server")
            }
        }
    }
```

### Real-Time Update Best Practices

1. **Start listeners in `onAppear`/`onStart`**
   - Begin listening when view appears
   - Ensures users see latest data

2. **Stop listeners in `onDisappear`/`onStop`**
   - Prevents unnecessary updates
   - Reduces battery usage
   - Prevents memory leaks

3. **Use weak self in closures (iOS)**
   - Prevents retain cycles
   - Example: `{ [weak self] in ... }`

4. **Filter queries as much as possible**
   - Reduces data transfer
   - Improves performance
   - Lowers Firestore read costs

5. **Handle errors gracefully**
   - Network can fail
   - Show cached data
   - Inform user of sync status

6. **Use transactions for counters**
   - Prevents race conditions
   - Ensures accurate counts
   - Example: `currentScouts` counter

### Summary: How Real-Time Updates Work

```
┌──────────────────────────────────────────────────────────┐
│  User Makes Change                                       │
│  ├─> Write to Firestore                                  │
│  ├─> Firestore confirms write                            │
│  └─> User's UI updates immediately (optimistic)          │
└──────────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────┐
│  Firestore Cloud                                         │
│  ├─> Stores document                                     │
│  ├─> Updates indexes                                     │
│  ├─> Triggers Cloud Functions (if any)                   │
│  └─> Broadcasts to all active listeners                  │
└──────────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────┐
│  Other Users' Devices                                    │
│  ├─> Listeners receive snapshot                          │
│  ├─> Process document changes                            │
│  ├─> Update local data model                             │
│  └─> UI automatically refreshes                          │
│                                                           │
│  ✨ Users see changes within ~100ms                      │
│  ✨ No manual refresh needed                             │
│  ✨ Works offline with local cache                       │
└──────────────────────────────────────────────────────────┘
```

**Key Takeaway:** Firestore's real-time listeners create a "live" app where changes made by one user instantly appear for all other users. You write the listener code once, and Firebase handles all the synchronization magic automatically.

---

## Firestore Schema Versioning

### Why Schema Versioning Matters

Unlike SQL databases with rigid schemas and migration scripts, Firestore is schema-less. This is both a blessing and a curse:

**The Problem:**
- Your app evolves and data structure needs change
- Users don't update apps immediately (some may never update)
- Old app versions try to read new data structures → crashes or bugs
- You can't just "ALTER TABLE" like in SQL

**The Solution:**
Schema versioning lets you safely evolve your data structure while supporting multiple app versions simultaneously.

### Strategy 1: Schema Version Field (Recommended)

Add a `schemaVersion` field to every document from day one.

#### Implementation

**Starting from Day 1:**

```javascript
// All documents include schemaVersion
// users collection
{
  schemaVersion: 1,
  uid: "abc123",
  firstName: "John",
  lastName: "Smith",
  email: "john@example.com",
  role: "parent",
  createdAt: Timestamp,
  updatedAt: Timestamp
}

// families collection
{
  schemaVersion: 1,
  familyName: "Smith Household",
  primaryParentId: "abc123",
  members: [...],
  createdAt: Timestamp,
  updatedAt: Timestamp
}

// shifts collection
{
  schemaVersion: 1,
  date: Timestamp,
  title: "Friday Evening",
  requiredVolunteers: 5,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Update Your Models to Include Version:**

```swift
// iOS
struct User: Codable {
    @DocumentID var id: String?
    let schemaVersion: Int  // Add this to all models
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    let role: String
    // ... other fields
}

struct Shift: Codable {
    @DocumentID var id: String?
    let schemaVersion: Int  // Add this to all models
    let date: Timestamp
    let title: String
    // ... other fields
}
```

```kotlin
// Android
data class User(
    @DocumentId val id: String = "",
    val schemaVersion: Int = 1,  // Add this to all models
    val uid: String = "",
    val firstName: String = "",
    val lastName: String = "",
    val email: String = "",
    val role: String = ""
    // ... other fields
)

data class Shift(
    @DocumentId val id: String = "",
    val schemaVersion: Int = 1,  // Add this to all models
    val date: Timestamp = Timestamp.now(),
    val title: String = ""
    // ... other fields
)
```

### Strategy 2: Additive Changes (Preferred)

The safest way to evolve schema is to **add new fields without removing old ones** initially.

#### Example: Changing User Name Storage

**Scenario:** You want to change from separate `firstName`/`lastName` to a single `fullName` field.

**Phase 1: Original Schema (V1)**
```javascript
{
  schemaVersion: 1,
  firstName: "John",
  lastName: "Smith",
  email: "john@example.com"
}
```

**Phase 2: Add New Field, Keep Old (V2)**
```javascript
{
  schemaVersion: 2,
  firstName: "John",      // Keep for backward compatibility
  lastName: "Smith",       // Keep for backward compatibility
  fullName: "John Smith",  // New field
  email: "john@example.com"
}
```

**Phase 3: Update App to Handle Both Versions**

```swift
// iOS - Backward compatible User model
struct User: Codable {
    let schemaVersion: Int
    
    // Version 2 field
    var fullName: String?
    
    // Version 1 fields (optional for backward compatibility)
    var firstName: String?
    var lastName: String?
    
    let email: String
    
    // Computed property that works with any version
    var displayName: String {
        if schemaVersion >= 2, let name = fullName {
            return name
        } else if let first = firstName, let last = lastName {
            return "\(first) \(last)"
        }
        return email
    }
    
    // Helper for creating new users (always use latest schema)
    static func create(fullName: String, email: String, role: String) -> [String: Any] {
        return [
            "schemaVersion": 2,  // Always use latest
            "fullName": fullName,
            "email": email,
            "role": role,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}
```

```kotlin
// Android - Backward compatible User model
data class User(
    val schemaVersion: Int = 1,
    
    // V2 field
    val fullName: String? = null,
    
    // V1 fields
    val firstName: String? = null,
    val lastName: String? = null,
    
    val email: String = ""
) {
    // Computed property that works with any version
    val displayName: String
        get() = when {
            schemaVersion >= 2 && fullName != null -> fullName
            firstName != null && lastName != null -> "$firstName $lastName"
            else -> email
        }
    
    companion object {
        // Helper for creating new users (always use latest schema)
        fun create(fullName: String, email: String, role: String): Map<String, Any> {
            return mapOf(
                "schemaVersion" to 2,  // Always use latest
                "fullName" to fullName,
                "email" to email,
                "role" to role,
                "createdAt" to FieldValue.serverTimestamp()
            )
        }
    }
}
```

**Phase 4: Eventually Remove Old Fields (Optional)**

After 90%+ of users have updated (check Firebase Analytics):
- Deploy a migration to remove old fields
- Update models to remove backward compatibility code
- This step is optional - keeping old fields doesn't hurt

**Benefits of Additive Changes:**
- ✅ Zero downtime
- ✅ Old app versions continue working
- ✅ Easy rollback if needed
- ✅ No coordination needed between app updates and data migration

### Strategy 3: Bulk Migration with Cloud Functions

For existing data, use a Cloud Function to migrate documents in bulk.

#### Example: Migrate All Users to V2

```typescript
// functions/src/migrations/migrateUsersToV2.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

interface MigrationResult {
  success: boolean;
  migrated: number;
  skipped: number;
  errors: number;
  message: string;
}

export const migrateUsersToV2 = functions
  .runWith({
    timeoutSeconds: 540,  // 9 minutes (max)
    memory: '1GB'
  })
  .https.onRequest(async (req, res) => {
    // CRITICAL: Protect this endpoint!
    const adminSecret = req.headers.authorization;
    if (adminSecret !== process.env.ADMIN_MIGRATION_SECRET) {
      res.status(403).json({ error: 'Unauthorized' });
      return;
    }

    const db = admin.firestore();
    let migratedCount = 0;
    let skippedCount = 0;
    let errorCount = 0;

    try {
      // Get all users with old schema (V1 or no version)
      const usersSnapshot = await db.collection('users')
        .where('schemaVersion', 'in', [1, null])
        .get();

      console.log(`Found ${usersSnapshot.size} users to migrate`);

      // Process in batches of 500 (Firestore batch limit)
      const batches: admin.firestore.WriteBatch[] = [];
      let currentBatch = db.batch();
      let operationCount = 0;

      for (const doc of usersSnapshot.docs) {
        const data = doc.data();
        
        // Skip if already V2
        if (data.schemaVersion === 2) {
          skippedCount++;
          continue;
        }

        try {
          // Build V2 document
          const updates: any = {
            schemaVersion: 2,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          };

          // Migrate firstName + lastName to fullName
          if (data.firstName && data.lastName) {
            updates.fullName = `${data.firstName} ${data.lastName}`;
            // Keep old fields for safety during transition
            // updates.firstName = data.firstName;
            // updates.lastName = data.lastName;
          }

          currentBatch.update(doc.ref, updates);
          operationCount++;
          migratedCount++;

          // Commit batch when we hit 500 operations
          if (operationCount === 500) {
            batches.push(currentBatch);
            currentBatch = db.batch();
            operationCount = 0;
          }
        } catch (error) {
          console.error(`Error processing user ${doc.id}:`, error);
          errorCount++;
        }
      }

      // Add final batch if it has operations
      if (operationCount > 0) {
        batches.push(currentBatch);
      }

      // Commit all batches
      console.log(`Committing ${batches.length} batches...`);
      for (let i = 0; i < batches.length; i++) {
        await batches[i].commit();
        console.log(`Committed batch ${i + 1}/${batches.length}`);
      }

      const result: MigrationResult = {
        success: true,
        migrated: migratedCount,
        skipped: skippedCount,
        errors: errorCount,
        message: `Successfully migrated ${migratedCount} users to schema V2. Skipped: ${skippedCount}, Errors: ${errorCount}`
      };

      console.log('Migration complete:', result);
      res.json(result);

    } catch (error) {
      console.error('Migration failed:', error);
      res.status(500).json({
        success: false,
        migrated: migratedCount,
        skipped: skippedCount,
        errors: errorCount,
        message: `Migration failed: ${error}`
      });
    }
  });
```

**Deploy and Run:**

```bash
# 1. Set the admin secret
firebase functions:config:set migration.admin_secret="YOUR_SECURE_RANDOM_TOKEN_HERE"

# 2. Deploy the migration function
firebase deploy --only functions:migrateUsersToV2

# 3. Run migration (use curl or Postman)
curl -X POST \
  https://us-central1-troop900-tree-lot.cloudfunctions.net/migrateUsersToV2 \
  -H "Authorization: YOUR_SECURE_RANDOM_TOKEN_HERE"

# 4. Monitor logs
firebase functions:log --only migrateUsersToV2
```

### Strategy 4: Lazy Migration (On-Demand)

Migrate documents automatically when they're accessed.

#### Example: Auto-Upgrade on Read

```typescript
// functions/src/triggers/autoMigrateUser.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// This doesn't exist in Firebase yet, but illustrates the concept
// Instead, do lazy migration in your callable functions

export const upgradeUserOnAccess = async (userId: string): Promise<void> => {
  const db = admin.firestore();
  const userRef = db.collection('users').doc(userId);
  const userDoc = await userRef.get();
  
  if (!userDoc.exists) return;
  
  const data = userDoc.data()!;
  const currentVersion = data.schemaVersion || 1;
  
  // Check if migration needed
  if (currentVersion < 2) {
    console.log(`Auto-upgrading user ${userId} from V${currentVersion} to V2`);
    
    const updates: any = {
      schemaVersion: 2,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    // Perform migration
    if (data.firstName && data.lastName) {
      updates.fullName = `${data.firstName} ${data.lastName}`;
    }
    
    await userRef.update(updates);
  }
};

// Use in your callable functions
export const getMyProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }
  
  const userId = context.auth.uid;
  
  // Auto-upgrade before returning data
  await upgradeUserOnAccess(userId);
  
  const db = admin.firestore();
  const userDoc = await db.collection('users').doc(userId).get();
  
  return userDoc.data();
});
```

### Strategy 5: Real-World Example for Troop 900

Let's walk through a realistic schema change for your app.

#### Scenario: Enhanced Household Membership

**Current (V1):** Simple array of household IDs
```javascript
// users collection
{
  schemaVersion: 1,
  uid: "scout123",
  firstName: "Alex",
  lastName: "Smith",
  role: "scout",
  householdIds: ["household-1", "household-2"]  // Just IDs
}
```

**Goal (V2):** Track when joined and relationship to each household
```javascript
// users collection
{
  schemaVersion: 2,
  uid: "scout123",
  fullName: "Alex Smith",  // Also migrating name
  role: "scout",
  householdIds: ["household-1", "household-2"],  // Keep for compatibility
  households: [  // New detailed structure
    {
      id: "household-1",
      relationship: "child",  // child, stepchild, parent, etc.
      joinedAt: Timestamp,
      isPrimary: true
    },
    {
      id: "household-2",
      relationship: "child",
      joinedAt: Timestamp,
      isPrimary: false
    }
  ]
}
```

**Step 1: Update Models**

```swift
// iOS
struct HouseholdMembership: Codable {
    let id: String
    let relationship: String
    let joinedAt: Timestamp
    let isPrimary: Bool
}

struct User: Codable {
    let schemaVersion: Int
    
    // V2 fields
    var fullName: String?
    var households: [HouseholdMembership]?
    
    // V1 fields (keep for compatibility)
    var firstName: String?
    var lastName: String?
    var householdIds: [String]?
    
    let uid: String
    let role: String
    
    // Compatibility layer
    var displayName: String {
        if schemaVersion >= 2, let name = fullName {
            return name
        } else if let first = firstName, let last = lastName {
            return "\(first) \(last)"
        }
        return uid
    }
    
    var allHouseholdIds: [String] {
        if schemaVersion >= 2, let houses = households {
            return houses.map { $0.id }
        }
        return householdIds ?? []
    }
    
    var primaryHouseholdId: String? {
        if schemaVersion >= 2, let houses = households {
            return houses.first(where: { $0.isPrimary })?.id
        }
        return householdIds?.first
    }
}
```

**Step 2: Migration Function**

```typescript
// functions/src/migrations/migrateUsersToV2Households.ts
export const migrateUsersToV2Households = functions
  .runWith({ timeoutSeconds: 540, memory: '1GB' })
  .https.onRequest(async (req, res) => {
    // Check authorization
    if (req.headers.authorization !== process.env.ADMIN_MIGRATION_SECRET) {
      res.status(403).json({ error: 'Unauthorized' });
      return;
    }

    const db = admin.firestore();
    const batch = db.batch();
    let count = 0;

    const usersSnapshot = await db.collection('users')
      .where('schemaVersion', '<', 2)
      .get();

    for (const userDoc of usersSnapshot.docs) {
      const data = userDoc.data();
      
      // Build V2 structure
      const updates: any = {
        schemaVersion: 2,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };
      
      // Migrate name
      if (data.firstName && data.lastName) {
        updates.fullName = `${data.firstName} ${data.lastName}`;
      }
      
      // Migrate households
      if (data.householdIds && data.householdIds.length > 0) {
        updates.households = data.householdIds.map((id: string, index: number) => ({
          id: id,
          relationship: data.role === 'parent' ? 'parent' : 'child',
          joinedAt: data.createdAt || admin.firestore.Timestamp.now(),
          isPrimary: index === 0  // First household is primary
        }));
        
        // Keep old field for compatibility
        updates.householdIds = data.householdIds;
      }
      
      batch.update(userDoc.ref, updates);
      count++;
      
      if (count % 500 === 0) {
        await batch.commit();
        console.log(`Migrated ${count} users...`);
      }
    }
    
    if (count % 500 !== 0) {
      await batch.commit();
    }
    
    res.json({ success: true, migrated: count });
  });
```

**Step 3: Update Cloud Functions to Write V2**

```typescript
// functions/src/callable/addFamilyMember.ts
export const addFamilyMember = functions.https.onCall(async (data, context) => {
  // ... authentication checks ...
  
  const db = admin.firestore();
  
  // When creating new users, always use latest schema
  const newUserData = {
    schemaVersion: 2,  // Always current version
    uid: newUserId,
    fullName: data.fullName,  // V2 field
    role: data.role,
    households: [{  // V2 structure
      id: data.householdId,
      relationship: data.relationship,
      joinedAt: admin.firestore.FieldValue.serverTimestamp(),
      isPrimary: true
    }],
    householdIds: [data.householdId],  // Keep V1 for compatibility
    isClaimed: false,
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };
  
  await db.collection('users').doc(newUserId).set(newUserData);
});
```

### Schema Versioning Checklist

When you need to change schema, follow this checklist:

```markdown
Phase 1: Planning
□ Document current schema (V1)
□ Design new schema (V2)
□ Identify breaking vs. non-breaking changes
□ Plan backward compatibility strategy
□ Estimate number of documents to migrate

Phase 2: Code Updates
□ Update mobile app models to handle both versions
□ Add computed properties for compatibility layer
□ Update Cloud Functions to write new version
□ Update Cloud Functions to read both versions
□ Write migration function (if needed)
□ Test thoroughly on development environment

Phase 3: Deployment
□ Deploy new app version to stores
□ Update security rules if needed
□ Deploy Cloud Functions updates
□ Monitor for errors in production
□ Wait for app adoption (check Firebase Analytics)

Phase 4: Migration (if needed)
□ Test migration function with small batch
□ Run migration during off-peak hours
□ Monitor Cloud Functions logs
□ Verify migration success in Firestore Console
□ Check app still works with migrated data

Phase 5: Cleanup (optional)
□ Wait for 90%+ user adoption (2-4 weeks minimum)
□ Deploy app version that only uses new schema
□ Remove backward compatibility code
□ (Optional) Remove old fields from documents
```

### Common Migration Patterns

#### Pattern 1: Rename Field

```javascript
// V1
{ name: "John Smith" }

// V2 (additive)
{ 
  name: "John Smith",      // Keep
  fullName: "John Smith"   // Add
}

// V3 (cleanup - after all users migrated)
{ fullName: "John Smith" }  // Remove old field
```

#### Pattern 2: Split Field

```javascript
// V1
{ address: "123 Main St, San Francisco, CA 94102" }

// V2 (additive)
{
  address: "123 Main St, San Francisco, CA 94102",  // Keep
  addressComponents: {  // Add
    street: "123 Main St",
    city: "San Francisco",
    state: "CA",
    zip: "94102"
  }
}
```

#### Pattern 3: Change Data Type

```javascript
// V1
{ phoneNumber: "555-123-4567" }  // String

// V2 (additive)
{
  phoneNumber: "555-123-4567",  // Keep as string
  phoneNumberFormatted: {       // Add structured version
    countryCode: "+1",
    areaCode: "555",
    number: "1234567",
    display: "(555) 123-4567"
  }
}
```

#### Pattern 4: Array to Map

```javascript
// V1
{ 
  fcmTokens: ["token1", "token2", "token3"]  // Array
}

// V2 (additive)
{
  fcmTokens: ["token1", "token2", "token3"],  // Keep
  fcmTokensMap: {  // Add for easier management
    "token1": { addedAt: Timestamp, platform: "ios" },
    "token2": { addedAt: Timestamp, platform: "android" },
    "token3": { addedAt: Timestamp, platform: "ios" }
  }
}
```

### Best Practices Summary

#### ✅ DO:

1. **Add `schemaVersion` to every document from day 1**
   ```javascript
   { schemaVersion: 1, /* ... rest of fields */ }
   ```

2. **Prefer additive changes**
   - Add new fields, keep old ones
   - Easier rollback, zero downtime

3. **Handle multiple versions in app code**
   - Use computed properties for compatibility
   - Always write latest version

4. **Test migrations thoroughly**
   - Test on dev/staging with real data
   - Start with small batch in production

5. **Plan for transition period**
   - Keep backward compatibility for 2-4 weeks
   - Monitor adoption via Firebase Analytics

6. **Document schema changes**
   ```typescript
   // Add comments in your code
   // Schema V1: Simple name string
   // Schema V2: Split into firstName/lastName
   // Migration: 2024-12-15
   ```

#### ❌ DON'T:

1. **Don't remove fields immediately**
   - Keep for transition period
   - Prevents crashes in old app versions

2. **Don't migrate everything at once without testing**
   - Test with 10-100 documents first
   - Then scale up

3. **Don't break old app versions**
   - Users don't update immediately
   - Some may never update

4. **Don't forget security rules**
   - Update rules when adding new fields
   - Test rule changes in emulator

5. **Don't skip the version field**
   - You'll regret it later
   - Impossible to know which schema a document uses

### For Troop 900 Specifically

Since this is a seasonal app (November-December), you have natural migration windows:

**Off-Season (January-October):**
- Perfect time for major schema changes
- No active users to disrupt
- Can test thoroughly before next season

**Active Season (November-December):**
- Avoid breaking changes
- Use additive changes only
- Can do lazy migrations during season

**Recommended Approach:**
1. Start with `schemaVersion: 1` in all collections
2. Make any needed changes during off-season
3. Keep schema stable during active season
4. Use January-October for major refactoring

This gives you a full year to plan and execute migrations!

---

## Cloud Functions Development

### What are Cloud Functions?

Cloud Functions are serverless functions that run in response to events. Think of them as backend API endpoints and automation that you don't have to host yourself.

**Benefits:**
- **No server management:** Google runs them for you
- **Automatic scaling:** Handle 1 request or 1000
- **Event-driven:** Trigger on database changes, HTTP requests, schedules
- **Integrated:** Direct access to Firestore, Auth, etc.

### Types of Cloud Functions

Your app uses 3 types:

1. **HTTPS Callable Functions** - Like API endpoints called from your app
2. **Firestore Triggers** - Auto-run when database changes
3. **Scheduled Functions** - Cron jobs (run on a schedule)

### Project Structure

```
functions/
├── src/
│   ├── index.ts              # Main file exporting all functions
│   ├── callable/             # HTTPS callable functions
│   │   ├── processInviteCode.ts
│   │   ├── addFamilyMember.ts
│   │   ├── claimProfile.ts
│   │   ├── signUpForShift.ts
│   │   ├── cancelAssignment.ts
│   │   ├── checkInUser.ts
│   │   ├── checkOutUser.ts
│   │   ├── addWalkIn.ts
│   │   ├── getLeaderboard.ts
│   │   ├── getMyStats.ts
│   │   ├── getScoutBucksReport.ts
│   │   ├── createShiftTemplate.ts
│   │   ├── generateShiftsFromTemplates.ts
│   │   ├── publishShifts.ts
│   │   └── sendMessage.ts
│   ├── triggers/             # Firestore triggers
│   │   ├── onAssignmentCreated.ts
│   │   ├── onAssignmentCancelled.ts
│   │   ├── onShiftCreated.ts
│   │   └── onMessageCreated.ts
│   ├── scheduled/            # Scheduled functions
│   │   └── sendShiftReminders.ts
│   └── utils/                # Shared utilities
│       ├── auth.ts           # Authentication helpers
│       ├── permissions.ts    # Permission checking
│       └── notifications.ts  # FCM helpers
├── package.json
└── tsconfig.json
```

### Setting Up Cloud Functions

#### 1. Install Dependencies

```bash
cd functions
npm install

# Install additional packages we'll need
npm install @google-cloud/firestore
npm install firebase-admin
npm install firebase-functions
```

#### 2. Update package.json

```json
{
  "name": "functions",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js",
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
```

### Function Implementations

#### HTTPS Callable Functions

These are called directly from your mobile app like API endpoints.

**Example: processInviteCode**

```typescript
// functions/src/callable/processInviteCode.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

interface ProcessInviteCodeData {
  inviteCode: string;
  familyName: string;
}

interface ProcessInviteCodeResult {
  success: boolean;
  familyId?: string;
  familyUnitId?: string;
  error?: string;
}

export const processInviteCode = functions.https.onCall(
  async (data: ProcessInviteCodeData, context): Promise<ProcessInviteCodeResult> => {
    // 1. Verify user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const userId = context.auth.uid;
    const { inviteCode, familyName } = data;

    // 2. Validate input
    if (!inviteCode || !familyName) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'inviteCode and familyName are required'
      );
    }

    const db = admin.firestore();

    try {
      // 3. Find the invite code
      const inviteCodeSnapshot = await db.collection('invite-codes')
        .where('code', '==', inviteCode.toUpperCase())
        .where('isActive', '==', true)
        .where('usedBy', '==', null)
        .limit(1)
        .get();

      if (inviteCodeSnapshot.empty) {
        return {
          success: false,
          error: 'Invalid or already used invite code'
        };
      }

      const inviteCodeDoc = inviteCodeSnapshot.docs[0];
      const inviteCodeId = inviteCodeDoc.id;

      // 4. Create family unit
      const familyUnitRef = await db.collection('family-units').add({
        unitName: familyName + ' Family',
        householdIds: [],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      const familyUnitId = familyUnitRef.id;

      // 5. Create household (family)
      const familyRef = await db.collection('families').add({
        familyName: familyName,
        inviteCodeId: inviteCodeId,
        primaryParentId: userId,
        familyUnitId: familyUnitId,
        members: [{
          userId: userId,
          role: 'parent',
          addedBy: userId,
          addedAt: admin.firestore.FieldValue.serverTimestamp()
        }],
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      const familyId = familyRef.id;

      // 6. Update family unit with household ID
      await familyUnitRef.update({
        householdIds: admin.firestore.FieldValue.arrayUnion(familyId)
      });

      // 7. Update user document
      await db.collection('users').doc(userId).update({
        householdIds: admin.firestore.FieldValue.arrayUnion(familyId),
        familyUnitId: familyUnitId,
        canManageFamily: true,
        role: 'parent',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // 8. Mark invite code as used
      await inviteCodeDoc.ref.update({
        usedBy: userId,
        usedAt: admin.firestore.FieldValue.serverTimestamp(),
        isActive: false
      });

      return {
        success: true,
        familyId: familyId,
        familyUnitId: familyUnitId
      };

    } catch (error) {
      console.error('Error processing invite code:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to process invite code'
      );
    }
  }
);
```

**Calling from iOS:**

```swift
struct ProcessInviteCodeRequest: Encodable {
    let inviteCode: String
    let familyName: String
}

struct ProcessInviteCodeResponse: Decodable {
    let success: Bool
    let familyId: String?
    let familyUnitId: String?
    let error: String?
}

func processInviteCode(code: String, familyName: String) async throws -> ProcessInviteCodeResponse {
    let functions = Functions.functions()
    
    let request = ProcessInviteCodeRequest(
        inviteCode: code,
        familyName: familyName
    )
    
    let result = try await functions.httpsCallable("processInviteCode")
        .call(request)
    
    let data = try JSONSerialization.data(withJSONObject: result.data)
    return try JSONDecoder().decode(ProcessInviteCodeResponse.self, from: data)
}
```

**Example: signUpForShift**

```typescript
// functions/src/callable/signUpForShift.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

interface SignUpForShiftData {
  shiftId: string;
  userId: string;          // Who to sign up
  householdId: string;     // Which household is making the assignment
}

interface SignUpForShiftResult {
  success: boolean;
  assignmentId?: string;
  error?: string;
}

export const signUpForShift = functions.https.onCall(
  async (data: SignUpForShiftData, context): Promise<SignUpForShiftResult> => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
    }

    const callerId = context.auth.uid;
    const { shiftId, userId, householdId } = data;

    if (!shiftId || !userId || !householdId) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    const db = admin.firestore();

    try {
      // Run as a transaction to prevent race conditions
      return await db.runTransaction(async (transaction) => {
        // 1. Get shift
        const shiftRef = db.collection('shifts').doc(shiftId);
        const shiftDoc = await transaction.get(shiftRef);

        if (!shiftDoc.exists) {
          return { success: false, error: 'Shift not found' };
        }

        const shift = shiftDoc.data()!;

        // 2. Check if shift is full
        const requiredVolunteers = shift.requiredVolunteers || 0;
        const assignedCount = shift.assignedCount || 0;

        if (assignedCount >= requiredVolunteers) {
          return { success: false, error: 'Shift is full' };
        }

        // 3. Check if shift is published
        if (shift.isDraft === true) {
          return { success: false, error: 'Shift is not published yet' };
        }

        // 4. Get user being signed up
        const userRef = db.collection('users').doc(userId);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          return { success: false, error: 'User not found' };
        }

        const user = userDoc.data()!;

        // 5. Check if family is active
        const householdRef = db.collection('families').doc(householdId);
        const householdDoc = await transaction.get(householdRef);

        if (!householdDoc.exists || !householdDoc.data()?.isActive) {
          return { success: false, error: 'Household is not active' };
        }

        // 6. Verify permission to sign up this user
        const canSignUp = await checkSignUpPermission(
          transaction,
          callerId,
          userId,
          householdId
        );

        if (!canSignUp.allowed) {
          return { success: false, error: canSignUp.reason };
        }

        // 7. Check if user is already signed up for this shift
        const existingAssignments = await db.collection('assignments')
          .where('shiftId', '==', shiftId)
          .where('userId', '==', userId)
          .where('status', '==', 'confirmed')
          .limit(1)
          .get();

        if (!existingAssignments.empty) {
          return { success: false, error: 'User is already signed up for this shift' };
        }

        // 8. Create assignment
        const assignmentRef = db.collection('assignments').doc();
        const assignmentData = {
          shiftId: shiftId,
          userId: userId,
          assignedBy: callerId,
          householdId: householdId,
          status: 'confirmed',
          wasWalkIn: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };

        transaction.set(assignmentRef, assignmentData);

        // 9. Increment shift's assigned count
        transaction.update(shiftRef, {
          assignedCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        return {
          success: true,
          assignmentId: assignmentRef.id
        };
      });

    } catch (error) {
      console.error('Error signing up for shift:', error);
      throw new functions.https.HttpsError('internal', 'Failed to sign up for shift');
    }
  }
);

// Helper function to check permissions
async function checkSignUpPermission(
  transaction: admin.firestore.Transaction,
  callerId: string,
  targetUserId: string,
  householdId: string
): Promise<{ allowed: boolean; reason?: string }> {
  const db = admin.firestore();

  // Get caller's user document
  const callerRef = db.collection('users').doc(callerId);
  const callerDoc = await transaction.get(callerRef);

  if (!callerDoc.exists) {
    return { allowed: false, reason: 'Caller not found' };
  }

  const caller = callerDoc.data()!;

  // Admins and committee can sign up anyone
  if (caller.role === 'admin' || caller.role === 'committee') {
    return { allowed: true };
  }

  // Check if caller is in the household
  const callerHouseholds = caller.householdIds || [];
  if (!callerHouseholds.includes(householdId)) {
    return { allowed: false, reason: 'You are not in this household' };
  }

  // Check if caller can manage family
  if (!caller.canManageFamily) {
    // Can only sign up self
    if (callerId !== targetUserId) {
      return { allowed: false, reason: 'You can only sign up yourself' };
    }
    return { allowed: true };
  }

  // If signing up someone else, check if they're unclaimed
  if (callerId !== targetUserId) {
    const targetUserRef = db.collection('users').doc(targetUserId);
    const targetUserDoc = await transaction.get(targetUserRef);

    if (!targetUserDoc.exists) {
      return { allowed: false, reason: 'Target user not found' };
    }

    const targetUser = targetUserDoc.data()!;

    // Check if target user is in this household
    const targetHouseholds = targetUser.householdIds || [];
    if (!targetHouseholds.includes(householdId)) {
      return { allowed: false, reason: 'Target user is not in this household' };
    }

    // Check if target user is claimed
    if (targetUser.isClaimed) {
      return { allowed: false, reason: 'Cannot sign up a claimed scout' };
    }
  }

  return { allowed: true };
}
```

#### Firestore Triggers

These run automatically when documents change.

**Example: onAssignmentCreated**

```typescript
// functions/src/triggers/onAssignmentCreated.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onAssignmentCreated = functions.firestore
  .document('assignments/{assignmentId}')
  .onCreate(async (snapshot, context) => {
    const assignment = snapshot.data();
    const assignmentId = context.params.assignmentId;

    const db = admin.firestore();

    try {
      // 1. Get user info
      const userDoc = await db.collection('users').doc(assignment.userId).get();
      if (!userDoc.exists) return;

      const user = userDoc.data()!;

      // 2. Get shift info
      const shiftDoc = await db.collection('shifts').doc(assignment.shiftId).get();
      if (!shiftDoc.exists) return;

      const shift = shiftDoc.data()!;

      // 3. Send push notification
      const fcmTokens = user.fcmTokens || [];
      if (fcmTokens.length === 0) {
        console.log('No FCM tokens for user:', assignment.userId);
        return;
      }

      const message = {
        notification: {
          title: 'Shift Assignment Confirmed',
          body: `You're signed up for ${shift.title} on ${formatDate(shift.date)}`
        },
        data: {
          type: 'assignment_created',
          shiftId: assignment.shiftId,
          assignmentId: assignmentId
        },
        tokens: fcmTokens
      };

      const response = await admin.messaging().sendMulticast(message);
      console.log(`Sent ${response.successCount} notifications`);

      // 4. Remove invalid tokens
      if (response.failureCount > 0) {
        const tokensToRemove: string[] = [];

        response.responses.forEach((resp, idx) => {
          if (!resp.success && resp.error) {
            // Token is invalid
            tokensToRemove.push(fcmTokens[idx]);
          }
        });

        if (tokensToRemove.length > 0) {
          await db.collection('users').doc(assignment.userId).update({
            fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove)
          });
        }
      }

    } catch (error) {
      console.error('Error in onAssignmentCreated:', error);
    }
  });

function formatDate(timestamp: admin.firestore.Timestamp): string {
  const date = timestamp.toDate();
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric'
  });
}
```

**Example: onShiftCreated**

```typescript
// functions/src/triggers/onShiftCreated.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onShiftCreated = functions.firestore
  .document('shifts/{shiftId}')
  .onCreate(async (snapshot, context) => {
    const shift = snapshot.data();
    const shiftId = context.params.shiftId;

    // Only send notifications for published shifts
    if (shift.isDraft) {
      console.log('Shift is draft, skipping notification');
      return;
    }

    const db = admin.firestore();

    try {
      // Get all active users
      const usersSnapshot = await db.collection('users')
        .where('isActive', '==', true)
        .get();

      if (usersSnapshot.empty) {
        console.log('No active users found');
        return;
      }

      // Collect all FCM tokens
      const allTokens: string[] = [];
      usersSnapshot.docs.forEach(doc => {
        const user = doc.data();
        const tokens = user.fcmTokens || [];
        allTokens.push(...tokens);
      });

      if (allTokens.length === 0) {
        console.log('No FCM tokens found');
        return;
      }

      // Send notification
      const message = {
        notification: {
          title: 'New Shift Available',
          body: `${shift.title} on ${formatDate(shift.date)}`
        },
        data: {
          type: 'shift_created',
          shiftId: shiftId
        }
      };

      // FCM allows max 500 tokens per request
      const batches = chunkArray(allTokens, 500);

      for (const batch of batches) {
        const response = await admin.messaging().sendMulticast({
          ...message,
          tokens: batch
        });
        console.log(`Batch sent: ${response.successCount} success, ${response.failureCount} failures`);
      }

    } catch (error) {
      console.error('Error in onShiftCreated:', error);
    }
  });

function chunkArray<T>(array: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < array.length; i += size) {
    chunks.push(array.slice(i, i + size));
  }
  return chunks;
}

function formatDate(timestamp: admin.firestore.Timestamp): string {
  const date = timestamp.toDate();
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric'
  });
}
```

#### Scheduled Functions

These run on a schedule (like cron jobs).

**Example: sendShiftReminders**

```typescript
// functions/src/scheduled/sendShiftReminders.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Run every day at 6 PM
export const sendShiftReminders = functions.pubsub
  .schedule('0 18 * * *')
  .timeZone('America/Los_Angeles')
  .onRun(async (context) => {
    const db = admin.firestore();

    try {
      // Get tomorrow's date
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(0, 0, 0, 0);

      const dayAfterTomorrow = new Date(tomorrow);
      dayAfterTomorrow.setDate(dayAfterTomorrow.getDate() + 1);

      // Get all shifts for tomorrow
      const shiftsSnapshot = await db.collection('shifts')
        .where('date', '>=', admin.firestore.Timestamp.fromDate(tomorrow))
        .where('date', '<', admin.firestore.Timestamp.fromDate(dayAfterTomorrow))
        .where('isDraft', '==', false)
        .get();

      if (shiftsSnapshot.empty) {
        console.log('No shifts tomorrow');
        return;
      }

      console.log(`Found ${shiftsSnapshot.size} shifts tomorrow`);

      // For each shift, find assignments and send reminders
      for (const shiftDoc of shiftsSnapshot.docs) {
        const shift = shiftDoc.data();
        const shiftId = shiftDoc.id;

        // Get assignments for this shift
        const assignmentsSnapshot = await db.collection('assignments')
          .where('shiftId', '==', shiftId)
          .where('status', '==', 'confirmed')
          .get();

        if (assignmentsSnapshot.empty) continue;

        // Send notification to each assigned user
        for (const assignmentDoc of assignmentsSnapshot.docs) {
          const assignment = assignmentDoc.data();

          const userDoc = await db.collection('users').doc(assignment.userId).get();
          if (!userDoc.exists) continue;

          const user = userDoc.data()!;
          const fcmTokens = user.fcmTokens || [];

          if (fcmTokens.length === 0) continue;

          const message = {
            notification: {
              title: 'Shift Reminder',
              body: `You have a shift tomorrow: ${shift.title} at ${formatTime(shift.startTime)}`
            },
            data: {
              type: 'shift_reminder',
              shiftId: shiftId,
              assignmentId: assignmentDoc.id
            },
            tokens: fcmTokens
          };

          try {
            await admin.messaging().sendMulticast(message);
            console.log(`Sent reminder to ${user.firstName} ${user.lastName}`);
          } catch (error) {
            console.error(`Failed to send reminder to ${assignment.userId}:`, error);
          }
        }
      }

      console.log('Shift reminders sent successfully');
    } catch (error) {
      console.error('Error sending shift reminders:', error);
    }
  });

function formatTime(timestamp: admin.firestore.Timestamp): string {
  const date = timestamp.toDate();
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true
  });
}
```

### Deploying Cloud Functions

```bash
# From the functions directory
cd functions

# Build TypeScript
npm run build

# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:processInviteCode

# View logs
firebase functions:log
```

---

## Firebase Cloud Messaging

### What is FCM?

Firebase Cloud Messaging sends push notifications to iOS and Android devices. You'll use it for:
- New shift notifications
- Shift reminders (24 hours before)
- Committee announcements
- Assignment confirmations

### iOS Setup

#### 1. Enable Push Notifications in Xcode

```
1. Select your project
2. Select your app target
3. Signing & Capabilities tab
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" and check "Remote notifications"
```

#### 2. Upload APNs Certificate to Firebase

```
1. Go to Apple Developer Portal
2. Certificates, Identifiers & Profiles
3. Create a new APNs Key (or Certificate)
4. Download the .p8 key file

In Firebase Console:
1. Project Settings
2. Cloud Messaging tab
3. iOS app configuration
4. Upload your APNs .p8 key
5. Enter Team ID and Key ID
```

#### 3. Request Permission and Get FCM Token

```swift
// AppDelegate.swift
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Set messaging delegate
        Messaging.messaging().delegate = self
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permission
        requestNotificationPermission()
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func requestNotificationPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    // Called when APNs registration succeeds
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Called when FCM token is available
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("FCM Token: \(token)")
        
        // Save token to Firestore
        if let userId = Auth.auth().currentUser?.uid {
            Task {
                await saveFCMToken(userId: userId, token: token)
            }
        }
    }
    
    // Handle notifications when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is open
        completionHandler([[.banner, .sound, .badge]])
    }
    
    // Handle notification taps
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different notification types
        if let type = userInfo["type"] as? String {
            switch type {
            case "shift_created", "shift_reminder":
                if let shiftId = userInfo["shiftId"] as? String {
                    // Navigate to shift details
                    navigateToShift(shiftId: shiftId)
                }
            case "assignment_created":
                if let assignmentId = userInfo["assignmentId"] as? String {
                    // Navigate to my shifts
                    navigateToMyShifts()
                }
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    func saveFCMToken(userId: String, token: String) async {
        let db = Firestore.firestore()
        do {
            try await db.collection("users").document(userId).updateData([
                "fcmTokens": FieldValue.arrayUnion([token])
            ])
            print("FCM token saved to Firestore")
        } catch {
            print("Error saving FCM token: \(error)")
        }
    }
    
    func navigateToShift(shiftId: String) {
        // Implement navigation logic
        print("Navigate to shift: \(shiftId)")
    }
    
    func navigateToMyShifts() {
        // Implement navigation logic
        print("Navigate to my shifts")
    }
}
```

### Android Setup

#### 1. Enable Cloud Messaging in Firebase Console

Already enabled when you added your Android app.

#### 2. Request Permission and Get FCM Token

```kotlin
// MessagingService.kt
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class Troop900MessagingService : FirebaseMessagingService() {
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        println("New FCM token: $token")
        
        // Save to Firestore
        val userId = com.google.firebase.auth.FirebaseAuth.getInstance().currentUser?.uid
        if (userId != null) {
            saveFCMToken(userId, token)
        }
    }
    
    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        
        // Show notification
        message.notification?.let { notification ->
            showNotification(
                title = notification.title ?: "Troop 900",
                body = notification.body ?: "",
                data = message.data
            )
        }
    }
    
    private fun saveFCMToken(userId: String, token: String) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                Firebase.firestore.collection("users")
                    .document(userId)
                    .update("fcmTokens", com.google.firebase.firestore.FieldValue.arrayUnion(token))
                println("FCM token saved to Firestore")
            } catch (e: Exception) {
                println("Error saving FCM token: ${e.message}")
            }
        }
    }
    
    private fun showNotification(title: String, body: String, data: Map<String, String>) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create notification channel (required for Android 8.0+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Shift Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for shift updates and reminders"
            }
            notificationManager.createNotificationChannel(channel)
        }
        
        // Create intent for notification tap
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            
            // Add data for navigation
            data["type"]?.let { putExtra("notification_type", it) }
            data["shiftId"]?.let { putExtra("shift_id", it) }
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        // Build notification
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        
        notificationManager.notify(NOTIFICATION_ID++, notification)
    }
    
    companion object {
        private const val CHANNEL_ID = "troop900_shifts"
        private var NOTIFICATION_ID = 0
    }
}
```

#### 3. Register Service in AndroidManifest.xml

```xml
<manifest ...>
    <application ...>
        
        <!-- Messaging Service -->
        <service
            android:name=".Troop900MessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
    </application>
</manifest>
```

#### 4. Request Permission (Android 13+)

```kotlin
// MainActivity.kt
import android.Manifest
import android.os.Build
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.messaging.FirebaseMessaging

class MainActivity : AppCompatActivity() {
    
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted: Boolean ->
        if (isGranted) {
            getAndSaveFCMToken()
        } else {
            // Permission denied
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Request notification permission on Android 13+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
        } else {
            getAndSaveFCMToken()
        }
    }
    
    private fun getAndSaveFCMToken() {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val token = task.result
                println("FCM Token: $token")
                // Token will be saved automatically by MessagingService
            }
        }
    }
}
```

---

## Security Rules Implementation

### What are Security Rules?

Security rules control who can read/write your Firestore data. They're enforced server-side, so even if someone modifies your app code, they can't bypass the rules.

**Critical Concept:** Security rules are NOT filters. If a rule denies access, the entire query fails.

### Writing firestore.rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isUser(uid) {
      return isSignedIn() && request.auth.uid == uid;
    }
    
    function hasRole(role) {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
    
    function isAdmin() {
      return hasRole('admin');
    }
    
    function isCommittee() {
      return hasRole('committee');
    }
    
    function isAdminOrCommittee() {
      return isAdmin() || isCommittee();
    }
    
    function userIsActive() {
      return isSignedIn() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isActive == true;
    }
    
    function inHousehold(householdId) {
      return isSignedIn() &&
             request.auth.uid in get(/databases/$(database)/documents/families/$(householdId)).data.members[].userId;
    }
    
    function canManageHousehold(householdId) {
      let userDoc = get(/databases/$(database)/documents/users/$(request.auth.uid));
      return isSignedIn() &&
             householdId in userDoc.data.householdIds &&
             userDoc.data.canManageFamily == true;
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone can read user profiles (for displaying names, etc.)
      allow read: if isSignedIn();
      
      // Users can update their own profile (limited fields)
      allow update: if isUser(userId) && 
                       (!request.resource.data.diff(resource.data).affectedKeys()
                         .hasAny(['role', 'isActive', 'householdIds', 'familyUnitId']));
      
      // Admins can create/update/delete any user
      allow create, update, delete: if isAdmin();
    }
    
    // Families collection
    match /families/{familyId} {
      // Members of household can read
      allow read: if inHousehold(familyId) || isAdminOrCommittee();
      
      // Admins can write
      allow write: if isAdmin();
      
      // Primary parent can update (limited fields)
      allow update: if canManageHousehold(familyId) &&
                       (!request.resource.data.diff(resource.data).affectedKeys()
                         .hasAny(['primaryParentId', 'inviteCodeId', 'isActive']));
    }
    
    // Family units collection
    match /family-units/{unitId} {
      // Anyone in any household in the unit can read
      allow read: if isSignedIn();
      allow write: if isAdmin();
    }
    
    // Invite codes collection
    match /invite-codes/{codeId} {
      // No one can read directly (use Cloud Function)
      allow read: if false;
      
      // Only admins can create
      allow create: if isAdmin();
      
      // Cloud Functions can update (for marking as used)
      allow update: if false;  // Handled by Cloud Function
      allow delete: if isAdmin();
    }
    
    // Household links collection
    match /household-links/{linkId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
    }
    
    // Shifts collection
    match /shifts/{shiftId} {
      // Everyone can read published shifts
      allow read: if isSignedIn() && resource.data.isDraft == false;
      
      // Committee can read draft shifts
      allow read: if isAdminOrCommittee();
      
      // Committee can create/update/delete shifts
      allow create, update, delete: if isAdminOrCommittee();
    }
    
    // Shift templates collection
    match /shift-templates/{templateId} {
      // Committee can read
      allow read: if isAdminOrCommittee();
      
      // Committee can create/update/delete
      allow create, update, delete: if isAdminOrCommittee();
    }
    
    // Assignments collection
    match /assignments/{assignmentId} {
      // Read: User can see their own, or household members', or admins/committee see all
      allow read: if isSignedIn() && (
        resource.data.userId == request.auth.uid ||
        inHousehold(resource.data.householdId) ||
        isAdminOrCommittee()
      );
      
      // Create/update/delete handled by Cloud Functions
      // (too complex permission logic for security rules)
      allow write: if false;
    }
    
    // Attendance collection
    match /attendance/{attendanceId} {
      // Read: User can see their own, or if they're checked in for same shift
      allow read: if isSignedIn() && (
        resource.data.userId == request.auth.uid ||
        isAdminOrCommittee() ||
        // Parent can see scout's attendance if in same household
        exists(/databases/$(database)/documents/users/$(resource.data.userId)) &&
        get(/databases/$(database)/documents/users/$(resource.data.userId)).data.householdIds.hasAny(
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.householdIds
        )
      );
      
      // Write handled by Cloud Functions
      allow write: if false;
    }
    
    // Messages collection
    match /messages/{messageId} {
      // All active users can read messages
      allow read: if userIsActive();
      
      // Only admins and committee can create messages
      allow create: if isAdminOrCommittee();
      
      // Users can update to mark as read
      allow update: if isSignedIn() &&
                       request.resource.data.diff(resource.data).affectedKeys() == ['readBy'].toSet() &&
                       request.auth.uid in request.resource.data.readBy;
      
      // Only creator can delete
      allow delete: if isAdmin();
    }
  }
}
```

### Testing Security Rules

```bash
# Start Firestore emulator with rules
firebase emulators:start --only firestore

# In another terminal, run tests
npm test
```

**Example Test:**

```javascript
// firestore.test.js
const firebase = require('@firebase/testing');
const fs = require('fs');

const PROJECT_ID = 'troop900-test';
const RULES = fs.readFileSync('firestore.rules', 'utf8');

function getFirestore(auth) {
  return firebase
    .initializeTestApp({ projectId: PROJECT_ID, auth })
    .firestore();
}

function getAdminFirestore() {
  return firebase
    .initializeAdminApp({ projectId: PROJECT_ID })
    .firestore();
}

beforeEach(async () => {
  await firebase.clearFirestoreData({ projectId: PROJECT_ID });
});

beforeAll(async () => {
  await firebase.loadFirestoreRules({ projectId: PROJECT_ID, rules: RULES });
});

afterAll(async () => {
  await Promise.all(firebase.apps().map(app => app.delete()));
});

describe('User collection security', () => {
  it('allows user to read their own profile', async () => {
    const db = getFirestore({ uid: 'user1', email: 'user1@test.com' });
    
    // First create the user document as admin
    const admin = getAdminFirestore();
    await admin.collection('users').doc('user1').set({
      uid: 'user1',
      email: 'user1@test.com',
      firstName: 'John',
      role: 'parent'
    });
    
    // Now test that user can read it
    const doc = db.collection('users').doc('user1');
    await firebase.assertSucceeds(doc.get());
  });
  
  it('prevents user from reading another user\'s profile', async () => {
    const db = getFirestore({ uid: 'user1' });
    const doc = db.collection('users').doc('user2');
    await firebase.assertFails(doc.get());
  });
  
  it('allows admin to create users', async () => {
    const admin = getAdminFirestore();
    await admin.collection('users').doc('admin').set({
      uid: 'admin',
      email: 'admin@test.com',
      role: 'admin'
    });
    
    const db = getFirestore({ uid: 'admin' });
    const doc = db.collection('users').doc('newuser');
    await firebase.assertSucceeds(doc.set({
      uid: 'newuser',
      email: 'new@test.com',
      role: 'parent'
    }));
  });
});
```

---

## Mobile App Integration

### iOS Architecture

**Recommended Structure:**

```
Troop900/
├── App/
│   ├── Troop900App.swift
│   └── AppDelegate.swift
├── Models/
│   ├── User.swift
│   ├── Family.swift
│   ├── Shift.swift
│   ├── Assignment.swift
│   └── Message.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── ShiftsViewModel.swift
│   ├── FamilyViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── Auth/
│   │   └── SignInView.swift
│   ├── Shifts/
│   │   ├── ShiftsListView.swift
│   │   ├── ShiftDetailView.swift
│   │   └── MyShiftsView.swift
│   ├── Family/
│   │   ├── FamilyView.swift
│   │   └── AddFamilyMemberView.swift
│   └── Profile/
│       └── ProfileView.swift
├── Services/
│   ├── FirestoreService.swift
│   ├── AuthService.swift
│   └── NotificationService.swift
└── Utilities/
    ├── Extensions.swift
    └── Constants.swift
```

**Example Model:**

```swift
// Models/Shift.swift
import Foundation
import FirebaseFirestore

struct Shift: Identifiable, Codable {
    @DocumentID var id: String?
    let date: Timestamp
    let startTime: Timestamp
    let endTime: Timestamp
    let title: String
    let description: String
    let requiredVolunteers: Int
    let assignedCount: Int
    let shiftType: String
    let isDraft: Bool
    let createdBy: String
    let createdAt: Timestamp
    let updatedAt: Timestamp
    
    var dateValue: Date {
        date.dateValue()
    }
    
    var startTimeValue: Date {
        startTime.dateValue()
    }
    
    var endTimeValue: Date {
        endTime.dateValue()
    }
    
    var isFull: Bool {
        assignedCount >= requiredVolunteers
    }
    
    var spotsRemaining: Int {
        max(0, requiredVolunteers - assignedCount)
    }
}
```

### Android Architecture (MVVM with Jetpack Compose)

**Recommended Structure:**

```
com.troop900.treelot/
├── TrooApp.kt
├── data/
│   ├── model/
│   │   ├── User.kt
│   │   ├── Family.kt
│   │   ├── Shift.kt
│   │   ├── Assignment.kt
│   │   └── Message.kt
│   ├── repository/
│   │   ├── AuthRepository.kt
│   │   ├── ShiftsRepository.kt
│   │   ├── FamilyRepository.kt
│   │   └── ProfileRepository.kt
│   └── service/
│       ├── FirestoreService.kt
│       └── NotificationService.kt
├── ui/
│   ├── auth/
│   │   ├── SignInScreen.kt
│   │   └── SignInViewModel.kt
│   ├── shifts/
│   │   ├── ShiftsListScreen.kt
│   │   ├── ShiftDetailScreen.kt
│   │   ├── MyShiftsScreen.kt
│   │   └── ShiftsViewModel.kt
│   ├── family/
│   │   ├── FamilyScreen.kt
│   │   ├── AddMemberScreen.kt
│   │   └── FamilyViewModel.kt
│   └── profile/
│       ├── ProfileScreen.kt
│       └── ProfileViewModel.kt
└── util/
    ├── Extensions.kt
    └── Constants.kt
```

**Example Model:**

```kotlin
// data/model/Shift.kt
import com.google.firebase.Timestamp
import com.google.firebase.firestore.DocumentId

data class Shift(
    @DocumentId val id: String = "",
    val date: Timestamp = Timestamp.now(),
    val startTime: Timestamp = Timestamp.now(),
    val endTime: Timestamp = Timestamp.now(),
    val title: String = "",
    val description: String = "",
    val requiredVolunteers: Int = 0,
    val assignedCount: Int = 0,
    val shiftType: String = "",
    val isDraft: Boolean = false,
    val createdBy: String = "",
    val createdAt: Timestamp = Timestamp.now(),
    val updatedAt: Timestamp = Timestamp.now()
) {
    val isFull: Boolean
        get() = assignedCount >= requiredVolunteers
    
    val spotsRemaining: Int
        get() = maxOf(0, requiredVolunteers - assignedCount)
}
```

---

## Testing Strategy

### 1. Firebase Emulator Suite

Test locally without touching production data.

```bash
# Install emulators
firebase init emulators

# Select:
# ◉ Authentication Emulator
# ◉ Firestore Emulator
# ◉ Functions Emulator

# Start emulators
firebase emulators:start

# Emulator UI available at: http://localhost:4000
```

**Connect app to emulators:**

```swift
// iOS
#if DEBUG
let settings = Firestore.firestore().settings
settings.host = "localhost:8080"
settings.isSSLEnabled = false
Firestore.firestore().settings = settings

Auth.auth().useEmulator(withHost: "localhost", port: 9099)
Functions.functions().useEmulator(withHost: "localhost", port: 5001)
#endif
```

```kotlin
// Android
if (BuildConfig.DEBUG) {
    Firebase.firestore.useEmulator("10.0.2.2", 8080)
    Firebase.auth.useEmulator("10.0.2.2", 9099)
    Firebase.functions.useEmulator("10.0.2.2", 5001)
}
```

### 2. Unit Testing Cloud Functions

```typescript
// functions/test/processInviteCode.test.ts
import * as admin from 'firebase-admin';
import { processInviteCode } from '../src/callable/processInviteCode';

// Initialize test environment
const testEnv = require('firebase-functions-test')();

describe('processInviteCode', () => {
  let db: admin.firestore.Firestore;
  
  beforeAll(() => {
    db = admin.firestore();
  });
  
  afterEach(async () => {
    // Clean up test data
    const collections = await db.listCollections();
    for (const collection of collections) {
      const docs = await collection.listDocuments();
      for (const doc of docs) {
        await doc.delete();
      }
    }
  });
  
  afterAll(() => {
    testEnv.cleanup();
  });
  
  it('should create family with valid invite code', async () => {
    // Create test invite code
    const codeRef = await db.collection('invite-codes').add({
      code: 'TEST123',
      isActive: true,
      usedBy: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    // Call function
    const wrapped = testEnv.wrap(processInviteCode);
    const result = await wrapped(
      { inviteCode: 'TEST123', familyName: 'Smith' },
      { auth: { uid: 'user123' } }
    );
    
    expect(result.success).toBe(true);
    expect(result.familyId).toBeDefined();
  });
});
```

---

## Deployment & Monitoring

### Initial Deployment

```bash
# Deploy everything
firebase deploy

# Deploy only specific services
firebase deploy --only firestore:rules
firebase deploy --only functions
firebase deploy --only firestore:indexes
```

### Monitoring

**Firebase Console Monitoring:**
1. **Authentication:** Track daily active users
2. **Firestore:** Monitor reads/writes, document count
3. **Functions:** View invocations, errors, execution time
4. **Cloud Messaging:** Track notification delivery rates

**Set up Alerts:**
```
Firebase Console > Project Settings > Integrations
- Enable Slack/Email alerts for:
  - Function errors
  - Firestore quota warnings
  - Authentication anomalies
```

### Cost Monitoring

**Check usage regularly:**
```
Firebase Console > Usage and billing
- Firestore: Reads, writes, deletes
- Functions: Invocations, compute time
- Cloud Messaging: Messages sent
```

---

## Common Patterns & Best Practices

### 1. Real-time Listeners

**Pattern: Listen to shifts list**

```swift
class ShiftsViewModel: ObservableObject {
    @Published var shifts: [Shift] = []
    private var listener: ListenerRegistration?
    
    func startListening() {
        let db = Firestore.firestore()
        
        listener = db.collection("shifts")
            .whereField("isDraft", isEqualTo: false)
            .whereField("date", isGreaterThan: Date())
            .order(by: "date")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching shifts: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                self?.shifts = documents.compactMap { doc in
                    try? doc.data(as: Shift.self)
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
    }
    
    deinit {
        stopListening()
    }
}
```

### 2. Batch Writes

**Pattern: Create multiple shifts at once**

```kotlin
suspend fun createMultipleShifts(shifts: List<Shift>) {
    val db = Firebase.firestore
    
    db.runBatch { batch ->
        shifts.forEach { shift ->
            val docRef = db.collection("shifts").document()
            batch.set(docRef, shift)
        }
    }.await()
}
```

### 3. Pagination

**Pattern: Load shifts in batches**

```swift
class ShiftsViewModel: ObservableObject {
    @Published var shifts: [Shift] = []
    private var lastDocument: DocumentSnapshot?
    private let pageSize = 20
    
    func loadMore() async throws {
        let db = Firestore.firestore()
        var query = db.collection("shifts")
            .whereField("isDraft", isEqualTo: false)
            .order(by: "date")
            .limit(to: pageSize)
        
        // Start after last document if we have one
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        let snapshot = try await query.getDocuments()
        
        let newShifts = snapshot.documents.compactMap { doc -> Shift? in
            try? doc.data(as: Shift.self)
        }
        
        shifts.append(contentsOf: newShifts)
        lastDocument = snapshot.documents.last
    }
}
```

### 4. Offline Persistence

**Enable offline caching:**

```swift
// iOS
let settings = Firestore.firestore().settings
settings.isPersistenceEnabled = true
Firestore.firestore().settings = settings
```

```kotlin
// Android
Firebase.firestore.firestoreSettings = firestoreSettings {
    isPersistenceEnabled = true
}
```

### 5. Schema Versioning from Day 1

**Always include schemaVersion in documents:**

```swift
// iOS - Creating documents with version
func createShift(title: String, date: Date) async throws {
    let db = Firestore.firestore()
    let data: [String: Any] = [
        "schemaVersion": 1,  // Always include!
        "title": title,
        "date": Timestamp(date: date),
        "createdAt": FieldValue.serverTimestamp()
    ]
    try await db.collection("shifts").addDocument(data: data)
}
```

```kotlin
// Android - Creating documents with version
suspend fun createShift(title: String, date: Date) {
    val db = Firebase.firestore
    val data = hashMapOf(
        "schemaVersion" to 1,  // Always include!
        "title" to title,
        "date" to Timestamp(date),
        "createdAt" to FieldValue.serverTimestamp()
    )
    db.collection("shifts").add(data).await()
}
```

**Why this matters:**
- Enables safe schema evolution
- Supports multiple app versions
- Makes migrations manageable
- See [Firestore Schema Versioning](#firestore-schema-versioning) for complete guide

---

## Troubleshooting Guide

### Common Issues

#### 1. "Permission Denied" Errors

**Symptom:** Firestore queries fail with permission denied

**Solutions:**
- Check security rules match your query
- Verify user is authenticated
- Check user's role/permissions in users collection
- Test with Firebase Emulator

#### 2. Cloud Function Timeouts

**Symptom:** Functions timeout after 60 seconds

**Solutions:**
- Increase timeout: `{ timeoutSeconds: 300 }`
- Optimize database queries (add indexes)
- Use batching for large operations
- Consider breaking into smaller functions

#### 3. "Index Required" Errors

**Symptom:** Firestore query fails asking for index

**Solutions:**
- Click the link in the error message (auto-creates index)
- Or manually add to firestore.indexes.json:

```json
{
  "indexes": [
    {
      "collectionGroup": "shifts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "isDraft", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    }
  ]
}
```

#### 4. FCM Notifications Not Arriving

**Symptoms:** Push notifications don't show up

**Solutions:**
- iOS: Verify APNs certificate uploaded to Firebase
- Android: Check google-services.json is in app/ directory
- Verify FCM token is saved to Firestore
- Check notification permissions granted
- Test with Firebase Console > Cloud Messaging > Send test message

#### 5. "Quota Exceeded" Errors

**Symptom:** Operations fail due to free tier limits

**Solutions:**
- Check Firebase Console > Usage and billing
- Optimize queries (reduce reads)
- Add caching to reduce repeat queries
- Consider upgrading to Blaze plan

#### 6. Schema Version Conflicts

**Symptom:** App crashes or shows wrong data after update

**Solutions:**
- Check if document has `schemaVersion` field
- Verify app handles all schema versions in production
- Use computed properties for backward compatibility:

```swift
// iOS
var displayName: String {
    if schemaVersion >= 2, let name = fullName {
        return name
    } else if let first = firstName, let last = lastName {
        return "\(first) \(last)"
    }
    return "Unknown"
}
```

- Test with emulator using different schema versions
- Consider lazy migration if too many old documents

#### 7. Migration Function Fails Partway Through

**Symptom:** Migration stops or times out

**Solutions:**
- Increase function timeout: `timeoutSeconds: 540`
- Process in smaller batches (100-200 documents)
- Add resume capability (track last migrated ID)
- Use multiple function calls for large datasets:

```typescript
// Track progress
const checkpoint = await db.collection('_migrations').doc('user_v2').get();
const lastMigratedId = checkpoint.data()?.lastId || '';

// Start after checkpoint
const usersSnapshot = await db.collection('users')
  .where('schemaVersion', '<', 2)
  .orderBy(admin.firestore.FieldPath.documentId())
  .startAfter(lastMigratedId)
  .limit(500)
  .get();

// Update checkpoint after batch
await db.collection('_migrations').doc('user_v2').set({
  lastId: lastDocumentId,
  migratedCount: totalMigrated,
  lastRunAt: admin.firestore.FieldValue.serverTimestamp()
});
```

---

## Next Steps

### Week 1: Setup
- ✅ Create Firebase project
- ✅ Enable Authentication (Apple & Google)
- ✅ Create Firestore database
- ✅ Deploy initial security rules
- ✅ Set up iOS/Android apps
- ✅ Add schemaVersion field to all document templates

### Week 2-3: Core Features
- Implement authentication flow
- Create user/family management (with schemaVersion: 1)
- Build shift listing and detail views
- Implement shift signup/cancel
- Test backward compatibility patterns

### Week 4: Cloud Functions
- Deploy all Cloud Functions
- Test invite code flow
- Test shift signup flow
- Set up scheduled reminders

### Week 5: Notifications & Polish
- Implement push notifications
- Add messaging system
- Test attendance tracking
- Build leaderboards

### Week 6: Testing & Launch
- Test with real users (beta group)
- Fix bugs and gather feedback
- Deploy to App Store / Play Store
- Train committee on admin features

---

## Conclusion

You now have a comprehensive guide to building your Troop 900 Tree Lot Shift Scheduler with Firebase. The key takeaways:

1. **Firebase handles your backend** - No servers to manage
2. **Security rules protect your data** - Enforced server-side
3. **Cloud Functions add business logic** - Serverless and scalable
4. **Real-time updates** - Changes sync instantly
5. **Free tier is generous** - Should handle 40-50 users easily
6. **Schema versioning from day 1** - Makes future changes safe and easy

Remember:
- Start small, test often
- Use the Firebase Emulator for development
- Monitor usage to stay within free tier
- Security rules are critical - test them thoroughly
- Include schemaVersion in every document from the start
- Plan for schema evolution with additive changes

**Resources:**
- Firebase Documentation: https://firebase.google.com/docs
- Firebase CLI Reference: https://firebase.google.com/docs/cli
- Firestore Security Rules: https://firebase.google.com/docs/firestore/security/get-started
- Cloud Functions Samples: https://github.com/firebase/functions-samples

Good luck with your project! 🎄🔥
