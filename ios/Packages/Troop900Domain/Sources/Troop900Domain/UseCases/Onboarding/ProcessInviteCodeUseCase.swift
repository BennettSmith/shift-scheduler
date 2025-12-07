import Foundation

/// Protocol for processing an invite code.
public protocol ProcessInviteCodeUseCaseProtocol: Sendable {
    func execute(request: ProcessInviteCodeRequest) async throws -> ProcessInviteCodeResponse
}

/// Use case for processing an invite code to join a household.
public final class ProcessInviteCodeUseCase: ProcessInviteCodeUseCaseProtocol, Sendable {
    private let onboardingService: OnboardingService
    private let householdRepository: HouseholdRepository
    
    public init(onboardingService: OnboardingService, householdRepository: HouseholdRepository) {
        self.onboardingService = onboardingService
        self.householdRepository = householdRepository
    }
    
    public func execute(request: ProcessInviteCodeRequest) async throws -> ProcessInviteCodeResponse {
        // Call service to process invite code (Cloud Function handles validation and assignment)
        let result = try await onboardingService.processInviteCode(code: request.code, userId: request.userId)
        
        // Fetch household name if successful
        var householdName: String?
        if let householdId = result.householdId {
            if let household = try? await householdRepository.getHousehold(id: householdId) {
                householdName = household.name
            }
        }
        
        return ProcessInviteCodeResponse(
            success: result.success,
            householdId: result.householdId,
            householdName: householdName,
            role: result.userRole,
            message: result.message
        )
    }
}
