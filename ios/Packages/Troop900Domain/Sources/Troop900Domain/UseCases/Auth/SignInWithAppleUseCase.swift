import Foundation

/// Protocol for signing in with Apple.
public protocol SignInWithAppleUseCaseProtocol: Sendable {
    func execute(identityToken: Data, nonce: String) async throws -> SignInResponse
}

/// Use case for handling Apple Sign In authentication.
public final class SignInWithAppleUseCase: SignInWithAppleUseCaseProtocol, Sendable {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    public init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    public func execute(identityToken: Data, nonce: String) async throws -> SignInResponse {
        // Sign in with Firebase Auth
        let userId = try await authRepository.signInWithApple(identityToken: identityToken, nonce: nonce)
        
        // Check if user exists in Firestore
        let user = try? await userRepository.getUser(id: userId)
        let isNewUser = user == nil
        let needsOnboarding = user?.isClaimed == false || user == nil
        
        return SignInResponse(
            userId: userId,
            isNewUser: isNewUser,
            needsOnboarding: needsOnboarding
        )
    }
}
