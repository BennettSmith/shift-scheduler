import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("SignOutUseCase Tests")
struct SignOutUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAuthRepository = MockAuthRepository()
    
    private var useCase: SignOutUseCase {
        SignOutUseCase(authRepository: mockAuthRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Sign out succeeds")
    func signOutSucceeds() async throws {
        // Given
        mockAuthRepository.signOutError = nil
        
        // When
        try await useCase.execute()
        
        // Then
        #expect(mockAuthRepository.signOutCallCount == 1)
    }
    
    // MARK: - Error Tests
    
    @Test("Sign out fails when auth repository throws error")
    func signOutFailsWhenAuthFails() async throws {
        // Given
        mockAuthRepository.signOutError = DomainError.notAuthenticated
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute()
        }
        #expect(mockAuthRepository.signOutCallCount == 1)
    }
    
    @Test("Sign out propagates network error")
    func signOutPropagatesNetworkError() async throws {
        // Given
        mockAuthRepository.signOutError = DomainError.networkError
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute()
        }
    }
}
