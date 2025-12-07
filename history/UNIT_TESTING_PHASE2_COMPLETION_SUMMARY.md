# Unit Testing Phase 2: Auth & Onboarding Use Cases - COMPLETED

## Overview

Successfully implemented comprehensive unit tests for all 7 Auth & Onboarding use cases in the Troop900Application package. This phase also included a critical bug fix in `DomainError` that was discovered during testing.

## What Was Implemented

### Test Files Created (7 files)

#### Auth Use Case Tests (`Tests/Troop900ApplicationTests/UseCases/Auth/`)

1. **SignInWithAppleUseCaseTests.swift** (5 tests)
   - Sign in succeeds for new user without existing profile
   - Sign in succeeds for existing unclaimed user
   - Sign in succeeds for existing claimed user
   - Sign in fails when auth repository throws error
   - Sign in handles user repository error gracefully

2. **SignInWithGoogleUseCaseTests.swift** (5 tests)
   - Sign in succeeds for new user without existing profile
   - Sign in succeeds for existing unclaimed user
   - Sign in succeeds for existing claimed user
   - Sign in fails when auth repository throws error
   - Sign in handles user repository error gracefully

3. **SignOutUseCaseTests.swift** (3 tests)
   - Sign out succeeds
   - Sign out fails when auth repository throws error
   - Sign out propagates network error

4. **GetCurrentUserUseCaseTests.swift** (7 tests)
   - Get current user succeeds with no households
   - Get current user succeeds with single household
   - Get current user succeeds with multiple households
   - Get current user handles missing households gracefully
   - Get current user fails when not authenticated
   - Get current user fails when user not found
   - Get current user propagates user repository error

5. **ObserveAuthStateUseCaseTests.swift** (4 tests)
   - Observe auth state returns stream from repository
   - Observe auth state emits nil for signed out state
   - Observe auth state emits user ID for signed in state
   - Observe auth state tracks sign in and sign out transitions

#### Onboarding Use Case Tests (`Tests/Troop900ApplicationTests/UseCases/Onboarding/`)

6. **ProcessInviteCodeUseCaseTests.swift** (8 tests)
   - Process invite code succeeds for parent role
   - Process invite code succeeds for scout role
   - Process invite code succeeds for committee member role
   - Process invite code handles missing household gracefully
   - Process invite code returns failure for invalid code
   - Process invite code returns failure for expired code
   - Process invite code throws when service fails
   - Process invite code throws for already used code

7. **ClaimProfileUseCaseTests.swift** (8 tests)
   - Claim profile succeeds and returns user
   - Claim profile succeeds for scout profile
   - Claim profile handles missing user gracefully
   - Claim profile returns failure for invalid claim code
   - Claim profile returns failure when profile already claimed
   - Claim profile does not fetch user when service returns failure
   - Claim profile throws when service fails
   - Claim profile throws for unauthorized access

## Bug Fix: DomainError Infinite Recursion

### Issue Discovered

During test execution, a crash was occurring with signal code 10 (SIGBUS). Investigation revealed an infinite recursion bug in `DomainError.debugMessage`:

```swift
// BEFORE (buggy)
public var debugMessage: String {
    switch self {
    // ... specific cases ...
    default:
        return "\(self)"  // ← Calls description → debugMessage → infinite loop!
    }
}
```

### Fix Applied

Updated `DomainError.debugMessage` in `Troop900Domain` to explicitly handle all cases without relying on string interpolation:

```swift
// AFTER (fixed)
public var debugMessage: String {
    switch self {
    case .notAuthenticated:
        return "DomainError.notAuthenticated"
    case .unauthorized:
        return "DomainError.unauthorized"
    // ... all cases explicitly handled ...
    }
}
```

**File Modified:** `ios/Packages/Troop900Domain/Sources/Troop900Domain/Errors/DomainError.swift`

## Mock Updates

### MockAuthRepository

Added support for testing `observeAuthState()`:

```swift
/// Values to emit from observeAuthState() stream
public var authStateValues: [String?] = []

public func observeAuthState() -> AsyncStream<String?> {
    AsyncStream { continuation in
        if !authStateValues.isEmpty {
            for value in authStateValues {
                continuation.yield(value)
            }
        } else {
            continuation.yield(_currentUserId)
        }
        continuation.finish()
    }
}
```

## Directory Structure

```
Tests/Troop900ApplicationTests/
└── UseCases/
    ├── Auth/
    │   ├── SignInWithAppleUseCaseTests.swift
    │   ├── SignInWithGoogleUseCaseTests.swift
    │   ├── SignOutUseCaseTests.swift
    │   ├── GetCurrentUserUseCaseTests.swift
    │   └── ObserveAuthStateUseCaseTests.swift
    └── Onboarding/
        ├── ProcessInviteCodeUseCaseTests.swift
        └── ClaimProfileUseCaseTests.swift
```

## Test Execution Results

```
Test run with 41 tests in 8 suites passed after 0.002 seconds.

Suites:
- Application Package Tests: 1 test ✓
- SignInWithAppleUseCase Tests: 5 tests ✓
- SignInWithGoogleUseCase Tests: 5 tests ✓
- SignOutUseCase Tests: 3 tests ✓
- GetCurrentUserUseCase Tests: 7 tests ✓
- ObserveAuthStateUseCase Tests: 4 tests ✓
- ProcessInviteCodeUseCase Tests: 8 tests ✓
- ClaimProfileUseCase Tests: 8 tests ✓
```

## Test Coverage Summary

| Use Case | Tests | Coverage Areas |
|----------|-------|----------------|
| SignInWithAppleUseCase | 5 | New user, unclaimed user, claimed user, auth errors, graceful error handling |
| SignInWithGoogleUseCase | 5 | New user, unclaimed user, claimed user, auth errors, graceful error handling |
| SignOutUseCase | 3 | Success, auth errors, error propagation |
| GetCurrentUserUseCase | 7 | No households, single/multiple households, missing households, auth errors |
| ObserveAuthStateUseCase | 4 | Stream emission, nil state, user ID state, state transitions |
| ProcessInviteCodeUseCase | 8 | Role-based success, missing data handling, failure responses, service errors |
| ClaimProfileUseCase | 8 | Profile claiming, scout profiles, graceful failures, service errors |

## Statistics

| Metric | Count |
|--------|-------|
| Test files created | 7 |
| Tests added | 40 |
| Total tests (including Phase 1) | 41 |
| Test suites | 8 |
| Use cases tested | 7 |

## Test Patterns Used

### 1. Success Path Testing
Each use case has tests for the primary success scenarios with different configurations.

### 2. Error Handling
Tests verify both error propagation (when errors should bubble up) and graceful handling (when errors are expected and handled).

### 3. Mock Configuration
```swift
// Configure success
mockOnboardingService.claimProfileResult = .success(ClaimProfileResult(...))

// Configure failure
mockOnboardingService.claimProfileResult = .failure(DomainError.networkError)
```

### 4. Call Verification
```swift
#expect(mockOnboardingService.claimProfileCallCount == 1)
#expect(mockOnboardingService.claimProfileCalledWith[0].claimCode == claimCode)
```

### 5. Async Stream Testing
```swift
var receivedValues: [String?] = []
for await userId in stream {
    receivedValues.append(userId)
    if receivedValues.count >= expectedValues.count { break }
}
#expect(receivedValues == expectedValues)
```

## Files Created/Modified

### New Test Files
- `Tests/Troop900ApplicationTests/UseCases/Auth/SignInWithAppleUseCaseTests.swift`
- `Tests/Troop900ApplicationTests/UseCases/Auth/SignInWithGoogleUseCaseTests.swift`
- `Tests/Troop900ApplicationTests/UseCases/Auth/SignOutUseCaseTests.swift`
- `Tests/Troop900ApplicationTests/UseCases/Auth/GetCurrentUserUseCaseTests.swift`
- `Tests/Troop900ApplicationTests/UseCases/Auth/ObserveAuthStateUseCaseTests.swift`
- `Tests/Troop900ApplicationTests/UseCases/Onboarding/ProcessInviteCodeUseCaseTests.swift`
- `Tests/Troop900ApplicationTests/UseCases/Onboarding/ClaimProfileUseCaseTests.swift`

### Modified Files
- `Tests/Troop900ApplicationTests/Mocks/Repositories/MockAuthRepository.swift` (added `authStateValues`)
- `ios/Packages/Troop900Domain/Sources/Troop900Domain/Errors/DomainError.swift` (bug fix)

## Verification

- [x] All 41 tests pass
- [x] No compiler warnings in test code
- [x] All 7 Auth & Onboarding use cases covered
- [x] Success, failure, and error scenarios tested
- [x] Mock interactions verified
- [x] DomainError bug fixed and tests no longer crash

## Next Steps

Phase 3 will implement tests for Template & Schedule Management use cases:
- CreateShiftTemplateUseCase
- UpdateShiftTemplateUseCase
- GenerateSeasonScheduleUseCase
- CreateShiftUseCase
- UpdateDraftShiftUseCase
- PublishScheduleUseCase

Estimated: 6 use cases, ~30-35 tests
