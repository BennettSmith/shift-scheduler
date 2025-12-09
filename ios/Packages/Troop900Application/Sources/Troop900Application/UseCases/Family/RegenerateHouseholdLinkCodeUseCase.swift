import Foundation
import Troop900Domain

/// Protocol for regenerating a household's link code.
public protocol RegenerateHouseholdLinkCodeUseCaseProtocol: Sendable {
    func execute(householdId: String, requestingUserId: String) async throws -> RegenerateHouseholdLinkCodeResponse
}

/// Use case for regenerating a household's link code.
/// Used for security when the existing code may be compromised or shared unintentionally.
public final class RegenerateHouseholdLinkCodeUseCase: RegenerateHouseholdLinkCodeUseCaseProtocol, Sendable {
    private let familyManagementService: FamilyManagementService
    private let householdRepository: HouseholdRepository
    private let userRepository: UserRepository
    
    public init(
        familyManagementService: FamilyManagementService,
        householdRepository: HouseholdRepository,
        userRepository: UserRepository
    ) {
        self.familyManagementService = familyManagementService
        self.householdRepository = householdRepository
        self.userRepository = userRepository
    }
    
    public func execute(householdId: String, requestingUserId: String) async throws -> RegenerateHouseholdLinkCodeResponse {
        // Validate and convert boundary ID to domain ID type
        let requestingUserIdValue = try UserId(requestingUserId)
        
        // Validate household exists
        _ = try await householdRepository.getHousehold(id: householdId)
        
        // Validate requesting user can manage this household
        let requestingUser = try await userRepository.getUser(id: requestingUserIdValue)
        guard requestingUser.canManageHouseholds.contains(householdId) else {
            throw DomainError.unauthorized
        }
        
        // Call service to regenerate link code (Cloud Function handles update)
        let newLinkCode = try await familyManagementService.regenerateHouseholdLinkCode(householdId: householdId)
        
        let now = Date()
        
        return RegenerateHouseholdLinkCodeResponse(
            success: true,
            newLinkCode: newLinkCode,
            message: "Household link code regenerated successfully",
            regeneratedAt: now
        )
    }
}
