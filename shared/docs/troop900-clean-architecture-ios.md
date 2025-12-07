# Troop 900 Tree Lot Scheduler
## Clean Architecture iOS Implementation Guide (Revised)

**Version:** 4.0  
**Date:** December 2024  
**Project:** iOS implementation following Clean Architecture principles

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Layer Definitions](#layer-definitions)
3. [Enforcing Architecture with Swift Package Manager](#enforcing-architecture-with-swift-package-manager)
4. [Project Structure](#project-structure)
5. [Domain Layer](#domain-layer)
6. [Data Layer](#data-layer)
7. [Presentation Layer](#presentation-layer)
8. [Dependency Injection](#dependency-injection)
9. [Use Case Catalog](#use-case-catalog)
10. [Observable Use Cases](#observable-use-cases)
11. [Boundary Objects (DTOs)](#boundary-objects-dtos)
12. [Repository and Service Protocols](#repository-and-service-protocols)
13. [Implementation Examples](#implementation-examples)
14. [Error Handling](#error-handling)
15. [Testing Strategy](#testing-strategy)

---

## Architecture Overview

This application follows **Clean Architecture** principles where:

- **Firebase is an implementation detail** hidden behind repository and service abstractions
- **The domain layer is completely independent** of Firebase, UIKit, SwiftUI, or any framework
- **Use cases orchestrate business logic** through async `execute` methods
- **Boundary objects live in the Domain layer** as the contract between Use Cases and consumers
- **Repositories handle data persistence** (Firestore reads/writes)
- **Services handle remote operations** (Cloud Functions invocations)
- **Dependencies flow inward** - outer layers depend on inner layers, never the reverse

### The Dependency Rule

```
┌─────────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                              │
│   (SwiftUI Views, ViewModels, UI State)                             │
│   Consumes boundary objects defined in Domain Layer                  │
│                                                                      │
│   ┌──────────────────────────────────────────────────────────────┐  │
│   │                      DOMAIN LAYER                             │  │
│   │   (Use Cases, Domain Entities, Repository/Service Protocols)  │  │
│   │   (Boundary Objects - Use Case Input/Output Types)            │  │
│   │                                                               │  │
│   │   ┌────────────────────────────────────────────────────────┐ │  │
│   │   │                   DOMAIN CORE                           │ │  │
│   │   │   (Business Rules, Value Objects)                       │ │  │
│   │   └────────────────────────────────────────────────────────┘ │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                                   │
│   (Firebase Implementations, Mappers, Network)                       │
│   Implements protocols defined in Domain Layer                       │
│                                                                      │
│   ┌─────────────────────────┐  ┌─────────────────────────────────┐  │
│   │      REPOSITORIES       │  │           SERVICES              │  │
│   │  (Firestore Data Access)│  │  (Cloud Functions Invocations)  │  │
│   └─────────────────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Domain entities never cross layer boundaries** - Use boundary objects (DTOs)
2. **Repository protocols live in the Domain layer** - Handle data persistence (Firestore)
3. **Service protocols live in the Domain layer** - Handle remote operations (Cloud Functions)
4. **Boundary objects live in the Domain layer** - They are the use case's contract with consumers
5. **Use cases have a single `execute` method** - All use cases are async
6. **Firebase types never appear in Domain** - All Firebase-specific code is in Data layer
7. **View models depend on Use Cases** - Never on repositories or services directly

### Repository vs Service Distinction

| Aspect | Repository | Service |
|--------|------------|---------|
| **Purpose** | Data persistence and retrieval | Remote operation invocation |
| **Data Source** | Firestore (local cache + cloud) | Cloud Functions |
| **Operations** | CRUD on stored entities | Business operations, complex transactions |
| **Examples** | GetUser, SaveShift, ObserveAssignments | CheckIn, GenerateSchedule, ProcessInviteCode |
| **Caching** | Usually cached/observable | Typically not cached |
| **Complexity** | Simple data access | Business logic execution |

---

## Layer Definitions

### Domain Layer (Innermost)

The domain layer contains:
- **Entities**: Core business objects (User, Shift, Assignment, etc.)
- **Value Objects**: Immutable types representing domain concepts (UserRole, AttendanceStatus, etc.)
- **Repository Protocols**: Interfaces for data persistence (Firestore operations)
- **Service Protocols**: Interfaces for remote operations (Cloud Functions)
- **Use Cases**: Application-specific business rules
- **Boundary Objects**: Input/Output types for use cases (Request/Response DTOs)
- **Domain Errors**: Business-level error definitions

**Key Rule**: This layer has ZERO dependencies on external frameworks. No Firebase, no UIKit, no SwiftUI.

### Data Layer

The data layer contains:
- **Repository Implementations**: Firestore-backed implementations of domain repository protocols
- **Service Implementations**: Cloud Functions-backed implementations of domain service protocols
- **Data Sources**: Firebase Authentication, Firestore, Cloud Functions clients
- **Mappers**: Convert between Firebase DTOs and Domain entities
- **Data Transfer Objects (DTOs)**: External representations of data (Firebase response types)

**Key Rule**: This layer knows about Firebase but the domain layer doesn't.

### Presentation Layer (Outermost)

The presentation layer contains:
- **Views**: SwiftUI views
- **ViewModels**: ObservableObject classes that use Use Cases
- **UI State**: View-specific state objects
- **Coordinators/Routers**: Navigation logic

**Key Rule**: ViewModels call Use Cases, receive boundary objects (defined in Domain layer), and never see domain entities.

---

## Enforcing Architecture with Swift Package Manager

While Clean Architecture provides logical boundaries between layers, these boundaries are only enforced by developer discipline in a traditional Xcode project structure. Swift Package Manager (SPM) local packages provide **compile-time enforcement** of the dependency rule, making architectural violations impossible.

### Why Use Local Packages?

1. **Compile-Time Enforcement**: If the Domain package doesn't depend on Firebase, you literally cannot import Firebase types in Domain code—the compiler prevents it.

2. **Clear Dependency Graph**: The `Package.swift` manifest explicitly declares what each layer can access, making the architecture visible and auditable.

3. **Faster Incremental Builds**: Changes to one package only rebuild that package and its dependents, not the entire project.

4. **Improved Testability**: Each package can have its own test target with isolated dependencies.

5. **Better Code Organization**: Packages create natural boundaries that prevent spaghetti code and circular dependencies.

### Package Structure

```
Troop900/
├── Troop900.xcodeproj
├── Troop900/                          # Main app target (thin shell)
│   ├── Troop900App.swift
│   └── DependencyContainer.swift
│
└── Packages/
    ├── Troop900Domain/               # Domain Layer Package
    │   ├── Package.swift
    │   ├── Sources/
    │   │   └── Troop900Domain/
    │   │       ├── Entities/
    │   │       ├── ValueObjects/
    │   │       ├── Repositories/
    │   │       ├── Services/
    │   │       ├── UseCases/
    │   │       ├── BoundaryObjects/
    │   │       └── Errors/
    │   └── Tests/
    │       └── Troop900DomainTests/
    │
    ├── Troop900Data/                 # Data Layer Package
    │   ├── Package.swift
    │   ├── Sources/
    │   │   └── Troop900Data/
    │   │       ├── Repositories/
    │   │       ├── Services/
    │   │       ├── DataSources/
    │   │       ├── DTOs/
    │   │       └── Mappers/
    │   └── Tests/
    │       └── Troop900DataTests/
    │
    └── Troop900Presentation/         # Presentation Layer Package
        ├── Package.swift
        ├── Sources/
        │   └── Troop900Presentation/
        │       ├── Views/
        │       ├── ViewModels/
        │       ├── UIState/
        │       └── Coordinators/
        └── Tests/
            └── Troop900PresentationTests/
```

### Package Manifests

#### Domain Package (No External Dependencies)

```swift
// ios/Packages/Troop900Domain/Package.swift

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900Domain",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Troop900Domain",
            targets: ["Troop900Domain"]
        ),
    ],
    dependencies: [
        // INTENTIONALLY EMPTY
        // The Domain layer has ZERO external dependencies.
        // This is the innermost layer of Clean Architecture.
    ],
    targets: [
        .target(
            name: "Troop900Domain",
            dependencies: [],
            path: "Sources/Troop900Domain"
        ),
        .testTarget(
            name: "Troop900DomainTests",
            dependencies: ["Troop900Domain"],
            path: "Tests/Troop900DomainTests"
        ),
    ]
)
```

**Key Point**: The Domain package has an empty `dependencies` array. This is what enforces the innermost layer rule—if a developer tries to `import FirebaseFirestore` in any Domain file, the compiler will produce an error because the package doesn't have access to that dependency.

#### Data Package (Depends on Domain and Firebase)

```swift
// ios/Packages/Troop900Data/Package.swift

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900Data",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Troop900Data",
            targets: ["Troop900Data"]
        ),
    ],
    dependencies: [
        // Local Domain package
        .package(path: "../Troop900Domain"),
        
        // Firebase SDK
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.0.0"
        ),
    ],
    targets: [
        .target(
            name: "Troop900Data",
            dependencies: [
                "Troop900Domain",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Troop900Data"
        ),
        .testTarget(
            name: "Troop900DataTests",
            dependencies: ["Troop900Data"],
            path: "Tests/Troop900DataTests"
        ),
    ]
)
```

**Key Point**: The Data package depends on `Troop900Domain` and Firebase. This allows it to implement the repository and service protocols defined in Domain using Firebase as the underlying technology.

#### Presentation Package (Depends on Domain Only)

```swift
// Packages/Troop900Presentation/Package.swift

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900Presentation",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Troop900Presentation",
            targets: ["Troop900Presentation"]
        ),
    ],
    dependencies: [
        // Local Domain package
        .package(path: "../Troop900Domain"),
    ],
    targets: [
        .target(
            name: "Troop900Presentation",
            dependencies: [
                "Troop900Domain",
            ],
            path: "Sources/Troop900Presentation"
        ),
        .testTarget(
            name: "Troop900PresentationTests",
            dependencies: ["Troop900Presentation"],
            path: "Tests/Troop900PresentationTests"
        ),
    ]
)
```

**Key Point**: The Presentation package depends only on `Troop900Domain`, NOT on `Troop900Data`. ViewModels work with use case protocols and boundary objects from Domain. They never see Firebase types or Data layer implementations.

### Dependency Graph Visualization

```
                    ┌─────────────────────────┐
                    │      Main App Target    │
                    │   (DependencyContainer) │
                    └───────────┬─────────────┘
                                │
            ┌───────────────────┼───────────────────┐
            │                   │                   │
            ▼                   ▼                   ▼
┌───────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Troop900Presentation │ │  Troop900Data   │ │ Troop900Domain │
│   (Views, VMs)    │ │ (Firebase Impl) │ │ (Use Cases)    │
└─────────┬─────────┘ └────────┬────────┘ └────────────────┘
          │                    │                    ▲
          │                    │                    │
          └────────────────────┴────────────────────┘
                         depends on
```

The main app target imports all three packages and is responsible for wiring up dependencies (injecting Data implementations into Domain protocols for use by Presentation).

### Adding Packages to the Xcode Project

1. **Create the Packages directory** in your project root:
   ```bash
   mkdir -p Packages/Troop900Domain/Sources/Troop900Domain
   mkdir -p Packages/Troop900Domain/Tests/Troop900DomainTests
   mkdir -p Packages/Troop900Data/Sources/Troop900Data
   mkdir -p Packages/Troop900Data/Tests/Troop900DataTests
   mkdir -p Packages/Troop900Presentation/Sources/Troop900Presentation
   mkdir -p Packages/Troop900Presentation/Tests/Troop900PresentationTests
   ```

2. **Create the Package.swift files** as shown above in each package directory.

3. **Add the local packages to Xcode**:
   - Open your Xcode project
   - Select File → Add Package Dependencies...
   - Click "Add Local..."
   - Navigate to `Packages/Troop900Domain` and add it
   - Repeat for `Troop900Data` and `Troop900Presentation`

4. **Link packages to your app target**:
   - Select your app target in Xcode
   - Go to "General" → "Frameworks, Libraries, and Embedded Content"
   - Add `Troop900Domain`, `Troop900Data`, and `Troop900Presentation`

### Migrating Existing Code

When migrating from a flat project structure to packages:

1. **Start with Domain**: Move entities, value objects, repository protocols, service protocols, use cases, and boundary objects to the Domain package first. Ensure it compiles with no external imports.

2. **Move Data layer next**: Move Firebase implementations, mappers, and DTOs to the Data package. Update imports to use `import Troop900Domain`.

3. **Move Presentation last**: Move views and view models to the Presentation package. Update imports to use `import Troop900Domain`.

4. **Update the main app**: The main app target becomes a thin shell that primarily handles dependency injection and app lifecycle.

#### Example: Updating Imports in Data Layer

Before (flat structure):
```swift
// FirestoreUserRepository.swift
import Foundation
import FirebaseFirestore

class FirestoreUserRepository: UserRepository {
    // ...
}
```

After (package structure):
```swift
// Sources/Troop900Data/Repositories/FirestoreUserRepository.swift
import Foundation
import FirebaseFirestore
import Troop900Domain  // Import Domain to access UserRepository protocol

public class FirestoreUserRepository: UserRepository {
    // ...
}
```

#### Example: Updating Imports in Presentation Layer

Before (flat structure):
```swift
// ShiftListViewModel.swift
import SwiftUI

@MainActor
class ShiftListViewModel: ObservableObject {
    private let getWeekScheduleUseCase: GetWeekScheduleUseCaseProtocol
    // ...
}
```

After (package structure):
```swift
// Sources/Troop900Presentation/ViewModels/ShiftListViewModel.swift
import SwiftUI
import Troop900Domain  // Import Domain to access use case protocols

@MainActor
public class ShiftListViewModel: ObservableObject {
    private let getWeekScheduleUseCase: GetWeekScheduleUseCaseProtocol
    // ...
}
```

### Access Control Considerations

When using packages, you need to be intentional about access control:

1. **Public**: Types that need to be visible outside the package (protocols, entities, use cases, view models)

2. **Internal**: Types only used within the package (helpers, private implementations)

3. **Package** (Swift 5.9+): Types visible to other targets within the same package but not outside

#### Domain Package Access Control

```swift
// All types that other packages need must be public

// Entities
public struct User: Sendable {
    public let id: String
    public let email: String
    // ...
    
    public init(id: String, email: String, /* ... */) {
        self.id = id
        self.email = email
        // ...
    }
}

// Repository Protocols
public protocol UserRepository: Sendable {
    func getUser(id: String) async throws -> User
    func observeUser(id: String) -> AsyncThrowingStream<User, Error>
}

// Use Cases
public protocol GetCurrentUserUseCaseProtocol: Sendable {
    func execute() async throws -> CurrentUserResponse
}

public final class GetCurrentUserUseCase: GetCurrentUserUseCaseProtocol {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    public init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    public func execute() async throws -> CurrentUserResponse {
        // ...
    }
}
```

#### Data Package Access Control

```swift
// Implementation classes need public init for dependency injection

public final class FirestoreUserRepository: UserRepository {
    private let firestore: Firestore
    private let mapper: UserMapper
    
    public init(firestore: Firestore, mapper: UserMapper) {
        self.firestore = firestore
        self.mapper = mapper
    }
    
    public func getUser(id: String) async throws -> User {
        // ...
    }
}

// Mappers can be internal if only used within the Data package
internal struct UserMapper {
    func toDomain(_ dto: UserDTO) -> User {
        // ...
    }
}

// Or public if needed for testing or DI
public struct UserMapper {
    public init() {}
    
    public func toDomain(_ dto: UserDTO) -> User {
        // ...
    }
}
```

### Dependency Injection with Packages

The main app target is responsible for creating concrete implementations and injecting them:

```swift
// Troop900/DependencyContainer.swift (in main app target)

import Foundation
import Troop900Domain
import Troop900Data
import Troop900Presentation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

@MainActor
final class DependencyContainer {
    
    // MARK: - Firebase Data Sources (Internal to DI)
    
    private lazy var firestore: Firestore = {
        Firestore.firestore()
    }()
    
    private lazy var auth: Auth = {
        Auth.auth()
    }()
    
    private lazy var functions: Functions = {
        Functions.functions()
    }()
    
    // MARK: - Mappers
    
    private lazy var userMapper = UserMapper()
    private lazy var shiftMapper = ShiftMapper()
    private lazy var assignmentMapper = AssignmentMapper()
    
    // MARK: - Repositories (Data Layer implementations of Domain protocols)
    
    lazy var authRepository: AuthRepository = {
        FirebaseAuthRepository(auth: auth)
    }()
    
    lazy var userRepository: UserRepository = {
        FirestoreUserRepository(
            firestore: firestore,
            mapper: userMapper
        )
    }()
    
    lazy var shiftRepository: ShiftRepository = {
        FirestoreShiftRepository(
            firestore: firestore,
            mapper: shiftMapper
        )
    }()
    
    // MARK: - Services (Data Layer implementations of Domain protocols)
    
    lazy var attendanceService: AttendanceService = {
        CloudFunctionsAttendanceService(
            functions: functions,
            mapper: attendanceMapper
        )
    }()
    
    // MARK: - Use Case Factories
    
    func makeGetCurrentUserUseCase() -> GetCurrentUserUseCaseProtocol {
        GetCurrentUserUseCase(
            authRepository: authRepository,
            userRepository: userRepository
        )
    }
    
    func makeSignUpForShiftUseCase() -> SignUpForShiftUseCaseProtocol {
        SignUpForShiftUseCase(
            shiftRepository: shiftRepository,
            assignmentRepository: assignmentRepository,
            userRepository: userRepository,
            shiftSignupService: shiftSignupService
        )
    }
    
    // MARK: - ViewModel Factories
    
    func makeShiftListViewModel() -> ShiftListViewModel {
        ShiftListViewModel(
            getWeekScheduleUseCase: makeGetWeekScheduleUseCase(),
            observeShiftAssignmentsUseCase: makeObserveShiftAssignmentsUseCase()
        )
    }
    
    func makeShiftDetailViewModel(shiftId: String) -> ShiftDetailViewModel {
        ShiftDetailViewModel(
            shiftId: shiftId,
            observeShiftUseCase: makeObserveShiftUseCase(),
            signUpForShiftUseCase: makeSignUpForShiftUseCase()
        )
    }
}
```

### Testing Benefits

Each package can have isolated tests with appropriate dependencies:

#### Domain Tests (Pure Unit Tests)

```swift
// Packages/Troop900Domain/Tests/Troop900DomainTests/SignUpForShiftUseCaseTests.swift

import XCTest
@testable import Troop900Domain

final class SignUpForShiftUseCaseTests: XCTestCase {
    
    var sut: SignUpForShiftUseCase!
    var mockShiftRepository: MockShiftRepository!
    var mockUserRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockShiftRepository = MockShiftRepository()
        mockUserRepository = MockUserRepository()
        
        sut = SignUpForShiftUseCase(
            shiftRepository: mockShiftRepository,
            userRepository: mockUserRepository,
            // ...
        )
    }
    
    func test_execute_withValidRequest_succeeds() async throws {
        // Pure domain logic testing - no Firebase involved
    }
}

// Mock implementations live in the test target
final class MockShiftRepository: ShiftRepository {
    var getShiftResult: Result<Shift, Error> = .failure(TestError.notConfigured)
    
    func getShift(id: String) async throws -> Shift {
        try getShiftResult.get()
    }
    
    // ...
}
```

#### Data Tests (Integration Tests)

```swift
// Packages/Troop900Data/Tests/Troop900DataTests/FirestoreUserRepositoryTests.swift

import XCTest
@testable import Troop900Data
import Troop900Domain
import FirebaseFirestore

final class FirestoreUserRepositoryTests: XCTestCase {
    
    var sut: FirestoreUserRepository!
    var firestore: Firestore!
    
    override func setUp() {
        super.setUp()
        // Configure Firebase emulator for testing
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        
        firestore = Firestore.firestore()
        sut = FirestoreUserRepository(
            firestore: firestore,
            mapper: UserMapper()
        )
    }
    
    func test_getUser_withExistingUser_returnsUser() async throws {
        // Test actual Firestore integration
    }
}
```

### Architectural Violation Prevention

With packages, the compiler prevents architectural violations:

#### ❌ Violation: Importing Firebase in Domain

```swift
// Packages/Troop900Domain/Sources/Troop900Domain/UseCases/SomeUseCase.swift

import Foundation
import FirebaseFirestore  // ❌ COMPILER ERROR: No such module 'FirebaseFirestore'

class SomeUseCase {
    // ...
}
```

The Domain package doesn't list Firebase as a dependency, so this import fails at compile time.

#### ❌ Violation: Importing Data in Presentation

```swift
// Packages/Troop900Presentation/Sources/Troop900Presentation/ViewModels/SomeViewModel.swift

import SwiftUI
import Troop900Domain
import Troop900Data  // ❌ COMPILER ERROR: No such module 'Troop900Data'

class SomeViewModel: ObservableObject {
    // ...
}
```

The Presentation package doesn't depend on Data, preventing direct access to Firebase implementations.

#### ❌ Violation: Using Firebase Types in ViewModel

```swift
// Even if someone tried to use Firebase types via Domain, it won't work

import Troop900Domain

class SomeViewModel: ObservableObject {
    func doSomething() {
        let query: Query = ...  // ❌ COMPILER ERROR: Cannot find type 'Query' in scope
    }
}
```

Firebase types simply aren't available in the Presentation layer.

### Summary of Package Benefits

| Benefit | Description |
|---------|-------------|
| **Compile-Time Safety** | Impossible to violate the dependency rule |
| **Explicit Dependencies** | Package.swift manifests document what each layer can access |
| **Faster Builds** | Incremental builds only recompile affected packages |
| **Isolated Testing** | Each package has its own test target |
| **Enforced Boundaries** | No accidental coupling between layers |
| **Team Scalability** | Different teams can own different packages |
| **Reusability** | Domain package could theoretically be used in other apps |

### Migration Checklist

- [ ] Create `Packages/` directory structure
- [ ] Create `Package.swift` for each layer
- [ ] Move Domain code first (should compile with no external imports)
- [ ] Move Data code (add `import Troop900Domain`)
- [ ] Move Presentation code (add `import Troop900Domain`)
- [ ] Update main app target to import all packages
- [ ] Update DependencyContainer for cross-package injection
- [ ] Add `public` access modifiers to exported types
- [ ] Update test targets for each package
- [ ] Verify clean build with no circular dependencies

---

## Project Structure

```
Troop900/
├── App/
│   ├── Troop900App.swift
│   ├── AppDelegate.swift
│   └── DependencyContainer.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── User.swift
│   │   ├── Household.swift
│   │   ├── FamilyUnit.swift
│   │   ├── Shift.swift
│   │   ├── Assignment.swift
│   │   ├── ShiftTemplate.swift
│   │   ├── Season.swift
│   │   ├── Message.swift
│   │   ├── InviteCode.swift
│   │   └── AttendanceRecord.swift
│   │
│   ├── ValueObjects/
│   │   ├── UserRole.swift
│   │   ├── AccountStatus.swift
│   │   ├── ShiftStatus.swift
│   │   ├── AttendanceStatus.swift
│   │   ├── AssignmentType.swift
│   │   ├── StaffingStatus.swift
│   │   ├── SeasonStatus.swift
│   │   └── TargetAudience.swift
│   │
│   ├── Repositories/
│   │   ├── AuthRepository.swift
│   │   ├── UserRepository.swift
│   │   ├── HouseholdRepository.swift
│   │   ├── ShiftRepository.swift
│   │   ├── AssignmentRepository.swift
│   │   ├── SeasonRepository.swift
│   │   ├── TemplateRepository.swift
│   │   └── MessageRepository.swift
│   │
│   ├── Services/
│   │   ├── OnboardingService.swift
│   │   ├── FamilyManagementService.swift
│   │   ├── AttendanceService.swift
│   │   ├── SeasonManagementService.swift
│   │   ├── TemplateManagementService.swift
│   │   ├── LeaderboardService.swift
│   │   └── MessagingService.swift
│   │
│   ├── UseCases/
│   │   ├── Auth/
│   │   │   ├── SignInWithAppleUseCase.swift
│   │   │   ├── SignInWithGoogleUseCase.swift
│   │   │   ├── SignOutUseCase.swift
│   │   │   ├── GetCurrentUserUseCase.swift
│   │   │   └── ObserveAuthStateUseCase.swift
│   │   │
│   │   ├── Onboarding/
│   │   │   ├── ProcessInviteCodeUseCase.swift
│   │   │   ├── ClaimProfileUseCase.swift
│   │   │   └── CheckOnboardingStatusUseCase.swift
│   │   │
│   │   ├── Family/
│   │   │   ├── AddFamilyMemberUseCase.swift
│   │   │   ├── GetHouseholdMembersUseCase.swift
│   │   │   ├── LinkScoutToHouseholdUseCase.swift
│   │   │   ├── RegenerateHouseholdLinkCodeUseCase.swift
│   │   │   └── DeactivateFamilyUseCase.swift
│   │   │
│   │   ├── Shifts/
│   │   │   ├── GetWeekScheduleUseCase.swift
│   │   │   ├── GetShiftDetailsUseCase.swift
│   │   │   ├── SignUpForShiftUseCase.swift
│   │   │   ├── CancelAssignmentUseCase.swift
│   │   │   ├── GetMyShiftsUseCase.swift
│   │   │   ├── GetFamilyScheduleUseCase.swift
│   │   │   ├── ObserveShiftUseCase.swift
│   │   │   └── ObserveShiftAssignmentsUseCase.swift
│   │   │
│   │   ├── Attendance/
│   │   │   ├── CheckInUseCase.swift
│   │   │   ├── CheckOutUseCase.swift
│   │   │   ├── GetAttendanceHistoryUseCase.swift
│   │   │   └── AdminManualCheckInOutUseCase.swift
│   │   │
│   │   ├── Admin/
│   │   │   ├── GenerateScheduleUseCase.swift
│   │   │   ├── PublishScheduleUseCase.swift
│   │   │   ├── CreateSeasonUseCase.swift
│   │   │   ├── ManageTemplatesUseCase.swift
│   │   │   ├── GenerateInviteCodesUseCase.swift
│   │   │   └── GetLeaderboardUseCase.swift
│   │   │
│   │   └── Messaging/
│   │       ├── SendMessageUseCase.swift
│   │       └── GetMessagesUseCase.swift
│   │
│   ├── BoundaryObjects/
│   │   ├── Auth/
│   │   │   ├── SignInResponse.swift
│   │   │   ├── CurrentUserResponse.swift
│   │   │   └── AuthStateResponse.swift
│   │   │
│   │   ├── Shifts/
│   │   │   ├── WeekScheduleResponse.swift
│   │   │   ├── ShiftDetailResponse.swift
│   │   │   ├── SignUpRequest.swift
│   │   │   ├── SignUpResponse.swift
│   │   │   ├── ShiftSummary.swift
│   │   │   └── AssignmentInfo.swift
│   │   │
│   │   ├── Attendance/
│   │   │   ├── CheckInRequest.swift
│   │   │   ├── CheckInResponse.swift
│   │   │   └── AttendanceHistoryResponse.swift
│   │   │
│   │   └── Admin/
│   │       ├── ScheduleGenerationRequest.swift
│   │       ├── ScheduleGenerationResponse.swift
│   │       └── LeaderboardResponse.swift
│   │
│   └── Errors/
│       └── DomainError.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── FirebaseAuthRepository.swift
│   │   ├── FirestoreUserRepository.swift
│   │   ├── FirestoreHouseholdRepository.swift
│   │   ├── FirestoreShiftRepository.swift
│   │   ├── FirestoreAssignmentRepository.swift
│   │   ├── FirestoreSeasonRepository.swift
│   │   ├── FirestoreTemplateRepository.swift
│   │   └── FirestoreMessageRepository.swift
│   │
│   ├── Services/
│   │   ├── CloudFunctionsOnboardingService.swift
│   │   ├── CloudFunctionsFamilyManagementService.swift
│   │   ├── CloudFunctionsAttendanceService.swift
│   │   ├── CloudFunctionsSeasonManagementService.swift
│   │   ├── CloudFunctionsTemplateManagementService.swift
│   │   ├── CloudFunctionsLeaderboardService.swift
│   │   └── CloudFunctionsMessagingService.swift
│   │
│   ├── DataSources/
│   │   ├── FirestoreDataSource.swift
│   │   ├── CloudFunctionsDataSource.swift
│   │   └── AuthDataSource.swift
│   │
│   ├── DTOs/
│   │   ├── UserDTO.swift
│   │   ├── HouseholdDTO.swift
│   │   ├── ShiftDTO.swift
│   │   ├── AssignmentDTO.swift
│   │   ├── AttendanceDTO.swift
│   │   └── CloudFunctionResponses.swift
│   │
│   └── Mappers/
│       ├── UserMapper.swift
│       ├── ShiftMapper.swift
│       ├── AssignmentMapper.swift
│       ├── AttendanceMapper.swift
│       └── HouseholdMapper.swift
│
├── Presentation/
│   ├── App/
│   │   └── ContentView.swift
│   │
│   ├── Auth/
│   │   ├── Views/
│   │   │   ├── LoginView.swift
│   │   │   └── OnboardingView.swift
│   │   └── ViewModels/
│   │       ├── LoginViewModel.swift
│   │       └── OnboardingViewModel.swift
│   │
│   ├── Schedule/
│   │   ├── Views/
│   │   │   ├── WeekScheduleView.swift
│   │   │   ├── ShiftDetailView.swift
│   │   │   └── ShiftCardView.swift
│   │   └── ViewModels/
│   │       ├── WeekScheduleViewModel.swift
│   │       └── ShiftDetailViewModel.swift
│   │
│   ├── MyShifts/
│   │   ├── Views/
│   │   │   └── MyShiftsView.swift
│   │   └── ViewModels/
│   │       └── MyShiftsViewModel.swift
│   │
│   ├── Family/
│   │   ├── Views/
│   │   │   ├── FamilyManagementView.swift
│   │   │   └── AddFamilyMemberView.swift
│   │   └── ViewModels/
│   │       └── FamilyManagementViewModel.swift
│   │
│   ├── Admin/
│   │   ├── Views/
│   │   │   ├── AdminDashboardView.swift
│   │   │   ├── ScheduleGeneratorView.swift
│   │   │   └── InviteCodeGeneratorView.swift
│   │   └── ViewModels/
│   │       ├── AdminDashboardViewModel.swift
│   │       └── ScheduleGeneratorViewModel.swift
│   │
│   └── Shared/
│       ├── Components/
│       │   ├── LoadingView.swift
│       │   ├── ErrorView.swift
│       │   └── StaffingIndicator.swift
│       └── Extensions/
│           └── View+Extensions.swift
│
└── Resources/
    ├── Assets.xcassets
    └── GoogleService-Info.plist
```

---

## Domain Layer

### Entities

Domain entities are pure Swift types with no external dependencies. They represent the core business objects.

```swift
// Domain/Entities/User.swift

import Foundation

struct User: Identifiable, Equatable, Sendable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole
    let accountStatus: AccountStatus
    let households: [String]
    let canManageHouseholds: [String]
    let familyUnitId: String?
    let isClaimed: Bool
    let claimCode: String?
    let householdLinkCode: String?
    let createdAt: Date
    let updatedAt: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var isAdmin: Bool {
        role == .scoutmaster || role == .assistantScoutmaster
    }
    
    var canSignUpForShifts: Bool {
        accountStatus == .active && isClaimed
    }
}
```

```swift
// Domain/Entities/Shift.swift

import Foundation

struct Shift: Identifiable, Equatable, Sendable {
    let id: String
    let date: Date
    let startTime: Date
    let endTime: Date
    let requiredScouts: Int
    let requiredParents: Int
    let currentScouts: Int
    let currentParents: Int
    let location: String
    let label: String?
    let notes: String?
    let status: ShiftStatus
    let seasonId: String?
    let templateId: String?
    let createdAt: Date
    
    var staffingStatus: StaffingStatus {
        if currentScouts >= requiredScouts && currentParents >= requiredParents {
            return .full
        } else if currentScouts > 0 || currentParents > 0 {
            return .partial
        }
        return .empty
    }
    
    var needsScouts: Bool {
        currentScouts < requiredScouts
    }
    
    var needsParents: Bool {
        currentParents < requiredParents
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}
```

```swift
// Domain/Entities/Assignment.swift

import Foundation

struct Assignment: Identifiable, Equatable, Sendable {
    let id: String
    let shiftId: String
    let userId: String
    let assignmentType: AssignmentType
    let status: AssignmentStatus
    let notes: String?
    let assignedAt: Date
    let assignedBy: String?
    
    var isActive: Bool {
        status == .confirmed || status == .pending
    }
}
```

```swift
// Domain/Entities/AttendanceRecord.swift

import Foundation

struct AttendanceRecord: Identifiable, Equatable, Sendable {
    let id: String
    let assignmentId: String
    let shiftId: String
    let userId: String
    let checkInTime: Date?
    let checkOutTime: Date?
    let checkInMethod: CheckInMethod
    let checkInLocation: GeoLocation?
    let hoursWorked: Double?
    let status: AttendanceStatus
    let notes: String?
    
    var isCheckedIn: Bool {
        checkInTime != nil && checkOutTime == nil
    }
    
    var isComplete: Bool {
        checkInTime != nil && checkOutTime != nil
    }
}

struct GeoLocation: Equatable, Sendable {
    let latitude: Double
    let longitude: Double
}

enum CheckInMethod: String, Sendable {
    case qrCode = "qr_code"
    case manual = "manual"
    case adminOverride = "admin_override"
}
```

### Value Objects

Value objects are immutable types that represent domain concepts.

```swift
// Domain/ValueObjects/UserRole.swift

enum UserRole: String, Sendable, CaseIterable {
    case scout
    case parent
    case scoutmaster
    case assistantScoutmaster
    
    var displayName: String {
        switch self {
        case .scout: return "Scout"
        case .parent: return "Parent"
        case .scoutmaster: return "Scoutmaster"
        case .assistantScoutmaster: return "Assistant Scoutmaster"
        }
    }
    
    var isLeadership: Bool {
        self == .scoutmaster || self == .assistantScoutmaster
    }
}
```

```swift
// Domain/ValueObjects/ShiftStatus.swift

enum ShiftStatus: String, Sendable {
    case draft
    case published
    case cancelled
    case completed
    
    var canAcceptSignups: Bool {
        self == .published
    }
}
```

```swift
// Domain/ValueObjects/AttendanceStatus.swift

enum AttendanceStatus: String, Sendable {
    case pending
    case checkedIn
    case checkedOut
    case noShow
    case excused
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .checkedIn: return "Checked In"
        case .checkedOut: return "Completed"
        case .noShow: return "No Show"
        case .excused: return "Excused"
        }
    }
}
```

```swift
// Domain/ValueObjects/StaffingStatus.swift

enum StaffingStatus: Sendable {
    case empty
    case partial
    case full
    
    var color: String {
        switch self {
        case .empty: return "red"
        case .partial: return "yellow"
        case .full: return "green"
        }
    }
}
```

---

## Data Layer

### Repository Protocols (Defined in Domain)

Repository protocols define the contract for data persistence. They live in the Domain layer.

```swift
// Domain/Repositories/UserRepository.swift

import Foundation

protocol UserRepository: Sendable {
    func getUser(id: String) async throws -> User
    func getUserByEmail(email: String) async throws -> User?
    func getUserByClaimCode(code: String) async throws -> User?
    func observeUser(id: String) -> AsyncThrowingStream<User, Error>
    func updateUser(_ user: User) async throws
}
```

```swift
// Domain/Repositories/ShiftRepository.swift

import Foundation

protocol ShiftRepository: Sendable {
    func getShift(id: String) async throws -> Shift
    func getShiftsForDateRange(start: Date, end: Date) async throws -> [Shift]
    func getShiftsForSeason(seasonId: String) async throws -> [Shift]
    func observeShift(id: String) -> AsyncThrowingStream<Shift, Error>
    func observeShiftsForDateRange(start: Date, end: Date) -> AsyncThrowingStream<[Shift], Error>
}
```

```swift
// Domain/Repositories/AssignmentRepository.swift

import Foundation

protocol AssignmentRepository: Sendable {
    func getAssignment(id: String) async throws -> Assignment
    func getAssignmentsForShift(shiftId: String) async throws -> [Assignment]
    func getAssignmentsForUser(userId: String) async throws -> [Assignment]
    func getAssignmentsForUserInDateRange(userId: String, start: Date, end: Date) async throws -> [Assignment]
    func observeAssignmentsForShift(shiftId: String) -> AsyncThrowingStream<[Assignment], Error>
    func observeAssignmentsForUser(userId: String) -> AsyncThrowingStream<[Assignment], Error>
}
```

```swift
// Domain/Repositories/AuthRepository.swift

import Foundation

protocol AuthRepository: Sendable {
    var currentUserId: String? { get }
    func signInWithApple(identityToken: Data, nonce: String) async throws -> String
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> String
    func signOut() async throws
    func observeAuthState() -> AsyncStream<String?>
}
```

### Service Protocols (Defined in Domain)

Service protocols define the contract for remote operations (Cloud Functions). They live in the Domain layer.

```swift
// Domain/Services/OnboardingService.swift

import Foundation

protocol OnboardingService: Sendable {
    func processInviteCode(code: String, userId: String) async throws -> InviteCodeResult
    func claimProfile(claimCode: String, userId: String) async throws -> ClaimProfileResult
}

struct InviteCodeResult: Sendable {
    let success: Bool
    let householdId: String?
    let userRole: UserRole?
    let message: String
}

struct ClaimProfileResult: Sendable {
    let success: Bool
    let userId: String?
    let message: String
}
```

```swift
// Domain/Services/AttendanceService.swift

import Foundation

protocol AttendanceService: Sendable {
    func checkIn(request: CheckInServiceRequest) async throws -> CheckInServiceResponse
    func checkOut(assignmentId: String, notes: String?) async throws -> CheckOutServiceResponse
    func adminManualCheckIn(request: AdminCheckInRequest) async throws -> CheckInServiceResponse
    func adminManualCheckOut(request: AdminCheckOutRequest) async throws -> CheckOutServiceResponse
}

struct CheckInServiceRequest: Sendable {
    let assignmentId: String
    let shiftId: String
    let qrCodeData: String?
    let location: GeoLocation?
}

struct CheckInServiceResponse: Sendable {
    let success: Bool
    let attendanceRecordId: String
    let checkInTime: Date
}

struct CheckOutServiceResponse: Sendable {
    let success: Bool
    let checkOutTime: Date
    let hoursWorked: Double
}

struct AdminCheckInRequest: Sendable {
    let assignmentId: String
    let shiftId: String
    let adminUserId: String
    let overrideTime: Date?
    let notes: String?
}

struct AdminCheckOutRequest: Sendable {
    let assignmentId: String
    let adminUserId: String
    let overrideTime: Date?
    let notes: String?
}
```

```swift
// Domain/Services/ShiftSignupService.swift

import Foundation

protocol ShiftSignupService: Sendable {
    func signUp(request: ShiftSignupServiceRequest) async throws -> ShiftSignupServiceResponse
    func cancelAssignment(assignmentId: String, reason: String?) async throws
}

struct ShiftSignupServiceRequest: Sendable {
    let shiftId: String
    let userId: String
    let assignmentType: AssignmentType
    let notes: String?
}

struct ShiftSignupServiceResponse: Sendable {
    let success: Bool
    let assignmentId: String
    let message: String
}
```

### Repository Implementations (Data Layer)

Repository implementations use Firebase and implement the Domain protocols.

```swift
// Data/Repositories/FirestoreUserRepository.swift

import Foundation
import FirebaseFirestore

final class FirestoreUserRepository: UserRepository, @unchecked Sendable {
    private let firestore: Firestore
    private let mapper: UserMapper
    
    init(firestore: Firestore, mapper: UserMapper) {
        self.firestore = firestore
        self.mapper = mapper
    }
    
    func getUser(id: String) async throws -> User {
        let document = try await firestore
            .collection("users")
            .document(id)
            .getDocument()
        
        guard let dto = try? document.data(as: UserDTO.self) else {
            throw DataError.documentNotFound
        }
        
        return mapper.toDomain(dto)
    }
    
    func getUserByEmail(email: String) async throws -> User? {
        let snapshot = try await firestore
            .collection("users")
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments()
        
        guard let document = snapshot.documents.first,
              let dto = try? document.data(as: UserDTO.self) else {
            return nil
        }
        
        return mapper.toDomain(dto)
    }
    
    func getUserByClaimCode(code: String) async throws -> User? {
        let snapshot = try await firestore
            .collection("users")
            .whereField("claimCode", isEqualTo: code)
            .whereField("isClaimed", isEqualTo: false)
            .limit(to: 1)
            .getDocuments()
        
        guard let document = snapshot.documents.first,
              let dto = try? document.data(as: UserDTO.self) else {
            return nil
        }
        
        return mapper.toDomain(dto)
    }
    
    func observeUser(id: String) -> AsyncThrowingStream<User, Error> {
        AsyncThrowingStream { continuation in
            let listener = firestore
                .collection("users")
                .document(id)
                .addSnapshotListener { [mapper] snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let snapshot = snapshot,
                          let dto = try? snapshot.data(as: UserDTO.self) else {
                        continuation.finish(throwing: DataError.documentNotFound)
                        return
                    }
                    
                    continuation.yield(mapper.toDomain(dto))
                }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func updateUser(_ user: User) async throws {
        let dto = mapper.toDTO(user)
        try firestore
            .collection("users")
            .document(user.id)
            .setData(from: dto, merge: true)
    }
}
```

```swift
// Data/Repositories/FirestoreShiftRepository.swift

import Foundation
import FirebaseFirestore

final class FirestoreShiftRepository: ShiftRepository, @unchecked Sendable {
    private let firestore: Firestore
    private let mapper: ShiftMapper
    
    init(firestore: Firestore, mapper: ShiftMapper) {
        self.firestore = firestore
        self.mapper = mapper
    }
    
    func getShift(id: String) async throws -> Shift {
        let document = try await firestore
            .collection("shifts")
            .document(id)
            .getDocument()
        
        guard let dto = try? document.data(as: ShiftDTO.self) else {
            throw DataError.documentNotFound
        }
        
        return mapper.toDomain(dto)
    }
    
    func getShiftsForDateRange(start: Date, end: Date) async throws -> [Shift] {
        let snapshot = try await firestore
            .collection("shifts")
            .whereField("date", isGreaterThanOrEqualTo: start)
            .whereField("date", isLessThanOrEqualTo: end)
            .whereField("status", isNotEqualTo: ShiftStatus.cancelled.rawValue)
            .order(by: "date")
            .order(by: "startTime")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: ShiftDTO.self) else {
                return nil
            }
            return mapper.toDomain(dto)
        }
    }
    
    func getShiftsForSeason(seasonId: String) async throws -> [Shift] {
        let snapshot = try await firestore
            .collection("shifts")
            .whereField("seasonId", isEqualTo: seasonId)
            .order(by: "date")
            .order(by: "startTime")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: ShiftDTO.self) else {
                return nil
            }
            return mapper.toDomain(dto)
        }
    }
    
    func observeShift(id: String) -> AsyncThrowingStream<Shift, Error> {
        AsyncThrowingStream { continuation in
            let listener = firestore
                .collection("shifts")
                .document(id)
                .addSnapshotListener { [mapper] snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let snapshot = snapshot,
                          let dto = try? snapshot.data(as: ShiftDTO.self) else {
                        continuation.finish(throwing: DataError.documentNotFound)
                        return
                    }
                    
                    continuation.yield(mapper.toDomain(dto))
                }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func observeShiftsForDateRange(start: Date, end: Date) -> AsyncThrowingStream<[Shift], Error> {
        AsyncThrowingStream { continuation in
            let listener = firestore
                .collection("shifts")
                .whereField("date", isGreaterThanOrEqualTo: start)
                .whereField("date", isLessThanOrEqualTo: end)
                .whereField("status", isNotEqualTo: ShiftStatus.cancelled.rawValue)
                .order(by: "date")
                .order(by: "startTime")
                .addSnapshotListener { [mapper] snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        continuation.yield([])
                        return
                    }
                    
                    let shifts = snapshot.documents.compactMap { document -> Shift? in
                        guard let dto = try? document.data(as: ShiftDTO.self) else {
                            return nil
                        }
                        return mapper.toDomain(dto)
                    }
                    
                    continuation.yield(shifts)
                }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}
```

### Service Implementations (Data Layer)

Service implementations call Cloud Functions and implement Domain protocols.

```swift
// Data/Services/CloudFunctionsAttendanceService.swift

import Foundation
import FirebaseFunctions

final class CloudFunctionsAttendanceService: AttendanceService, @unchecked Sendable {
    private let functions: Functions
    private let mapper: AttendanceMapper
    
    init(functions: Functions, mapper: AttendanceMapper) {
        self.functions = functions
        self.mapper = mapper
    }
    
    func checkIn(request: CheckInServiceRequest) async throws -> CheckInServiceResponse {
        let data: [String: Any] = [
            "assignmentId": request.assignmentId,
            "shiftId": request.shiftId,
            "qrCodeData": request.qrCodeData as Any,
            "latitude": request.location?.latitude as Any,
            "longitude": request.location?.longitude as Any
        ]
        
        let result = try await functions
            .httpsCallable("checkIn")
            .call(data)
        
        guard let response = result.data as? [String: Any] else {
            throw DataError.invalidResponse
        }
        
        return mapper.toCheckInResponse(response)
    }
    
    func checkOut(assignmentId: String, notes: String?) async throws -> CheckOutServiceResponse {
        let data: [String: Any] = [
            "assignmentId": assignmentId,
            "notes": notes as Any
        ]
        
        let result = try await functions
            .httpsCallable("checkOut")
            .call(data)
        
        guard let response = result.data as? [String: Any] else {
            throw DataError.invalidResponse
        }
        
        return mapper.toCheckOutResponse(response)
    }
    
    func adminManualCheckIn(request: AdminCheckInRequest) async throws -> CheckInServiceResponse {
        let data: [String: Any] = [
            "assignmentId": request.assignmentId,
            "shiftId": request.shiftId,
            "adminUserId": request.adminUserId,
            "overrideTime": request.overrideTime?.timeIntervalSince1970 as Any,
            "notes": request.notes as Any
        ]
        
        let result = try await functions
            .httpsCallable("adminManualCheckIn")
            .call(data)
        
        guard let response = result.data as? [String: Any] else {
            throw DataError.invalidResponse
        }
        
        return mapper.toCheckInResponse(response)
    }
    
    func adminManualCheckOut(request: AdminCheckOutRequest) async throws -> CheckOutServiceResponse {
        let data: [String: Any] = [
            "assignmentId": request.assignmentId,
            "adminUserId": request.adminUserId,
            "overrideTime": request.overrideTime?.timeIntervalSince1970 as Any,
            "notes": request.notes as Any
        ]
        
        let result = try await functions
            .httpsCallable("adminManualCheckOut")
            .call(data)
        
        guard let response = result.data as? [String: Any] else {
            throw DataError.invalidResponse
        }
        
        return mapper.toCheckOutResponse(response)
    }
}
```

### DTOs (Data Transfer Objects)

DTOs represent the structure of data as it exists in Firebase.

```swift
// Data/DTOs/UserDTO.swift

import Foundation
import FirebaseFirestore

struct UserDTO: Codable {
    @DocumentID var id: String?
    let email: String
    let firstName: String
    let lastName: String
    let role: String
    let accountStatus: String
    let households: [String]
    let canManageHouseholds: [String]
    let familyUnitId: String?
    let isClaimed: Bool
    let claimCode: String?
    let householdLinkCode: String?
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
}
```

```swift
// Data/DTOs/ShiftDTO.swift

import Foundation
import FirebaseFirestore

struct ShiftDTO: Codable {
    @DocumentID var id: String?
    let date: Date
    let startTime: Date
    let endTime: Date
    let requiredScouts: Int
    let requiredParents: Int
    let currentScouts: Int
    let currentParents: Int
    let location: String
    let label: String?
    let notes: String?
    let status: String
    let seasonId: String?
    let templateId: String?
    @ServerTimestamp var createdAt: Date?
}
```

### Mappers

Mappers convert between DTOs and Domain entities.

```swift
// Data/Mappers/UserMapper.swift

import Foundation

struct UserMapper {
    func toDomain(_ dto: UserDTO) -> User {
        User(
            id: dto.id ?? "",
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            role: UserRole(rawValue: dto.role) ?? .scout,
            accountStatus: AccountStatus(rawValue: dto.accountStatus) ?? .pending,
            households: dto.households,
            canManageHouseholds: dto.canManageHouseholds,
            familyUnitId: dto.familyUnitId,
            isClaimed: dto.isClaimed,
            claimCode: dto.claimCode,
            householdLinkCode: dto.householdLinkCode,
            createdAt: dto.createdAt ?? Date(),
            updatedAt: dto.updatedAt ?? Date()
        )
    }
    
    func toDTO(_ entity: User) -> UserDTO {
        UserDTO(
            id: entity.id,
            email: entity.email,
            firstName: entity.firstName,
            lastName: entity.lastName,
            role: entity.role.rawValue,
            accountStatus: entity.accountStatus.rawValue,
            households: entity.households,
            canManageHouseholds: entity.canManageHouseholds,
            familyUnitId: entity.familyUnitId,
            isClaimed: entity.isClaimed,
            claimCode: entity.claimCode,
            householdLinkCode: entity.householdLinkCode,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }
}
```

```swift
// Data/Mappers/ShiftMapper.swift

import Foundation

struct ShiftMapper {
    func toDomain(_ dto: ShiftDTO) -> Shift {
        Shift(
            id: dto.id ?? "",
            date: dto.date,
            startTime: dto.startTime,
            endTime: dto.endTime,
            requiredScouts: dto.requiredScouts,
            requiredParents: dto.requiredParents,
            currentScouts: dto.currentScouts,
            currentParents: dto.currentParents,
            location: dto.location,
            label: dto.label,
            notes: dto.notes,
            status: ShiftStatus(rawValue: dto.status) ?? .draft,
            seasonId: dto.seasonId,
            templateId: dto.templateId,
            createdAt: dto.createdAt ?? Date()
        )
    }
}
```

---

## Presentation Layer

### ViewModels

ViewModels use Use Cases and work with boundary objects from the Domain layer.

```swift
// Presentation/Schedule/ViewModels/WeekScheduleViewModel.swift

import Foundation
import SwiftUI

@MainActor
final class WeekScheduleViewModel: ObservableObject {
    
    // MARK: - Published State
    
    @Published private(set) var days: [DaySchedule] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published var selectedDate: Date = Date()
    
    // MARK: - Dependencies
    
    private let getWeekScheduleUseCase: GetWeekScheduleUseCaseProtocol
    
    // MARK: - Init
    
    init(getWeekScheduleUseCase: GetWeekScheduleUseCaseProtocol) {
        self.getWeekScheduleUseCase = getWeekScheduleUseCase
    }
    
    // MARK: - Public Methods
    
    func loadWeekSchedule() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await getWeekScheduleUseCase.execute(
                request: WeekScheduleRequest(referenceDate: selectedDate)
            )
            days = response.days
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func navigateToPreviousWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        Task { await loadWeekSchedule() }
    }
    
    func navigateToNextWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
        Task { await loadWeekSchedule() }
    }
}
```

```swift
// Presentation/Schedule/ViewModels/ShiftDetailViewModel.swift

import Foundation
import SwiftUI

@MainActor
final class ShiftDetailViewModel: ObservableObject {
    
    // MARK: - Published State
    
    @Published private(set) var shift: ShiftDetailResponse?
    @Published private(set) var assignments: [AssignmentInfo] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isSigningUp = false
    @Published private(set) var error: String?
    @Published var showSignUpSuccess = false
    
    // MARK: - Dependencies
    
    private let shiftId: String
    private let observeShiftUseCase: ObserveShiftUseCaseProtocol
    private let observeAssignmentsUseCase: ObserveShiftAssignmentsUseCaseProtocol
    private let signUpUseCase: SignUpForShiftUseCaseProtocol
    private let cancelAssignmentUseCase: CancelAssignmentUseCaseProtocol
    
    private var shiftObservationTask: Task<Void, Never>?
    private var assignmentsObservationTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(
        shiftId: String,
        observeShiftUseCase: ObserveShiftUseCaseProtocol,
        observeAssignmentsUseCase: ObserveShiftAssignmentsUseCaseProtocol,
        signUpUseCase: SignUpForShiftUseCaseProtocol,
        cancelAssignmentUseCase: CancelAssignmentUseCaseProtocol
    ) {
        self.shiftId = shiftId
        self.observeShiftUseCase = observeShiftUseCase
        self.observeAssignmentsUseCase = observeAssignmentsUseCase
        self.signUpUseCase = signUpUseCase
        self.cancelAssignmentUseCase = cancelAssignmentUseCase
    }
    
    deinit {
        shiftObservationTask?.cancel()
        assignmentsObservationTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    func startObserving() {
        observeShift()
        observeAssignments()
    }
    
    func signUp(userId: String, notes: String?) async {
        isSigningUp = true
        error = nil
        
        do {
            let request = SignUpRequest(shiftId: shiftId, userId: userId, notes: notes)
            _ = try await signUpUseCase.execute(request: request)
            showSignUpSuccess = true
        } catch let domainError as DomainError {
            error = domainError.userMessage
        } catch {
            self.error = error.localizedDescription
        }
        
        isSigningUp = false
    }
    
    func cancelAssignment(assignmentId: String, reason: String?) async {
        do {
            let request = CancelAssignmentRequest(assignmentId: assignmentId, reason: reason)
            try await cancelAssignmentUseCase.execute(request: request)
        } catch let domainError as DomainError {
            error = domainError.userMessage
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Private Methods
    
    private func observeShift() {
        shiftObservationTask?.cancel()
        shiftObservationTask = Task {
            do {
                for try await shiftDetail in observeShiftUseCase.execute(shiftId: shiftId) {
                    self.shift = shiftDetail
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    private func observeAssignments() {
        assignmentsObservationTask?.cancel()
        assignmentsObservationTask = Task {
            do {
                for try await assignmentList in observeAssignmentsUseCase.execute(shiftId: shiftId) {
                    self.assignments = assignmentList
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
```

### Views

Views use ViewModels and display data from boundary objects.

```swift
// Presentation/Schedule/Views/WeekScheduleView.swift

import SwiftUI

struct WeekScheduleView: View {
    @StateObject private var viewModel: WeekScheduleViewModel
    
    init(viewModel: WeekScheduleViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading schedule...")
                } else if let error = viewModel.error {
                    ErrorView(message: error) {
                        Task { await viewModel.loadWeekSchedule() }
                    }
                } else {
                    weekScheduleContent
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.navigateToPreviousWeek) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.navigateToNextWeek) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .task {
            await viewModel.loadWeekSchedule()
        }
    }
    
    @ViewBuilder
    private var weekScheduleContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.days) { day in
                    DaySection(day: day)
                }
            }
            .padding()
        }
    }
}

struct DaySection: View {
    let day: DaySchedule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.date, style: .date)
                .font(.headline)
            
            if day.shifts.isEmpty {
                Text("No shifts scheduled")
                    .foregroundColor(.secondary)
            } else {
                ForEach(day.shifts) { shift in
                    NavigationLink(value: shift.id) {
                        ShiftCardView(shift: shift)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
```

```swift
// Presentation/Schedule/Views/ShiftCardView.swift

import SwiftUI

struct ShiftCardView: View {
    let shift: ShiftSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(shift.timeRange)
                    .font(.subheadline.bold())
                
                Spacer()
                
                StaffingIndicator(status: shift.staffingStatus)
            }
            
            if let label = shift.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(shift.currentScouts)/\(shift.requiredScouts)", systemImage: "person.fill")
                    .font(.caption)
                
                Label("\(shift.currentParents)/\(shift.requiredParents)", systemImage: "person.2.fill")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
```

---

## Dependency Injection

### DependencyContainer

The DependencyContainer creates all dependencies and wires them together.

```swift
// App/DependencyContainer.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

@MainActor
final class DependencyContainer {
    
    // MARK: - Singleton
    
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Data Sources
    
    private lazy var firestore: Firestore = {
        Firestore.firestore()
    }()
    
    private lazy var auth: Auth = {
        Auth.auth()
    }()
    
    private lazy var functions: Functions = {
        Functions.functions()
    }()
    
    // MARK: - Mappers
    
    private lazy var userMapper = UserMapper()
    private lazy var shiftMapper = ShiftMapper()
    private lazy var assignmentMapper = AssignmentMapper()
    private lazy var attendanceMapper = AttendanceMapper()
    
    // MARK: - Repositories
    
    lazy var authRepository: AuthRepository = {
        FirebaseAuthRepository(auth: auth)
    }()
    
    lazy var userRepository: UserRepository = {
        FirestoreUserRepository(
            firestore: firestore,
            mapper: userMapper
        )
    }()
    
    lazy var shiftRepository: ShiftRepository = {
        FirestoreShiftRepository(
            firestore: firestore,
            mapper: shiftMapper
        )
    }()
    
    lazy var assignmentRepository: AssignmentRepository = {
        FirestoreAssignmentRepository(
            firestore: firestore,
            mapper: assignmentMapper
        )
    }()
    
    // MARK: - Services
    
    lazy var onboardingService: OnboardingService = {
        CloudFunctionsOnboardingService(functions: functions)
    }()
    
    lazy var attendanceService: AttendanceService = {
        CloudFunctionsAttendanceService(
            functions: functions,
            mapper: attendanceMapper
        )
    }()
    
    lazy var shiftSignupService: ShiftSignupService = {
        CloudFunctionsShiftSignupService(functions: functions)
    }()
    
    // MARK: - Standard Use Cases
    
    func makeSignInWithAppleUseCase() -> SignInWithAppleUseCaseProtocol {
        SignInWithAppleUseCase(
            authRepository: authRepository,
            userRepository: userRepository
        )
    }
    
    func makeSignUpForShiftUseCase() -> SignUpForShiftUseCaseProtocol {
        SignUpForShiftUseCase(
            shiftRepository: shiftRepository,
            assignmentRepository: assignmentRepository,
            userRepository: userRepository,
            shiftSignupService: shiftSignupService
        )
    }
    
    func makeCheckInUseCase() -> CheckInUseCaseProtocol {
        CheckInUseCase(attendanceService: attendanceService)
    }
    
    func makeCheckOutUseCase() -> CheckOutUseCaseProtocol {
        CheckOutUseCase(attendanceService: attendanceService)
    }
    
    // MARK: - Observable Use Cases
    
    func makeObserveAuthStateUseCase() -> ObserveAuthStateUseCaseProtocol {
        ObserveAuthStateUseCase(authRepository: authRepository)
    }
    
    func makeObserveCurrentUserUseCase() -> ObserveCurrentUserUseCaseProtocol {
        ObserveCurrentUserUseCase(
            authRepository: authRepository,
            userRepository: userRepository
        )
    }
    
    func makeObserveShiftUseCase() -> ObserveShiftUseCaseProtocol {
        ObserveShiftUseCase(shiftRepository: shiftRepository)
    }
    
    func makeObserveShiftAssignmentsUseCase() -> ObserveShiftAssignmentsUseCaseProtocol {
        ObserveShiftAssignmentsUseCase(assignmentRepository: assignmentRepository)
    }
}
```

---

## Testing Strategy

### Unit Testing Use Cases

```swift
// Tests/UseCases/SignUpForShiftUseCaseTests.swift

import XCTest
@testable import Troop900

final class SignUpForShiftUseCaseTests: XCTestCase {
    
    var sut: SignUpForShiftUseCase!
    var mockShiftRepository: MockShiftRepository!
    var mockAssignmentRepository: MockAssignmentRepository!
    var mockUserRepository: MockUserRepository!
    var mockShiftSignupService: MockShiftSignupService!
    
    override func setUp() {
        super.setUp()
        mockShiftRepository = MockShiftRepository()
        mockAssignmentRepository = MockAssignmentRepository()
        mockUserRepository = MockUserRepository()
        mockShiftSignupService = MockShiftSignupService()
        
        sut = SignUpForShiftUseCase(
            shiftRepository: mockShiftRepository,
            assignmentRepository: mockAssignmentRepository,
            userRepository: mockUserRepository,
            shiftSignupService: mockShiftSignupService
        )
    }
    
    func test_execute_withValidRequest_returnsSuccess() async throws {
        // Given
        let shift = makeShift(status: .published, currentScouts: 1, requiredScouts: 3)
        let user = makeUser(accountStatus: .active)
        
        mockShiftRepository.getShiftResult = .success(shift)
        mockUserRepository.getUserResult = .success(user)
        mockAssignmentRepository.getAssignmentsResult = .success([])
        mockShiftSignupService.signUpResult = .success("assignment-123")
        
        let request = SignUpRequest(shiftId: "shift-1", userId: "user-1", notes: nil)
        
        // When
        let result = try await sut.execute(request: request)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.assignmentId, "assignment-123")
    }
    
    func test_execute_withFullShift_throwsShiftFullError() async {
        // Given
        let shift = makeShift(status: .published, currentScouts: 3, requiredScouts: 3)
        mockShiftRepository.getShiftResult = .success(shift)
        
        let request = SignUpRequest(shiftId: "shift-1", userId: "user-1", notes: nil)
        
        // When/Then
        do {
            _ = try await sut.execute(request: request)
            XCTFail("Expected error to be thrown")
        } catch let error as DomainError {
            XCTAssertEqual(error, .shiftFull)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func makeShift(
        status: ShiftStatus,
        currentScouts: Int,
        requiredScouts: Int
    ) -> Shift {
        Shift(
            id: "shift-1",
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: requiredScouts,
            requiredParents: 2,
            currentScouts: currentScouts,
            currentParents: 1,
            location: "Tree Lot",
            label: "Morning Shift",
            notes: nil,
            status: status,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
    }
    
    private func makeUser(accountStatus: AccountStatus) -> User {
        User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            role: .scout,
            accountStatus: accountStatus,
            households: ["household-1"],
            canManageHouseholds: [],
            familyUnitId: "family-1",
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
```

---

## Summary

This revised Clean Architecture implementation ensures:

1. **Firebase is hidden** - All Firebase code is in the Data layer
2. **Domain is pure** - No external dependencies in entities, use cases, or boundary objects
3. **Repositories for persistence** - Firestore reads/writes through repository protocols
4. **Services for operations** - Cloud Functions through service protocols
5. **Boundary objects in Domain** - Use case input/output types live where they belong
6. **Observable use cases** - Real-time data streams via `AsyncStream` with proper boundary objects
7. **Testability** - Repository and service protocols enable easy mocking
8. **Clear boundaries** - DTOs at Firebase boundaries, boundary objects at use case boundaries
9. **Single responsibility** - Each use case does one thing
10. **Correct dependency direction** - Presentation depends on Domain, Domain has no external dependencies
11. **Compile-time enforcement** - Swift Package Manager local packages prevent architectural violations

The separation of Repositories and Services provides clear semantics:
- **Repository**: "I need to read/write this data"
- **Service**: "I need to perform this operation"

The distinction between standard and observable use cases provides clear patterns:
- **Standard Use Case**: "I need to perform an action once"
- **Observable Use Case**: "I need to watch data and react to changes"

The boundary objects in the Domain layer ensure the use cases define their own contract without depending on the presentation layer.

The use of Swift Package Manager local packages transforms the Clean Architecture from a conceptual guideline into a compiler-enforced reality, making it impossible to accidentally violate the dependency rule.
