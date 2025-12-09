import Foundation
import Troop900Domain

/// Mock implementation of AuthRepository for testing
public final class MockAuthRepository: AuthRepository, @unchecked Sendable {
    
    // MARK: - State
    
    /// The currently authenticated user ID
    private var _currentUserId: UserId?
    
    public var currentUserId: UserId? {
        _currentUserId
    }
    
    // MARK: - Configurable Results
    
    public var signInWithAppleResult: Result<UserId, Error>?
    public var signInWithGoogleResult: Result<UserId, Error>?
    public var signOutError: Error?
    
    /// Values to emit from observeAuthState() stream
    public var authStateValues: [UserId?] = []
    
    // MARK: - Call Tracking
    
    public var signInWithAppleCallCount = 0
    public var signInWithAppleCalledWith: [(identityToken: Data, nonce: String)] = []
    
    public var signInWithGoogleCallCount = 0
    public var signInWithGoogleCalledWith: [(idToken: String, accessToken: String)] = []
    
    public var signOutCallCount = 0
    
    // MARK: - AuthRepository Implementation
    
    public func signInWithApple(identityToken: Data, nonce: String) async throws -> UserId {
        signInWithAppleCallCount += 1
        signInWithAppleCalledWith.append((identityToken, nonce))
        
        if let result = signInWithAppleResult {
            let userId = try result.get()
            _currentUserId = userId
            return userId
        }
        
        // Default: generate a user ID and sign in
        let userId = UserId(unchecked: "apple-user-\(UUID().uuidString.prefix(8))")
        _currentUserId = userId
        return userId
    }
    
    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> UserId {
        signInWithGoogleCallCount += 1
        signInWithGoogleCalledWith.append((idToken, accessToken))
        
        if let result = signInWithGoogleResult {
            let userId = try result.get()
            _currentUserId = userId
            return userId
        }
        
        // Default: generate a user ID and sign in
        let userId = UserId(unchecked: "google-user-\(UUID().uuidString.prefix(8))")
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
    
    public func observeAuthState() -> AsyncStream<UserId?> {
        AsyncStream { continuation in
            if !authStateValues.isEmpty {
                // Emit configured values
                for value in authStateValues {
                    continuation.yield(value)
                }
            } else {
                // Default: emit current user ID
                continuation.yield(_currentUserId)
            }
            continuation.finish()
        }
    }
    
    // MARK: - Test Helpers
    
    /// Sets the current user ID without going through sign in
    public func setCurrentUserId(_ userId: UserId?) {
        _currentUserId = userId
    }
    
    /// Simulates a user being signed in
    public func simulateSignedIn(userId: String) {
        _currentUserId = UserId(unchecked: userId)
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
        authStateValues.removeAll()
        signInWithAppleCallCount = 0
        signInWithAppleCalledWith.removeAll()
        signInWithGoogleCallCount = 0
        signInWithGoogleCalledWith.removeAll()
        signOutCallCount = 0
    }
}
