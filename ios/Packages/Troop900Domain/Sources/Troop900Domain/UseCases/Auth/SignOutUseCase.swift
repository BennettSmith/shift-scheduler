import Foundation

/// Protocol for signing out.
public protocol SignOutUseCaseProtocol: Sendable {
    func execute() async throws
}

/// Use case for signing out the current user.
public final class SignOutUseCase: SignOutUseCaseProtocol, Sendable {
    private let authRepository: AuthRepository
    
    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    public func execute() async throws {
        try await authRepository.signOut()
    }
}
