import Foundation
import Troop900Domain

/// Mock implementation of AuthRepository for testing
public final class MockAuthRepository: AuthRepository, @unchecked Sendable {
    
    // MARK: - State
    
    /// The currently authenticated user ID
    private var _currentUserId: String?
    
    public var currentUserId: String? {
        _currentUserId
    }
    
    // MARK: - Configurable Results
    
    public var signInWithAppleResult: Result<String, Error>?
    public var signInWithGoogleResult: Result<String, Error>?
    public var signOutError: Error?
    
    // MARK: - Call Tracking
    
    public var signInWithAppleCallCount = 0
    public var signInWithAppleCalledWith: [(identityToken: Data, nonce: String)] = []
    
    public var signInWithGoogleCallCount = 0
    public var signInWithGoogleCalledWith: [(idToken: String, accessToken: String)] = []
    
    public var signOutCallCount = 0
    
    // MARK: - AuthRepository Implementation
    
    public func signInWithApple(identityToken: Data, nonce: String) async throws -> String {
        signInWithAppleCallCount += 1
        signInWithAppleCalledWith.append((identityToken, nonce))
        
        if let result = signInWithAppleResult {
            let userId = try result.get()
            _currentUserId = userId
            return userId
        }
        
        // Default: generate a user ID and sign in
        let userId = "apple-user-\(UUID().uuidString.prefix(8))"
        _currentUserId = userId
        return userId
    }
    
    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> String {
        signInWithGoogleCallCount += 1
        signInWithGoogleCalledWith.append((idToken, accessToken))
        
        if let result = signInWithGoogleResult {
            let userId = try result.get()
            _currentUserId = userId
            return userId
        }
        
        // Default: generate a user ID and sign in
        let userId = "google-user-\(UUID().uuidString.prefix(8))"
        _currentUserId = userId
        return userId
    }
    
    public func signOut() async throws {
        signOutCallCount += 1
        
        if let error = signOutError {
            throw error
        }
        
        _currentUserId = nil
    }
    
    public func observeAuthState() -> AsyncStream<String?> {
        AsyncStream { continuation in
            continuation.yield(_currentUserId)
            continuation.finish()
        }
    }
    
    // MARK: - Test Helpers
    
    /// Sets the current user ID without going through sign in
    public func setCurrentUserId(_ userId: String?) {
        _currentUserId = userId
    }
    
    /// Simulates a user being signed in
    public func simulateSignedIn(userId: String) {
        _currentUserId = userId
    }
    
    /// Simulates a user being signed out
    public func simulateSignedOut() {
        _currentUserId = nil
    }
    
    /// Resets all state and call tracking
    public func reset() {
        _currentUserId = nil
        signInWithAppleResult = nil
        signInWithGoogleResult = nil
        signOutError = nil
        signInWithAppleCallCount = 0
        signInWithAppleCalledWith.removeAll()
        signInWithGoogleCallCount = 0
        signInWithGoogleCalledWith.removeAll()
        signOutCallCount = 0
    }
}
