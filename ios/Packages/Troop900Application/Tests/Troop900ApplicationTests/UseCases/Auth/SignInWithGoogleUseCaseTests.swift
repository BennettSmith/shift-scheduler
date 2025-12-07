import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("SignInWithGoogleUseCase Tests")
struct SignInWithGoogleUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAuthRepository = MockAuthRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: SignInWithGoogleUseCase {
        SignInWithGoogleUseCase(
            authRepository: mockAuthRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Sign in succeeds for new user without existing profile")
    func signInSucceedsForNewUser() async throws {
        // Given
        let idToken = "test-id-token"
        let accessToken = "test-access-token"
        let expectedUserId = "user-456"
        
        mockAuthRepository.signInWithGoogleResult = .success(expectedUserId)
        // No user in repository = new user
        
        // When
        let response = try await useCase.execute(idToken: idToken, accessToken: accessToken)
        
        // Then
        #expect(response.userId == expectedUserId)
        #expect(response.isNewUser == true)
        #expect(response.needsOnboarding == true)
        #expect(mockAuthRepository.signInWithGoogleCallCount == 1)
    }
    
    @Test("Sign in succeeds for existing unclaimed user")
    func signInSucceedsForUnclaimedUser() async throws {
        // Given
        let idToken = "test-id-token"
        let accessToken = "test-access-token"
        let expectedUserId = "user-456"
        let unclaimedUser = TestFixtures.createUser(id: expectedUserId, isClaimed: false)
        
        mockAuthRepository.signInWithGoogleResult = .success(expectedUserId)
        mockUserRepository.usersById[expectedUserId] = unclaimedUser
        
        // When
        let response = try await useCase.execute(idToken: idToken, accessToken: accessToken)
        
        // Then
        #expect(response.userId == expectedUserId)
        #expect(response.isNewUser == false)
        #expect(response.needsOnboarding == true)
    }
    
    @Test("Sign in succeeds for existing claimed user")
    func signInSucceedsForClaimedUser() async throws {
        // Given
        let idToken = "test-id-token"
        let accessToken = "test-access-token"
        let expectedUserId = "user-456"
        let claimedUser = TestFixtures.createUser(id: expectedUserId, isClaimed: true)
        
        mockAuthRepository.signInWithGoogleResult = .success(expectedUserId)
        mockUserRepository.usersById[expectedUserId] = claimedUser
        
        // When
        let response = try await useCase.execute(idToken: idToken, accessToken: accessToken)
        
        // Then
        #expect(response.userId == expectedUserId)
        #expect(response.isNewUser == false)
        #expect(response.needsOnboarding == false)
    }
    
    // MARK: - Error Tests
    
    @Test("Sign in fails when auth repository throws error")
    func signInFailsWhenAuthFails() async throws {
        // Given
        let idToken = "test-id-token"
        let accessToken = "test-access-token"
        
        mockAuthRepository.signInWithGoogleResult = .failure(DomainError.invalidCredentials)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(idToken: idToken, accessToken: accessToken)
        }
    }
    
    @Test("Sign in handles user repository error gracefully")
    func signInHandlesUserRepositoryError() async throws {
        // Given
        let idToken = "test-id-token"
        let accessToken = "test-access-token"
        let expectedUserId = "user-456"
        
        mockAuthRepository.signInWithGoogleResult = .success(expectedUserId)
        mockUserRepository.getUserResult = .failure(DomainError.userNotFound)
        
        // When - should not throw, treats error as new user (use case uses try?)
        let response = try await useCase.execute(idToken: idToken, accessToken: accessToken)
        
        // Then
        #expect(response.userId == expectedUserId)
        #expect(response.isNewUser == true)
        #expect(response.needsOnboarding == true)
        #expect(mockUserRepository.getUserCallCount == 1) // Verify fetch was attempted
        #expect(mockUserRepository.getUserCalledWith[0] == expectedUserId)
    }
}
