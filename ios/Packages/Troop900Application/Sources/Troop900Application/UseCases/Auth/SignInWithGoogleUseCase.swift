import Foundation
import Troop900Domain

/// Protocol for signing in with Google.
public protocol SignInWithGoogleUseCaseProtocol: Sendable {
    func execute(idToken: String, accessToken: String) async throws -> SignInResponse
}

/// Use case for handling Google Sign In authentication.
public final class SignInWithGoogleUseCase: SignInWithGoogleUseCaseProtocol, Sendable {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    public init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    public func execute(idToken: String, accessToken: String) async throws -> SignInResponse {
        // Sign in with Firebase Auth
        let userId = try await authRepository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
        
        // Check if user exists in Firestore
        let user = try? await userRepository.getUser(id: userId)
        let isNewUser = user == nil
        let needsOnboarding = user?.isClaimed == false || user == nil
        
        return SignInResponse(
            userId: userId.value,
            isNewUser: isNewUser,
            needsOnboarding: needsOnboarding
        )
    }
}
