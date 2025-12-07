import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("AddFamilyMemberUseCase Tests")
struct AddFamilyMemberUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockFamilyManagementService = MockFamilyManagementService()
    private let mockHouseholdRepository = MockHouseholdRepository()
    
    private var useCase: AddFamilyMemberUseCase {
        AddFamilyMemberUseCase(
            familyManagementService: mockFamilyManagementService,
            householdRepository: mockHouseholdRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Add family member succeeds for valid household")
    func addFamilyMemberSucceeds() async throws {
        // Given
        let householdId = "household-1"
        let household = TestFixtures.createHousehold(id: householdId)
        mockHouseholdRepository.addHousehold(household)
        
        let request = AddFamilyMemberRequest(
            householdId: householdId,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            role: .parent,
            familyUnitId: "family-unit-1"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.userId != nil)
        #expect(response.claimCode != nil)
        #expect(mockFamilyManagementService.addFamilyMemberCallCount == 1)
        #expect(mockFamilyManagementService.addFamilyMemberCalledWith[0].householdId == householdId)
        #expect(mockFamilyManagementService.addFamilyMemberCalledWith[0].firstName == "John")
        #expect(mockFamilyManagementService.addFamilyMemberCalledWith[0].lastName == "Doe")
    }
    
    @Test("Add family member returns claim code for profile claiming")
    func addFamilyMemberReturnsClaimCode() async throws {
        // Given
        let householdId = "household-1"
        let household = TestFixtures.createHousehold(id: householdId)
        mockHouseholdRepository.addHousehold(household)
        
        mockFamilyManagementService.addFamilyMemberResult = .success(AddFamilyMemberResult(
            success: true,
            userId: "new-user-123",
            claimCode: "CLAIM123",
            message: "Successfully added"
        ))
        
        let request = AddFamilyMemberRequest(
            householdId: householdId,
            firstName: "Jane",
            lastName: "Doe",
            email: "jane@example.com",
            role: .scout,
            familyUnitId: "family-unit-1"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.userId == "new-user-123")
        #expect(response.claimCode == "CLAIM123")
    }
    
    // MARK: - Validation Tests
    
    @Test("Add family member fails when household not found")
    func addFamilyMemberFailsWhenHouseholdNotFound() async throws {
        // Given - no household in repository
        let request = AddFamilyMemberRequest(
            householdId: "non-existent",
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            role: .parent,
            familyUnitId: "family-unit-1"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockFamilyManagementService.addFamilyMemberCallCount == 0)
    }
    
    // MARK: - Service Error Tests
    
    @Test("Add family member propagates service error")
    func addFamilyMemberPropagatesServiceError() async throws {
        // Given
        let householdId = "household-1"
        let household = TestFixtures.createHousehold(id: householdId)
        mockHouseholdRepository.addHousehold(household)
        mockFamilyManagementService.addFamilyMemberResult = .failure(DomainError.networkError)
        
        let request = AddFamilyMemberRequest(
            householdId: householdId,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            role: .parent,
            familyUnitId: "family-unit-1"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockFamilyManagementService.addFamilyMemberCallCount == 1)
    }
}
