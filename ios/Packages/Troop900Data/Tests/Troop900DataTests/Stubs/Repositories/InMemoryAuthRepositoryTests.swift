import Foundation
import Testing
@testable import Troop900Data
import Troop900Domain

@Suite("InMemoryAuthRepository Tests")
struct InMemoryAuthRepositoryTests {
    
    @Test("Initial current user ID is nil")
    func initialCurrentUserIdIsNil() {
        let repository = InMemoryAuthRepository()
        
        #expect(repository.currentUserId == nil)
    }
    
    @Test("Initial current user ID can be set")
    func initialCurrentUserIdCanBeSet() {
        let userId = UserId(unchecked: "user-1")
        let repository = InMemoryAuthRepository(initialUserId: userId)
        
        #expect(repository.currentUserId == userId)
    }
    
    @Test("Sign in with Apple")
    func signInWithApple() async throws {
        let repository = InMemoryAuthRepository()
        let identityToken = Data("test-token".utf8)
        let nonce = "test-nonce-123"
        
        let userId = try await repository.signInWithApple(identityToken: identityToken, nonce: nonce)
        
        #expect(userId.value.hasPrefix("apple_"))
        #expect(repository.currentUserId == userId)
    }
    
    @Test("Sign in with Google")
    func signInWithGoogle() async throws {
        let repository = InMemoryAuthRepository()
        let idToken = "test-id-token"
        let accessToken = "test-access-token"
        
        let userId = try await repository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
        
        #expect(userId.value.hasPrefix("google_"))
        #expect(repository.currentUserId == userId)
    }
    
    @Test("Sign out clears current user")
    func signOut() async throws {
        let userId = UserId(unchecked: "user-1")
        let repository = InMemoryAuthRepository(initialUserId: userId)
        
        try await repository.signOut()
        
        #expect(repository.currentUserId == nil)
    }
    
    @Test("Observe auth state yields current user")
    func observeAuthState() async {
        let userId = UserId(unchecked: "user-1")
        let repository = InMemoryAuthRepository(initialUserId: userId)
        
        var observedUserId: UserId?
        for await currentUserId in repository.observeAuthState() {
            observedUserId = currentUserId
            break
        }
        
        #expect(observedUserId == userId)
    }
    
    @Test("Set current user helper")
    func setCurrentUser() {
        let repository = InMemoryAuthRepository()
        let userId = UserId(unchecked: "user-1")
        
        repository.setCurrentUser(userId)
        
        #expect(repository.currentUserId == userId)
    }
    
    @Test("Clear removes current user")
    func clear() {
        let userId = UserId(unchecked: "user-1")
        let repository = InMemoryAuthRepository(initialUserId: userId)
        
        repository.clear()
        
        #expect(repository.currentUserId == nil)
    }
}
