import Foundation
import Troop900Domain

/// Protocol for claiming a pre-created profile.
public protocol ClaimProfileUseCaseProtocol: Sendable {
    func execute(request: ClaimProfileRequest) async throws -> ClaimProfileResponse
}

/// Use case for claiming a pre-created user profile.
public final class ClaimProfileUseCase: ClaimProfileUseCaseProtocol, Sendable {
    private let onboardingService: OnboardingService
    private let userRepository: UserRepository
    
    public init(onboardingService: OnboardingService, userRepository: UserRepository) {
        self.onboardingService = onboardingService
        self.userRepository = userRepository
    }
    
    public func execute(request: ClaimProfileRequest) async throws -> ClaimProfileResponse {
        // Call service to claim profile (Cloud Function handles validation and linking)
        let result = try await onboardingService.claimProfile(claimCode: request.claimCode, userId: request.userId)
        
        // Fetch updated user if successful
        var user: User?
        if result.success, let userId = result.userId {
            user = try? await userRepository.getUser(id: userId)
        }
        
        return ClaimProfileResponse(
            success: result.success,
            user: user,
            message: result.message
        )
    }
}
