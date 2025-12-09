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
        // Validate and convert boundary ID to domain ID type
        let userId = try UserId(request.userId)
        
        // Call service to claim profile (Cloud Function handles validation and linking)
        let result = try await onboardingService.claimProfile(claimCode: request.claimCode, userId: userId)
        
        // Fetch updated user if successful
        var profile: ClaimedProfileInfo?
        if result.success, let resultUserId = result.userId {
            if let user = try? await userRepository.getUser(id: resultUserId) {
                profile = ClaimedProfileInfo(from: user)
            }
        }
        
        return ClaimProfileResponse(
            success: result.success,
            profile: profile,
            message: result.message
        )
    }
}
