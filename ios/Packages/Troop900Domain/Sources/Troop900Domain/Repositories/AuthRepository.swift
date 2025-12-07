import Foundation

/// Protocol for authentication operations.
/// The Auth Repository handles user authentication state and sign-in/sign-out operations.
public protocol AuthRepository: Sendable {
    /// The currently authenticated user's ID, or nil if not authenticated.
    var currentUserId: String? { get }
    
    /// Sign in with Apple authentication.
    /// - Parameters:
    ///   - identityToken: The identity token from Apple Sign In.
    ///   - nonce: The nonce used for security.
    /// - Returns: The authenticated user's ID.
    func signInWithApple(identityToken: Data, nonce: String) async throws -> String
    
    /// Sign in with Google authentication.
    /// - Parameters:
    ///   - idToken: The ID token from Google Sign In.
    ///   - accessToken: The access token from Google Sign In.
    /// - Returns: The authenticated user's ID.
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> String
    
    /// Sign out the current user.
    func signOut() async throws
    
    /// Observe authentication state changes.
    /// - Returns: A stream of user IDs (nil when signed out).
    func observeAuthState() -> AsyncStream<String?>
}
