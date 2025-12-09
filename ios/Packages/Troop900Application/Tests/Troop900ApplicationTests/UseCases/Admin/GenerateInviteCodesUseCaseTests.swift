import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GenerateInviteCodesUseCase Tests")
struct GenerateInviteCodesUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockInviteCodeRepository = MockInviteCodeRepository()
    
    private var useCase: GenerateInviteCodesUseCase {
        GenerateInviteCodesUseCase(inviteCodeRepository: mockInviteCodeRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Generate single invite code succeeds")
    func generateSingleCodeSucceeds() async throws {
        // Given
        let request = GenerateInviteCodesRequest(
            householdId: "household-1",
            role: .parent,
            count: 1,
            expirationDays: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.codes.count == 1)
        #expect(response.codes[0].role == .parent)
        #expect(response.codes[0].code.count == 8)
        #expect(response.message.contains("1"))
        #expect(mockInviteCodeRepository.createInviteCodeCallCount == 1)
    }
    
    @Test("Generate multiple invite codes succeeds")
    func generateMultipleCodesSucceeds() async throws {
        // Given
        let request = GenerateInviteCodesRequest(
            householdId: "household-1",
            role: .scout,
            count: 5,
            expirationDays: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.codes.count == 5)
        #expect(mockInviteCodeRepository.createInviteCodeCallCount == 5)
        
        // Verify all codes are unique
        let codeCounts = Set(response.codes.map { $0.code })
        #expect(codeCounts.count == 5)
        
        // Verify all codes have the same role
        for code in response.codes {
            #expect(code.role == .scout)
        }
    }
    
    @Test("Generate codes with expiration sets correct date")
    func generateCodesWithExpirationSetsDate() async throws {
        // Given
        let request = GenerateInviteCodesRequest(
            householdId: "household-1",
            role: .parent,
            count: 1,
            expirationDays: 7
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.codes.count == 1)
        #expect(response.codes[0].expiresAt != nil)
        
        // Verify expiration is approximately 7 days from now
        if let expiresAt = response.codes[0].expiresAt {
            let daysDifference = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0
            #expect(daysDifference >= 6 && daysDifference <= 7)
        }
    }
    
    @Test("Generate codes without expiration has no expiration date")
    func generateCodesWithoutExpirationHasNoDate() async throws {
        // Given
        let request = GenerateInviteCodesRequest(
            householdId: "household-1",
            role: .parent,
            count: 1,
            expirationDays: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.codes[0].expiresAt == nil)
    }
    
    @Test("Generate codes for different roles")
    func generateCodesForDifferentRoles() async throws {
        // Given
        let parentRequest = GenerateInviteCodesRequest(
            householdId: "household-1",
            role: .parent,
            count: 1,
            expirationDays: nil
        )
        let scoutRequest = GenerateInviteCodesRequest(
            householdId: "household-1",
            role: .scout,
            count: 1,
            expirationDays: nil
        )
        
        // When
        let parentResponse = try await useCase.execute(request: parentRequest)
        let scoutResponse = try await useCase.execute(request: scoutRequest)
        
        // Then
        #expect(parentResponse.codes[0].role == .parent)
        #expect(scoutResponse.codes[0].role == .scout)
    }
    
    // MARK: - Error Tests
    
    @Test("Generate codes propagates repository error")
    func generateCodesPropagatesRepositoryError() async throws {
        // Given
        mockInviteCodeRepository.createInviteCodeResult = .failure(DomainError.networkError)
        
        let request = GenerateInviteCodesRequest(
            householdId: "household-1",
            role: .parent,
            count: 1,
            expirationDays: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Generate zero codes returns empty array")
    func generateZeroCodesReturnsEmpty() async throws {
        // Given
        let request = GenerateInviteCodesRequest(
            householdId: "household-1",
            role: .parent,
            count: 0,
            expirationDays: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.codes.isEmpty)
        #expect(mockInviteCodeRepository.createInviteCodeCallCount == 0)
    }
}
