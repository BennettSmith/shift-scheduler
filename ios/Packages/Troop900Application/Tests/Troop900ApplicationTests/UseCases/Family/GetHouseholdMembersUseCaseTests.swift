import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetHouseholdMembersUseCase Tests")
struct GetHouseholdMembersUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockHouseholdRepository = MockHouseholdRepository()
    private let mockFamilyUnitRepository = MockFamilyUnitRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: GetHouseholdMembersUseCase {
        GetHouseholdMembersUseCase(
            householdRepository: mockHouseholdRepository,
            familyUnitRepository: mockFamilyUnitRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Get household members succeeds with members and family units")
    func getHouseholdMembersSucceeds() async throws {
        // Given
        let householdId = "household-1"
        let parentId = "parent-1"
        let scoutId = "scout-1"
        
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [parentId, scoutId]
        )
        let parent = TestFixtures.createParent(id: parentId, firstName: "John", lastName: "Doe")
        let scout = TestFixtures.createScout(id: scoutId, firstName: "Jane", lastName: "Doe")
        let familyUnit = TestFixtures.createFamilyUnit(
            id: "family-unit-1",
            householdId: householdId,
            scouts: [scoutId],
            parents: [parentId]
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[parentId] = parent
        mockUserRepository.usersById[scoutId] = scout
        mockFamilyUnitRepository.familyUnitsById["family-unit-1"] = familyUnit
        
        // When
        let response = try await useCase.execute(householdId: householdId)
        
        // Then
        #expect(response.householdId == householdId)
        #expect(response.members.count == 2)
        #expect(response.familyUnits.count == 1)
        
        let memberIds = response.members.map(\.id)
        #expect(memberIds.contains(parentId))
        #expect(memberIds.contains(scoutId))
    }
    
    @Test("Get household members returns empty members when no members exist")
    func getHouseholdMembersReturnsEmptyMembers() async throws {
        // Given
        let householdId = "household-1"
        let household = TestFixtures.createHousehold(id: householdId, members: [])
        mockHouseholdRepository.addHousehold(household)
        
        // When
        let response = try await useCase.execute(householdId: householdId)
        
        // Then
        #expect(response.householdId == householdId)
        #expect(response.members.isEmpty)
    }
    
    @Test("Get household members handles missing member gracefully")
    func getHouseholdMembersHandlesMissingMember() async throws {
        // Given
        let householdId = "household-1"
        let existingMemberId = "existing-member"
        let missingMemberId = "missing-member"
        
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [existingMemberId, missingMemberId]
        )
        let existingMember = TestFixtures.createParent(id: existingMemberId)
        
        mockHouseholdRepository.addHousehold(household)
        mockUserRepository.usersById[existingMemberId] = existingMember
        // Missing member not in repository
        
        // When
        let response = try await useCase.execute(householdId: householdId)
        
        // Then - only existing member returned
        #expect(response.members.count == 1)
        #expect(response.members[0].id == existingMemberId)
    }
    
    @Test("Get household members returns multiple family units")
    func getHouseholdMembersReturnsMultipleFamilyUnits() async throws {
        // Given
        let householdId = "household-1"
        let household = TestFixtures.createHousehold(id: householdId, members: [])
        
        let familyUnit1 = TestFixtures.createFamilyUnit(
            id: "family-unit-1",
            householdId: householdId,
            name: "Smith Family"
        )
        let familyUnit2 = TestFixtures.createFamilyUnit(
            id: "family-unit-2",
            householdId: householdId,
            name: "Johnson Family"
        )
        
        mockHouseholdRepository.addHousehold(household)
        mockFamilyUnitRepository.familyUnitsById["family-unit-1"] = familyUnit1
        mockFamilyUnitRepository.familyUnitsById["family-unit-2"] = familyUnit2
        
        // When
        let response = try await useCase.execute(householdId: householdId)
        
        // Then
        #expect(response.familyUnits.count == 2)
    }
    
    // MARK: - Error Tests
    
    @Test("Get household members fails when household not found")
    func getHouseholdMembersFailsWhenHouseholdNotFound() async throws {
        // Given - no household in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(householdId: "non-existent")
        }
    }
    
    @Test("Get household members propagates family unit repository error")
    func getHouseholdMembersPropagatesFamilyUnitError() async throws {
        // Given
        let householdId = "household-1"
        let household = TestFixtures.createHousehold(id: householdId, members: [])
        mockHouseholdRepository.addHousehold(household)
        mockFamilyUnitRepository.getFamilyUnitsInHouseholdResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(householdId: householdId)
        }
    }
}
