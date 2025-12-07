import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetCurrentUserUseCase Tests")
struct GetCurrentUserUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAuthRepository = MockAuthRepository()
    private let mockUserRepository = MockUserRepository()
    private let mockHouseholdRepository = MockHouseholdRepository()
    
    private var useCase: GetCurrentUserUseCase {
        GetCurrentUserUseCase(
            authRepository: mockAuthRepository,
            userRepository: mockUserRepository,
            householdRepository: mockHouseholdRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Get current user succeeds with no households")
    func getCurrentUserSucceedsWithNoHouseholds() async throws {
        // Given
        let userId = "user-123"
        let user = TestFixtures.createUser(id: userId, households: [])
        
        mockAuthRepository.setCurrentUserId(userId)
        mockUserRepository.usersById[userId] = user
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.user.id == userId)
        #expect(response.households.isEmpty)
    }
    
    @Test("Get current user succeeds with single household")
    func getCurrentUserSucceedsWithSingleHousehold() async throws {
        // Given
        let userId = "user-123"
        let householdId = "household-1"
        let user = TestFixtures.createUser(id: userId, households: [householdId])
        let household = TestFixtures.createHousehold(id: householdId, name: "Smith Family")
        
        mockAuthRepository.setCurrentUserId(userId)
        mockUserRepository.usersById[userId] = user
        mockHouseholdRepository.householdsById[householdId] = household
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.user.id == userId)
        #expect(response.households.count == 1)
        #expect(response.households[0].id == householdId)
        #expect(response.households[0].name == "Smith Family")
    }
    
    @Test("Get current user succeeds with multiple households")
    func getCurrentUserSucceedsWithMultipleHouseholds() async throws {
        // Given
        let userId = "user-123"
        let householdIds = ["household-1", "household-2", "household-3"]
        let user = TestFixtures.createUser(id: userId, households: householdIds)
        
        for (index, householdId) in householdIds.enumerated() {
            let household = TestFixtures.createHousehold(id: householdId, name: "Family \(index + 1)")
            mockHouseholdRepository.householdsById[householdId] = household
        }
        
        mockAuthRepository.setCurrentUserId(userId)
        mockUserRepository.usersById[userId] = user
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.user.id == userId)
        #expect(response.households.count == 3)
    }
    
    @Test("Get current user handles missing households gracefully")
    func getCurrentUserHandlesMissingHouseholds() async throws {
        // Given
        let userId = "user-123"
        let householdIds = ["household-1", "household-missing", "household-3"]
        let user = TestFixtures.createUser(id: userId, households: householdIds)
        
        // Only add household-1 and household-3, household-missing doesn't exist
        mockHouseholdRepository.householdsById["household-1"] = TestFixtures.createHousehold(id: "household-1")
        mockHouseholdRepository.householdsById["household-3"] = TestFixtures.createHousehold(id: "household-3")
        
        mockAuthRepository.setCurrentUserId(userId)
        mockUserRepository.usersById[userId] = user
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.user.id == userId)
        #expect(response.households.count == 2) // Missing household is skipped (use case uses try?)
        #expect(mockHouseholdRepository.getHouseholdCallCount == 3) // All 3 were attempted
        #expect(mockHouseholdRepository.getHouseholdCalledWith.contains("household-1"))
        #expect(mockHouseholdRepository.getHouseholdCalledWith.contains("household-missing"))
        #expect(mockHouseholdRepository.getHouseholdCalledWith.contains("household-3"))
    }
    
    // MARK: - Error Tests
    
    @Test("Get current user fails when not authenticated")
    func getCurrentUserFailsWhenNotAuthenticated() async throws {
        // Given
        mockAuthRepository.setCurrentUserId(nil)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute()
        }
    }
    
    @Test("Get current user fails when user not found")
    func getCurrentUserFailsWhenUserNotFound() async throws {
        // Given
        let userId = "user-123"
        mockAuthRepository.setCurrentUserId(userId)
        // User not in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute()
        }
    }
    
    @Test("Get current user propagates user repository error")
    func getCurrentUserPropagatesUserRepositoryError() async throws {
        // Given
        let userId = "user-123"
        mockAuthRepository.setCurrentUserId(userId)
        mockUserRepository.getUserResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute()
        }
    }
}
