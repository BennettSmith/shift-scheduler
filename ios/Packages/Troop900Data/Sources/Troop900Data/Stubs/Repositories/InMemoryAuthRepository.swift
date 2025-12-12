import Foundation
import Troop900Domain

/// In-memory implementation of AuthRepository for testing and local development.
public final class InMemoryAuthRepository: AuthRepository, @unchecked Sendable {
    private var _currentUserId: UserId?
    private let lock = AsyncLock()
    
    public init(initialUserId: UserId? = nil) {
        _currentUserId = initialUserId
    }
    
    public var currentUserId: UserId? {
        lock.lock()
        defer { lock.unlock() }
        return _currentUserId
    }
    
    public func signInWithApple(identityToken: Data, nonce: String) async throws -> UserId {
        lock.lock()
        defer { lock.unlock() }
        
        // For testing: create a mock user ID from the nonce
        // In real implementation, this would validate the token with Firebase
        let userId = try UserId(unchecked: "apple_\(nonce.prefix(8))")
        _currentUserId = userId
        return userId
    }
    
    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> UserId {
        lock.lock()
        defer { lock.unlock() }
        
        // For testing: create a mock user ID from the token
        // In real implementation, this would validate the token with Firebase
        let userId = try UserId(unchecked: "google_\(idToken.prefix(8))")
        _currentUserId = userId
        return userId
    }
    
    public func signOut() async throws {
        lock.lock()
        defer { lock.unlock() }
        _currentUserId = nil
    }
    
    public func observeAuthState() -> AsyncStream<UserId?> {
        AsyncStream { continuation in
            lock.lock()
            let currentId = _currentUserId
            lock.unlock()
            
            continuation.yield(currentId)
            continuation.finish()
        }
    }
    
    // MARK: - Test Helpers
    
    public func setCurrentUser(_ userId: UserId?) {
        lock.lock()
        defer { lock.unlock() }
        _currentUserId = userId
    }
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        _currentUserId = nil
    }
}
