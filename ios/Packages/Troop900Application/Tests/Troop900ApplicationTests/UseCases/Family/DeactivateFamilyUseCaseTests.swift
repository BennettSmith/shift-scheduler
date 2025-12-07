import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("DeactivateFamilyUseCase Tests")
struct DeactivateFamilyUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockHouseholdRepository = MockHouseholdRepository()
    private let mockUserRepository = MockUserRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    
    private var useCase: DeactivateFamilyUseCase {
        DeactivateFamilyUseCase(
            householdRepository: mockHouseholdRepository,
            userRepository: mockUserRepository,
            assignmentRepository: mockAssignmentRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Deactivate family succeeds for household manager")
    func deactivateFamilySucceedsForManager() async throws {
        // Given
        let householdId = "household-1"
        let managerId = "manager-1"
        
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [managerId],
            managers: [managerId],
            isActive: true
        )
        let manager = TestFixtures.createUser(
            id: managerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[managerId] = manager
        
        let request = DeactivateFamilyRequest(
            householdId: householdId,
            reason: "Family leaving troop",
            cancelFutureAssignments: false,
            requestingUserId: managerId
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.affectedMembersCount == 1)
        #expect(response.message.contains("successfully"))
        #expect(response.deactivatedAt != nil)
        
        // Verify household was updated
        #expect(mockHouseholdRepository.updateHouseholdCallCount == 1)
        let updatedHousehold = mockHouseholdRepository.updateHouseholdCalledWith[0]
        #expect(updatedHousehold.isActive == false)
    }
    
    @Test("Deactivate family succeeds for committee member")
    func deactivateFamilySucceedsForCommittee() async throws {
        // Given
        let householdId = "household-1"
        let committeeId = "committee-1"
        let memberId = "member-1"
        
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [memberId],
            isActive: true
        )
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        let member = TestFixtures.createParent(id: memberId, householdId: householdId)
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[committeeId] = committeeUser
        mockUserRepository.usersById[memberId] = member
        
        let request = DeactivateFamilyRequest(
            householdId: householdId,
            reason: "Administrative action",
            cancelFutureAssignments: false,
            requestingUserId: committeeId
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
    }
    
    @Test("Deactivate family cancels future assignments when requested")
    func deactivateFamilyCancelsFutureAssignments() async throws {
        // Given
        let householdId = "household-1"
        let managerId = "manager-1"
        let memberId = "member-1"
        
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [managerId, memberId],
            managers: [managerId],
            isActive: true
        )
        let manager = TestFixtures.createUser(
            id: managerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        let member = TestFixtures.createParent(id: memberId, householdId: householdId)
        
        // Create confirmed assignments for both members
        let assignment1 = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: managerId,
            status: .confirmed
        )
        let assignment2 = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: "shift-2",
            userId: memberId,
            status: .confirmed
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[managerId] = manager
        mockUserRepository.usersById[memberId] = member
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment1
        mockAssignmentRepository.assignmentsById["assignment-2"] = assignment2
        
        let request = DeactivateFamilyRequest(
            householdId: householdId,
            reason: "Leaving",
            cancelFutureAssignments: true,
            requestingUserId: managerId
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.cancelledAssignmentsCount == 2)
        #expect(response.affectedMembersCount == 2)
        #expect(mockAssignmentRepository.deleteAssignmentCallCount == 2)
    }
    
    @Test("Deactivate family does not cancel assignments when not requested")
    func deactivateFamilyDoesNotCancelAssignmentsWhenNotRequested() async throws {
        // Given
        let householdId = "household-1"
        let managerId = "manager-1"
        
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [managerId],
            managers: [managerId],
            isActive: true
        )
        let manager = TestFixtures.createUser(
            id: managerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        let assignment = TestFixtures.createAssignment(
            id: "assignment-1",
            userId: managerId,
            status: .confirmed
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[managerId] = manager
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment
        
        let request = DeactivateFamilyRequest(
            householdId: householdId,
            reason: nil,
            cancelFutureAssignments: false, // Don't cancel
            requestingUserId: managerId
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.cancelledAssignmentsCount == 0)
        #expect(mockAssignmentRepository.deleteAssignmentCallCount == 0)
    }
    
    @Test("Deactivate family returns failure when already inactive")
    func deactivateFamilyReturnsFailureWhenAlreadyInactive() async throws {
        // Given
        let householdId = "household-1"
        let managerId = "manager-1"
        
        let inactiveHousehold = TestFixtures.createHousehold(
            id: householdId,
            members: [managerId],
            managers: [managerId],
            isActive: false // Already inactive
        )
        let manager = TestFixtures.createUser(
            id: managerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        
        mockHouseholdRepository.addHousehold(inactiveHousehold)
        mockUserRepository.usersById[managerId] = manager
        
        let request = DeactivateFamilyRequest(
            householdId: householdId,
            reason: nil,
            cancelFutureAssignments: false,
            requestingUserId: managerId
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.message.contains("already inactive"))
        #expect(response.deactivatedAt == nil)
        #expect(mockHouseholdRepository.updateHouseholdCallCount == 0)
    }
    
    // MARK: - Permission Tests
    
    @Test("Deactivate family fails for non-manager non-admin")
    func deactivateFamilyFailsForNonManager() async throws {
        // Given
        let householdId = "household-1"
        let regularUserId = "regular-user"
        
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [regularUserId],
            managers: ["other-manager"],
            isActive: true
        )
        // Regular parent who is NOT a manager and NOT committee
        let regularUser = TestFixtures.createUser(
            id: regularUserId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: []
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[regularUserId] = regularUser
        
        let request = DeactivateFamilyRequest(
            householdId: householdId,
            reason: nil,
            cancelFutureAssignments: false,
            requestingUserId: regularUserId
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockHouseholdRepository.updateHouseholdCallCount == 0)
    }
    
    // MARK: - Error Tests
    
    @Test("Deactivate family fails when household not found")
    func deactivateFamilyFailsWhenHouseholdNotFound() async throws {
        // Given
        let managerId = "manager-1"
        let manager = TestFixtures.createParent(id: managerId)
        mockUserRepository.usersById[managerId] = manager
        // No household in repository
        
        let request = DeactivateFamilyRequest(
            householdId: "non-existent",
            reason: nil,
            cancelFutureAssignments: false,
            requestingUserId: managerId
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Deactivate family fails when requesting user not found")
    func deactivateFamilyFailsWhenUserNotFound() async throws {
        // Given
        let householdId = "household-1"
        let household = TestFixtures.createHousehold(id: householdId, isActive: true)
        mockHouseholdRepository.addHousehold(household)
        // User not in repository
        
        let request = DeactivateFamilyRequest(
            householdId: householdId,
            reason: nil,
            cancelFutureAssignments: false,
            requestingUserId: "non-existent"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Deactivate family propagates repository update error")
    func deactivateFamilyPropagatesUpdateError() async throws {
        // Given
        let householdId = "household-1"
        let managerId = "manager-1"
        
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [managerId],
            managers: [managerId],
            isActive: true
        )
        let manager = TestFixtures.createUser(
            id: managerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[managerId] = manager
        mockHouseholdRepository.updateHouseholdError = DomainError.networkError
        
        let request = DeactivateFamilyRequest(
            householdId: householdId,
            reason: nil,
            cancelFutureAssignments: false,
            requestingUserId: managerId
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
