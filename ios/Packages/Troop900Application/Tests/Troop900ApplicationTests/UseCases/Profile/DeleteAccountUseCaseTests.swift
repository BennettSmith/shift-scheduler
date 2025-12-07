import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("DeleteAccountUseCase Tests")
struct DeleteAccountUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockUserRepository = MockUserRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockHouseholdRepository = MockHouseholdRepository()
    
    private var useCase: DeleteAccountUseCase {
        DeleteAccountUseCase(
            userRepository: mockUserRepository,
            assignmentRepository: mockAssignmentRepository,
            householdRepository: mockHouseholdRepository
        )
    }
    
    // MARK: - Eligibility Check Tests
    
    @Test("Check eligibility returns can delete for regular user")
    func checkEligibilityReturnsCanDeleteForRegularUser() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        
        // When
        let response = try await useCase.checkEligibility(userId: userId)
        
        // Then
        #expect(response.canDelete == true)
        #expect(response.blockers.isEmpty)
        #expect(response.futureAssignments == 0)
        #expect(response.hasActiveRoles == false)
    }
    
    @Test("Check eligibility blocks user with future assignments")
    func checkEligibilityBlocksUserWithFutureAssignments() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let assignment = TestFixtures.createAssignment(userId: userId, status: .confirmed)
        mockAssignmentRepository.getAssignmentsForUserResult = .success([assignment])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        
        // When
        let response = try await useCase.checkEligibility(userId: userId)
        
        // Then
        #expect(response.canDelete == false)
        #expect(response.futureAssignments == 1)
        #expect(response.blockers.contains { $0.contains("upcoming shift") })
    }
    
    @Test("Check eligibility blocks committee member")
    func checkEligibilityBlocksCommitteeMember() async throws {
        // Given
        let userId = "committee-1"
        let user = TestFixtures.createCommittee(id: userId)
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        
        // When
        let response = try await useCase.checkEligibility(userId: userId)
        
        // Then
        #expect(response.canDelete == false)
        #expect(response.hasActiveRoles == true)
        #expect(response.blockers.contains { $0.contains("leadership") })
    }
    
    @Test("Check eligibility blocks household manager")
    func checkEligibilityBlocksHouseholdManager() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        
        let household = TestFixtures.createHousehold(id: "household-1", managers: [userId])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([household])
        
        // When
        let response = try await useCase.checkEligibility(userId: userId)
        
        // Then
        #expect(response.canDelete == false)
        #expect(response.blockers.contains { $0.contains("household") })
    }
    
    @Test("Check eligibility includes data retention warning")
    func checkEligibilityIncludesDataRetentionWarning() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        
        // When
        let response = try await useCase.checkEligibility(userId: userId)
        
        // Then
        #expect(response.dataRetentionWarning.contains("deactivated"))
        #expect(response.dataRetentionWarning.contains("retained"))
    }
    
    // MARK: - Delete Execution Tests
    
    @Test("Delete account succeeds for eligible user")
    func deleteAccountSucceedsForEligibleUser() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        
        let request = DeleteAccountRequest(
            userId: userId,
            reason: "Testing deletion",
            confirmed: true
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockUserRepository.updateUserCallCount == 1)
        let updatedUser = mockUserRepository.updateUserCalledWith[0]
        #expect(updatedUser.accountStatus == .inactive)
    }
    
    @Test("Delete account clears management rights")
    func deleteAccountClearsManagementRights() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createUser(
            id: userId,
            role: .parent,
            canManageHouseholds: ["household-1", "household-2"]
        )
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        
        let request = DeleteAccountRequest(
            userId: userId,
            reason: nil,
            confirmed: true
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedUser = mockUserRepository.updateUserCalledWith[0]
        #expect(updatedUser.canManageHouseholds.isEmpty)
    }
    
    @Test("Delete account clears claim and link codes")
    func deleteAccountClearsCodes() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createUser(
            id: userId,
            role: .parent,
            claimCode: "CLAIM123",
            householdLinkCode: "LINK456"
        )
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        
        let request = DeleteAccountRequest(
            userId: userId,
            reason: nil,
            confirmed: true
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedUser = mockUserRepository.updateUserCalledWith[0]
        #expect(updatedUser.claimCode == nil)
        #expect(updatedUser.householdLinkCode == nil)
    }
    
    @Test("Delete account fails without confirmation")
    func deleteAccountFailsWithoutConfirmation() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let request = DeleteAccountRequest(
            userId: userId,
            reason: nil,
            confirmed: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockUserRepository.updateUserCallCount == 0)
    }
    
    @Test("Delete account fails for ineligible user")
    func deleteAccountFailsForIneligibleUser() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        // User has active assignment
        let assignment = TestFixtures.createAssignment(userId: userId, status: .confirmed)
        mockAssignmentRepository.getAssignmentsForUserResult = .success([assignment])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        
        let request = DeleteAccountRequest(
            userId: userId,
            reason: nil,
            confirmed: true
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockUserRepository.updateUserCallCount == 0)
    }
    
    // MARK: - Error Tests
    
    @Test("Check eligibility fails when user not found")
    func checkEligibilityFailsWhenUserNotFound() async throws {
        // Given - no user in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.checkEligibility(userId: "non-existent")
        }
    }
    
    @Test("Delete account fails when user not found")
    func deleteAccountFailsWhenUserNotFound() async throws {
        // Given
        let request = DeleteAccountRequest(
            userId: "non-existent",
            reason: nil,
            confirmed: true
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Delete account propagates repository error")
    func deleteAccountPropagatesError() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockHouseholdRepository.getHouseholdsManagedByUserResult = .success([])
        mockUserRepository.updateUserError = DomainError.networkError
        
        let request = DeleteAccountRequest(
            userId: userId,
            reason: nil,
            confirmed: true
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
