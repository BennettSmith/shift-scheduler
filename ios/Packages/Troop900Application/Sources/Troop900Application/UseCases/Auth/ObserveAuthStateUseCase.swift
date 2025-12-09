import Foundation
import Troop900Domain

/// Protocol for observing authentication state changes.
public protocol ObserveAuthStateUseCaseProtocol: Sendable {
    func execute() -> AsyncStream<String?>
}

/// Use case for observing real-time authentication state changes.
public final class ObserveAuthStateUseCase: ObserveAuthStateUseCaseProtocol, Sendable {
    private let authRepository: AuthRepository
    
    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    public func execute() -> AsyncStream<String?> {
        AsyncStream { continuation in
            let task = Task {
                for await userId in authRepository.observeAuthState() {
                    continuation.yield(userId?.value)
                }
                continuation.finish()
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
