import Foundation
import Troop900Domain

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
        // Validate and convert boundary ID to domain ID type
        let userId = try UserId(request.userId)
        
        // Call service to process invite code (Cloud Function handles validation and assignment)
        let result = try await onboardingService.processInviteCode(code: request.code, userId: userId)
        
        // Fetch household name if successful
        var householdName: String?
        if let householdId = result.householdId {
            if let household = try? await householdRepository.getHousehold(id: householdId) {
                householdName = household.name
            }
        }
        
        // Convert domain role to boundary role
        let role = result.userRole.map { UserRoleType(from: $0) }
        
        return ProcessInviteCodeResponse(
            success: result.success,
            householdId: result.householdId,
            householdName: householdName,
            role: role,
            message: result.message
        )
    }
}
