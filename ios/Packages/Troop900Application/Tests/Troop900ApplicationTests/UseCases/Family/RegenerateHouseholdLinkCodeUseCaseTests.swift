import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("RegenerateHouseholdLinkCodeUseCase Tests")
struct RegenerateHouseholdLinkCodeUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockFamilyManagementService = MockFamilyManagementService()
    private let mockHouseholdRepository = MockHouseholdRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: RegenerateHouseholdLinkCodeUseCase {
        RegenerateHouseholdLinkCodeUseCase(
            familyManagementService: mockFamilyManagementService,
            householdRepository: mockHouseholdRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Regenerate link code succeeds for household manager")
    func regenerateLinkCodeSucceedsForManager() async throws {
        // Given
        let householdId = "household-1"
        let managerId = "manager-1"
        
        let household = TestFixtures.createHousehold(id: householdId, managers: [managerId])
        let manager = TestFixtures.createUser(
            id: managerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[managerId] = manager
        
        mockFamilyManagementService.regenerateHouseholdLinkCodeResult = .success("NEWCODE123")
        
        // When
        let response = try await useCase.execute(householdId: householdId, requestingUserId: managerId)
        
        // Then
        #expect(response.success == true)
        #expect(response.newLinkCode == "NEWCODE123")
        #expect(response.message.contains("successfully"))
        #expect(mockFamilyManagementService.regenerateHouseholdLinkCodeCallCount == 1)
        #expect(mockFamilyManagementService.regenerateHouseholdLinkCodeCalledWith[0] == householdId)
    }
    
    @Test("Regenerate link code returns new random code")
    func regenerateLinkCodeReturnsNewCode() async throws {
        // Given
        let householdId = "household-1"
        let managerId = "manager-1"
        
        let household = TestFixtures.createHousehold(id: householdId, managers: [managerId], linkCode: "OLDCODE")
        let manager = TestFixtures.createUser(
            id: managerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[managerId] = manager
        
        // When
        let response = try await useCase.execute(householdId: householdId, requestingUserId: managerId)
        
        // Then
        #expect(response.success == true)
        #expect(response.newLinkCode != nil)
        #expect(response.newLinkCode != "OLDCODE")
    }
    
    // MARK: - Permission Tests
    
    @Test("Regenerate link code fails for non-manager")
    func regenerateLinkCodeFailsForNonManager() async throws {
        // Given
        let householdId = "household-1"
        let nonManagerId = "non-manager-1"
        
        let household = TestFixtures.createHousehold(id: householdId, managers: ["other-manager"])
        // User can NOT manage this household
        let nonManager = TestFixtures.createUser(
            id: nonManagerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: []
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[nonManagerId] = nonManager
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(householdId: householdId, requestingUserId: nonManagerId)
        }
        #expect(mockFamilyManagementService.regenerateHouseholdLinkCodeCallCount == 0)
    }
    
    @Test("Regenerate link code fails for user managing different household")
    func regenerateLinkCodeFailsForDifferentHouseholdManager() async throws {
        // Given
        let householdId = "household-1"
        let userId = "user-1"
        
        let household = TestFixtures.createHousehold(id: householdId)
        // User manages a different household
        let user = TestFixtures.createUser(
            id: userId,
            role: .parent,
            households: ["other-household"],
            canManageHouseholds: ["other-household"]
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[userId] = user
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(householdId: householdId, requestingUserId: userId)
        }
    }
    
    // MARK: - Error Tests
    
    @Test("Regenerate link code fails when household not found")
    func regenerateLinkCodeFailsWhenHouseholdNotFound() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        // No household in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(householdId: "non-existent", requestingUserId: userId)
        }
    }
    
    @Test("Regenerate link code fails when requesting user not found")
    func regenerateLinkCodeFailsWhenUserNotFound() async throws {
        // Given
        let householdId = "household-1"
        let household = TestFixtures.createHousehold(id: householdId)
        mockHouseholdRepository.addHousehold(household)
        // User not in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(householdId: householdId, requestingUserId: "non-existent")
        }
    }
    
    @Test("Regenerate link code propagates service error")
    func regenerateLinkCodePropagatesServiceError() async throws {
        // Given
        let householdId = "household-1"
        let managerId = "manager-1"
        
        let household = TestFixtures.createHousehold(id: householdId, managers: [managerId])
        let manager = TestFixtures.createUser(
            id: managerId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[managerId] = manager
        mockFamilyManagementService.regenerateHouseholdLinkCodeResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(householdId: householdId, requestingUserId: managerId)
        }
        #expect(mockFamilyManagementService.regenerateHouseholdLinkCodeCallCount == 1)
    }
}
