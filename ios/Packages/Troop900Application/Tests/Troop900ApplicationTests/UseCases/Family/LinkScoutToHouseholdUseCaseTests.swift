import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("LinkScoutToHouseholdUseCase Tests")
struct LinkScoutToHouseholdUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockFamilyManagementService = MockFamilyManagementService()
    private let mockHouseholdRepository = MockHouseholdRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: LinkScoutToHouseholdUseCase {
        LinkScoutToHouseholdUseCase(
            familyManagementService: mockFamilyManagementService,
            householdRepository: mockHouseholdRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Link scout succeeds with valid link code")
    func linkScoutSucceedsWithValidLinkCode() async throws {
        // Given
        let scoutId = "scout-1"
        let requestingUserId = "parent-1"
        let targetHouseholdId = "household-2"
        let linkCode = "VALIDCODE"
        
        // Scout is in household-1
        let scout = TestFixtures.createUser(
            id: scoutId,
            role: .scout,
            households: ["household-1"],
            canManageHouseholds: []
        )
        // Requesting user is in target household
        let requestingUser = TestFixtures.createUser(
            id: requestingUserId,
            role: .parent,
            households: [targetHouseholdId],
            canManageHouseholds: [targetHouseholdId]
        )
        let targetHousehold = TestFixtures.createHousehold(id: targetHouseholdId, linkCode: linkCode)
        
        mockUserRepository.usersById[scoutId] = scout
        mockUserRepository.usersById[requestingUserId] = requestingUser
        mockHouseholdRepository.addHousehold(targetHousehold)
        
        // Configure service result
        mockFamilyManagementService.linkScoutToHouseholdResult = .success(LinkScoutResult(
            success: true,
            householdId: targetHouseholdId,
            message: "Scout linked successfully"
        ))
        
        let request = LinkScoutRequest(
            scoutId: scoutId,
            householdLinkCode: linkCode,
            requestingUserId: requestingUserId
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.householdId == targetHouseholdId)
        #expect(mockFamilyManagementService.linkScoutToHouseholdCallCount == 1)
        #expect(mockFamilyManagementService.linkScoutToHouseholdCalledWith[0].scoutId == scoutId)
        #expect(mockFamilyManagementService.linkScoutToHouseholdCalledWith[0].linkCode == linkCode)
    }
    
    @Test("Link scout returns failure for invalid link code")
    func linkScoutReturnsFailureForInvalidLinkCode() async throws {
        // Given
        let scoutId = "scout-1"
        let requestingUserId = "parent-1"
        
        let scout = TestFixtures.createScout(id: scoutId)
        let requestingUser = TestFixtures.createParent(id: requestingUserId)
        
        mockUserRepository.usersById[scoutId] = scout
        mockUserRepository.usersById[requestingUserId] = requestingUser
        // No household with this link code
        
        let request = LinkScoutRequest(
            scoutId: scoutId,
            householdLinkCode: "INVALIDCODE",
            requestingUserId: requestingUserId
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.message.contains("Invalid household link code"))
        #expect(mockFamilyManagementService.linkScoutToHouseholdCallCount == 0)
    }
    
    @Test("Link scout returns failure when already in household")
    func linkScoutReturnsFailureWhenAlreadyInHousehold() async throws {
        // Given
        let scoutId = "scout-1"
        let requestingUserId = "parent-1"
        let targetHouseholdId = "household-1"
        let linkCode = "LINKCODE"
        
        // Scout is already in the target household (using householdId parameter)
        let scout = TestFixtures.createScout(id: scoutId, householdId: targetHouseholdId)
        let requestingUser = TestFixtures.createParent(id: requestingUserId, householdId: targetHouseholdId)
        let targetHousehold = TestFixtures.createHousehold(id: targetHouseholdId, linkCode: linkCode)
        
        mockUserRepository.usersById[scoutId] = scout
        mockUserRepository.usersById[requestingUserId] = requestingUser
        mockHouseholdRepository.addHousehold(targetHousehold)
        
        let request = LinkScoutRequest(
            scoutId: scoutId,
            householdLinkCode: linkCode,
            requestingUserId: requestingUserId
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.message.contains("already a member"))
        #expect(mockFamilyManagementService.linkScoutToHouseholdCallCount == 0)
    }
    
    // MARK: - Permission Tests
    
    @Test("Link scout fails when requesting user not in target household")
    func linkScoutFailsWhenRequestingUserNotInTargetHousehold() async throws {
        // Given
        let scoutId = "scout-1"
        let requestingUserId = "parent-1"
        let targetHouseholdId = "household-2"
        let linkCode = "VALIDCODE"
        
        let scout = TestFixtures.createScout(id: scoutId, householdId: "household-1")
        // Requesting user is NOT in the target household
        let requestingUser = TestFixtures.createParent(id: requestingUserId, householdId: "household-3")
        let targetHousehold = TestFixtures.createHousehold(id: targetHouseholdId, linkCode: linkCode)
        
        mockUserRepository.usersById[scoutId] = scout
        mockUserRepository.usersById[requestingUserId] = requestingUser
        mockHouseholdRepository.addHousehold(targetHousehold)
        
        let request = LinkScoutRequest(
            scoutId: scoutId,
            householdLinkCode: linkCode,
            requestingUserId: requestingUserId
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockFamilyManagementService.linkScoutToHouseholdCallCount == 0)
    }
    
    // MARK: - Error Tests
    
    @Test("Link scout fails when scout not found")
    func linkScoutFailsWhenScoutNotFound() async throws {
        // Given
        let requestingUserId = "parent-1"
        let requestingUser = TestFixtures.createParent(id: requestingUserId)
        mockUserRepository.usersById[requestingUserId] = requestingUser
        // Scout not in repository
        
        let request = LinkScoutRequest(
            scoutId: "non-existent",
            householdLinkCode: "VALIDCODE",
            requestingUserId: requestingUserId
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Link scout propagates service error")
    func linkScoutPropagatesServiceError() async throws {
        // Given
        let scoutId = "scout-1"
        let requestingUserId = "parent-1"
        let targetHouseholdId = "household-2"
        let linkCode = "VALIDCODE"
        
        let scout = TestFixtures.createScout(id: scoutId, householdId: "household-1")
        let requestingUser = TestFixtures.createUser(
            id: requestingUserId,
            role: .parent,
            households: [targetHouseholdId],
            canManageHouseholds: [targetHouseholdId]
        )
        let targetHousehold = TestFixtures.createHousehold(id: targetHouseholdId, linkCode: linkCode)
        
        mockUserRepository.usersById[scoutId] = scout
        mockUserRepository.usersById[requestingUserId] = requestingUser
        mockHouseholdRepository.addHousehold(targetHousehold)
        mockFamilyManagementService.linkScoutToHouseholdResult = .failure(DomainError.networkError)
        
        let request = LinkScoutRequest(
            scoutId: scoutId,
            householdLinkCode: linkCode,
            requestingUserId: requestingUserId
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockFamilyManagementService.linkScoutToHouseholdCallCount == 1)
    }
}
