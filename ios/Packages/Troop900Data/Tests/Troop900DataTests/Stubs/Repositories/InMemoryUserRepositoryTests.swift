import Foundation
import Testing
@testable import Troop900Data
import Troop900Domain

@Suite("InMemoryUserRepository Tests")
struct InMemoryUserRepositoryTests {
    
    func makeTestUser(id: String = "user-1", email: String = "test@example.com") -> User {
        User(
            id: UserId(unchecked: id),
            email: email,
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: .active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    @Test("Create user")
    func createUser() async throws {
        let repository = InMemoryUserRepository()
        let user = makeTestUser()
        
        let userId = try await repository.createUser(user)
        
        #expect(userId == user.id)
        let retrieved = try await repository.getUser(id: user.id)
        #expect(retrieved == user)
    }
    
    @Test("Get user by ID")
    func getUserById() async throws {
        let user = makeTestUser()
        let repository = InMemoryUserRepository(initialUsers: [user])
        
        let retrieved = try await repository.getUser(id: user.id)
        
        #expect(retrieved == user)
    }
    
    @Test("Get user by ID throws when not found")
    func getUserByIdNotFound() async throws {
        let repository = InMemoryUserRepository()
        let userId = UserId(unchecked: "nonexistent")
        
        do {
            _ = try await repository.getUser(id: userId)
            Issue.record("Expected DomainError.userNotFound")
        } catch DomainError.userNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Get user by email")
    func getUserByEmail() async throws {
        let user = makeTestUser(email: "test@example.com")
        let repository = InMemoryUserRepository(initialUsers: [user])
        
        let retrieved = try await repository.getUserByEmail(email: "test@example.com")
        
        #expect(retrieved == user)
    }
    
    @Test("Get user by email returns nil when not found")
    func getUserByEmailNotFound() async throws {
        let repository = InMemoryUserRepository()
        
        let retrieved = try await repository.getUserByEmail(email: "nonexistent@example.com")
        
        #expect(retrieved == nil)
    }
    
    @Test("Get user by email is case insensitive")
    func getUserByEmailCaseInsensitive() async throws {
        let user = makeTestUser(email: "Test@Example.com")
        let repository = InMemoryUserRepository(initialUsers: [user])
        
        let retrieved = try await repository.getUserByEmail(email: "test@example.com")
        
        #expect(retrieved == user)
    }
    
    @Test("Get user by claim code")
    func getUserByClaimCode() async throws {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: .pending,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: false,
            claimCode: "CLAIM123",
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        let repository = InMemoryUserRepository(initialUsers: [user])
        
        let retrieved = try await repository.getUserByClaimCode(code: "CLAIM123")
        
        #expect(retrieved == user)
    }
    
    @Test("Get users by household")
    func getUsersByHousehold() async throws {
        let user1 = User(
            id: UserId(unchecked: "user-1"),
            email: "user1@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: .active,
            households: ["household-1"],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        let user2 = User(
            id: UserId(unchecked: "user-2"),
            email: "user2@example.com",
            firstName: "Jane",
            lastName: "Doe",
            role: .parent,
            accountStatus: .active,
            households: ["household-1"],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        let user3 = User(
            id: UserId(unchecked: "user-3"),
            email: "user3@example.com",
            firstName: "Bob",
            lastName: "Smith",
            role: .scout,
            accountStatus: .active,
            households: ["household-2"],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        let repository = InMemoryUserRepository(initialUsers: [user1, user2, user3])
        
        let users = try await repository.getUsersByHousehold(householdId: "household-1")
        
        #expect(users.count == 2)
        #expect(users.contains(user1))
        #expect(users.contains(user2))
        #expect(!users.contains(user3))
    }
    
    @Test("Update user")
    func updateUser() async throws {
        let user = makeTestUser()
        let repository = InMemoryUserRepository(initialUsers: [user])
        
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: "Jane",
            lastName: "Smith",
            role: user.role,
            accountStatus: user.accountStatus,
            households: user.households,
            canManageHouseholds: user.canManageHouseholds,
            familyUnitId: user.familyUnitId,
            isClaimed: user.isClaimed,
            claimCode: user.claimCode,
            householdLinkCode: user.householdLinkCode,
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        try await repository.updateUser(updatedUser)
        
        let retrieved = try await repository.getUser(id: user.id)
        #expect(retrieved.firstName == "Jane")
        #expect(retrieved.lastName == "Smith")
    }
    
    @Test("Update user throws when not found")
    func updateUserNotFound() async throws {
        let repository = InMemoryUserRepository()
        let user = makeTestUser()
        
        do {
            try await repository.updateUser(user)
            Issue.record("Expected DomainError.userNotFound")
        } catch DomainError.userNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Create user throws when already exists")
    func createUserAlreadyExists() async throws {
        let user = makeTestUser()
        let repository = InMemoryUserRepository(initialUsers: [user])
        
        do {
            _ = try await repository.createUser(user)
            Issue.record("Expected DomainError.userAlreadyExists")
        } catch DomainError.userAlreadyExists {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Clear removes all users")
    func clear() async throws {
        let user1 = makeTestUser(id: "user-1")
        let user2 = makeTestUser(id: "user-2", email: "user2@example.com")
        let repository = InMemoryUserRepository(initialUsers: [user1, user2])
        
        repository.clear()
        
        do {
            _ = try await repository.getUser(id: user1.id)
            Issue.record("Expected DomainError.userNotFound")
        } catch DomainError.userNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
