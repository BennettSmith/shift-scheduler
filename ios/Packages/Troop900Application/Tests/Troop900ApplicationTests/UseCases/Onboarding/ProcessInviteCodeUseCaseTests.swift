import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("ProcessInviteCodeUseCase Tests")
struct ProcessInviteCodeUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockOnboardingService = MockOnboardingService()
    private let mockHouseholdRepository = MockHouseholdRepository()
    
    private var useCase: ProcessInviteCodeUseCase {
        ProcessInviteCodeUseCase(
            onboardingService: mockOnboardingService,
            householdRepository: mockHouseholdRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Process invite code succeeds for parent role")
    func processInviteCodeSucceedsForParent() async throws {
        // Given
        let code = "INVITE-ABC123"
        let userId = "user-123"
        let householdId = "household-456"
        let householdName = "Smith Family"
        
        mockOnboardingService.processInviteCodeResult = .success(InviteCodeResult(
            success: true,
            householdId: householdId,
            userRole: .parent,
            message: "Welcome to the household!"
        ))
        mockHouseholdRepository.householdsById[householdId] = TestFixtures.createHousehold(
            id: householdId,
            name: householdName
        )
        
        let request = ProcessInviteCodeRequest(code: code, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.householdId == householdId)
        #expect(response.householdName == householdName)
        #expect(response.role == .parent)
        #expect(response.message == "Welcome to the household!")
        #expect(mockOnboardingService.processInviteCodeCallCount == 1)
        #expect(mockOnboardingService.processInviteCodeCalledWith[0].code == code)
        #expect(mockOnboardingService.processInviteCodeCalledWith[0].userId == userId)
    }
    
    @Test("Process invite code succeeds for scout role")
    func processInviteCodeSucceedsForScout() async throws {
        // Given
        let code = "SCOUT-XYZ789"
        let userId = "user-456"
        let householdId = "household-789"
        
        mockOnboardingService.processInviteCodeResult = .success(InviteCodeResult(
            success: true,
            householdId: householdId,
            userRole: .scout,
            message: "Scout profile linked!"
        ))
        mockHouseholdRepository.householdsById[householdId] = TestFixtures.createHousehold(
            id: householdId,
            name: "Jones Family"
        )
        
        let request = ProcessInviteCodeRequest(code: code, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.role == .scout)
    }
    
    @Test("Process invite code succeeds for committee member role")
    func processInviteCodeSucceedsForCommittee() async throws {
        // Given
        let code = "COMMITTEE-001"
        let userId = "user-789"
        let householdId = "household-abc"
        
        mockOnboardingService.processInviteCodeResult = .success(InviteCodeResult(
            success: true,
            householdId: householdId,
            userRole: .scoutmaster,
            message: "Committee access granted!"
        ))
        mockHouseholdRepository.householdsById[householdId] = TestFixtures.createHousehold(id: householdId)
        
        let request = ProcessInviteCodeRequest(code: code, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.role == .scoutmaster)
    }
    
    @Test("Process invite code handles missing household gracefully")
    func processInviteCodeHandlesMissingHousehold() async throws {
        // Given
        let code = "INVITE-ABC123"
        let userId = "user-123"
        let householdId = "household-missing"
        
        mockOnboardingService.processInviteCodeResult = .success(InviteCodeResult(
            success: true,
            householdId: householdId,
            userRole: .parent,
            message: "Joined household"
        ))
        // Household not in repository - getHousehold will throw, caught by try?
        
        let request = ProcessInviteCodeRequest(code: code, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.householdId == householdId)
        #expect(response.householdName == nil) // Name not available (fetch threw error)
        #expect(mockHouseholdRepository.getHouseholdCallCount == 1) // Verify fetch was attempted
        #expect(mockHouseholdRepository.getHouseholdCalledWith[0] == householdId)
    }
    
    // MARK: - Failure Tests
    
    @Test("Process invite code returns failure for invalid code")
    func processInviteCodeFailsForInvalidCode() async throws {
        // Given
        let code = "INVALID-CODE"
        let userId = "user-123"
        
        mockOnboardingService.processInviteCodeResult = .success(InviteCodeResult(
            success: false,
            householdId: nil,
            userRole: nil,
            message: "Invalid invite code"
        ))
        
        let request = ProcessInviteCodeRequest(code: code, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.householdId == nil)
        #expect(response.householdName == nil)
        #expect(response.role == nil)
        #expect(response.message == "Invalid invite code")
    }
    
    @Test("Process invite code returns failure for expired code")
    func processInviteCodeFailsForExpiredCode() async throws {
        // Given
        let code = "EXPIRED-CODE"
        let userId = "user-123"
        
        mockOnboardingService.processInviteCodeResult = .success(InviteCodeResult(
            success: false,
            householdId: nil,
            userRole: nil,
            message: "This invite code has expired"
        ))
        
        let request = ProcessInviteCodeRequest(code: code, userId: userId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.message == "This invite code has expired")
    }
    
    // MARK: - Error Tests
    
    @Test("Process invite code throws when service fails")
    func processInviteCodeThrowsWhenServiceFails() async throws {
        // Given
        let code = "ANY-CODE"
        let userId = "user-123"
        
        mockOnboardingService.processInviteCodeResult = .failure(DomainError.networkError)
        
        let request = ProcessInviteCodeRequest(code: code, userId: userId)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Process invite code throws for already used code")
    func processInviteCodeThrowsForAlreadyUsedCode() async throws {
        // Given
        let code = "USED-CODE"
        let userId = "user-123"
        
        mockOnboardingService.processInviteCodeResult = .failure(DomainError.inviteCodeAlreadyUsed)
        
        let request = ProcessInviteCodeRequest(code: code, userId: userId)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
