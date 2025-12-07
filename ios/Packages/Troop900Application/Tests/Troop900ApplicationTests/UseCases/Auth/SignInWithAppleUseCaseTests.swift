import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("SignInWithAppleUseCase Tests")
struct SignInWithAppleUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAuthRepository = MockAuthRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: SignInWithAppleUseCase {
        SignInWithAppleUseCase(
            authRepository: mockAuthRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Sign in succeeds for new user without existing profile")
    func signInSucceedsForNewUser() async throws {
        // Given
        let identityToken = "test-identity-token".data(using: .utf8)!
        let nonce = "test-nonce"
        let expectedUserId = "user-123"
        
        mockAuthRepository.signInWithAppleResult = .success(expectedUserId)
        // No user in repository = new user
        
        // When
        let response = try await useCase.execute(identityToken: identityToken, nonce: nonce)
        
        // Then
        #expect(response.userId == expectedUserId)
        #expect(response.isNewUser == true)
        #expect(response.needsOnboarding == true)
        #expect(mockAuthRepository.signInWithAppleCallCount == 1)
    }
    
    @Test("Sign in succeeds for existing unclaimed user")
    func signInSucceedsForUnclaimedUser() async throws {
        // Given
        let identityToken = "test-identity-token".data(using: .utf8)!
        let nonce = "test-nonce"
        let expectedUserId = "user-123"
        let unclaimedUser = TestFixtures.createUser(id: expectedUserId, isClaimed: false)
        
        mockAuthRepository.signInWithAppleResult = .success(expectedUserId)
        mockUserRepository.usersById[expectedUserId] = unclaimedUser
        
        // When
        let response = try await useCase.execute(identityToken: identityToken, nonce: nonce)
        
        // Then
        #expect(response.userId == expectedUserId)
        #expect(response.isNewUser == false)
        #expect(response.needsOnboarding == true)
    }
    
    @Test("Sign in succeeds for existing claimed user")
    func signInSucceedsForClaimedUser() async throws {
        // Given
        let identityToken = "test-identity-token".data(using: .utf8)!
        let nonce = "test-nonce"
        let expectedUserId = "user-123"
        let claimedUser = TestFixtures.createUser(id: expectedUserId, isClaimed: true)
        
        mockAuthRepository.signInWithAppleResult = .success(expectedUserId)
        mockUserRepository.usersById[expectedUserId] = claimedUser
        
        // When
        let response = try await useCase.execute(identityToken: identityToken, nonce: nonce)
        
        // Then
        #expect(response.userId == expectedUserId)
        #expect(response.isNewUser == false)
        #expect(response.needsOnboarding == false)
    }
    
    // MARK: - Error Tests
    
    @Test("Sign in fails when auth repository throws error")
    func signInFailsWhenAuthFails() async throws {
        // Given
        let identityToken = "test-identity-token".data(using: .utf8)!
        let nonce = "test-nonce"
        
        mockAuthRepository.signInWithAppleResult = .failure(DomainError.invalidCredentials)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(identityToken: identityToken, nonce: nonce)
        }
    }
    
    @Test("Sign in handles user repository error gracefully")
    func signInHandlesUserRepositoryError() async throws {
        // Given
        let identityToken = "test-identity-token".data(using: .utf8)!
        let nonce = "test-nonce"
        let expectedUserId = "user-123"
        
        mockAuthRepository.signInWithAppleResult = .success(expectedUserId)
        mockUserRepository.getUserResult = .failure(DomainError.userNotFound)
        
        // When - should not throw, treats error as new user (use case uses try?)
        let response = try await useCase.execute(identityToken: identityToken, nonce: nonce)
        
        // Then
        #expect(response.userId == expectedUserId)
        #expect(response.isNewUser == true)
        #expect(response.needsOnboarding == true)
        #expect(mockUserRepository.getUserCallCount == 1) // Verify fetch was attempted
        #expect(mockUserRepository.getUserCalledWith[0] == expectedUserId)
    }
}
