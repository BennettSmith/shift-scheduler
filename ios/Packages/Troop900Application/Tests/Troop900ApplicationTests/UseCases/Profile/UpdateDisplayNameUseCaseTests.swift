import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("UpdateDisplayNameUseCase Tests")
struct UpdateDisplayNameUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: UpdateDisplayNameUseCase {
        UpdateDisplayNameUseCase(userRepository: mockUserRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Update display name succeeds with valid input")
    func updateDisplayNameSucceeds() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId, firstName: "John", lastName: "Doe")
        mockUserRepository.usersById[userId] = user
        
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: "Jane",
            lastName: "Smith"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockUserRepository.updateUserCallCount == 1)
        let updatedUser = mockUserRepository.updateUserCalledWith[0]
        #expect(updatedUser.firstName == "Jane")
        #expect(updatedUser.lastName == "Smith")
    }
    
    @Test("Update display name trims whitespace")
    func updateDisplayNameTrimsWhitespace() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: "  Jane  ",
            lastName: "  Smith  "
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedUser = mockUserRepository.updateUserCalledWith[0]
        #expect(updatedUser.firstName == "Jane")
        #expect(updatedUser.lastName == "Smith")
    }
    
    @Test("Update display name preserves other user fields")
    func updateDisplayNamePreservesOtherFields() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(
            id: userId,
            householdId: "household-1"
        )
        mockUserRepository.usersById[userId] = user
        
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: "Jane",
            lastName: "Smith"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedUser = mockUserRepository.updateUserCalledWith[0]
        #expect(updatedUser.id.value == userId)
        #expect(updatedUser.email == user.email)
        #expect(updatedUser.role == user.role)
        #expect(updatedUser.households == user.households)
    }
    
    // MARK: - Validation Tests
    
    @Test("Update display name fails with empty first name")
    func updateDisplayNameFailsWithEmptyFirstName() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: "",
            lastName: "Smith"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockUserRepository.updateUserCallCount == 0)
    }
    
    @Test("Update display name fails with whitespace-only first name")
    func updateDisplayNameFailsWithWhitespaceFirstName() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: "   ",
            lastName: "Smith"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Update display name fails with empty last name")
    func updateDisplayNameFailsWithEmptyLastName() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: "Jane",
            lastName: ""
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Update display name fails with first name too long")
    func updateDisplayNameFailsWithFirstNameTooLong() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let longName = String(repeating: "a", count: 51)
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: longName,
            lastName: "Smith"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Update display name fails with last name too long")
    func updateDisplayNameFailsWithLastNameTooLong() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let longName = String(repeating: "a", count: 51)
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: "Jane",
            lastName: longName
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Update display name succeeds with max length names")
    func updateDisplayNameSucceedsWithMaxLength() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let maxLengthName = String(repeating: "a", count: 50)
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: maxLengthName,
            lastName: maxLengthName
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockUserRepository.updateUserCallCount == 1)
        let updatedUser = mockUserRepository.updateUserCalledWith[0]
        #expect(updatedUser.firstName.count == 50)
        #expect(updatedUser.lastName.count == 50)
    }
    
    // MARK: - Error Tests
    
    @Test("Update display name fails when user not found")
    func updateDisplayNameFailsWhenUserNotFound() async throws {
        // Given - no user in repository
        let request = UpdateDisplayNameRequest(
            userId: "non-existent",
            firstName: "Jane",
            lastName: "Smith"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Update display name propagates repository error")
    func updateDisplayNamePropagatesError() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        mockUserRepository.updateUserError = DomainError.networkError
        
        let request = UpdateDisplayNameRequest(
            userId: userId,
            firstName: "Jane",
            lastName: "Smith"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
