import Foundation
import Troop900Domain

/// Protocol for linking a scout to an additional household.
public protocol LinkScoutToHouseholdUseCaseProtocol: Sendable {
    func execute(request: LinkScoutRequest) async throws -> LinkScoutResponse
}

/// Use case for linking an existing scout to an additional household.
/// This enables scouts to be part of multiple households (e.g., divorced parents).
public final class LinkScoutToHouseholdUseCase: LinkScoutToHouseholdUseCaseProtocol, Sendable {
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
    
    public func execute(request: LinkScoutRequest) async throws -> LinkScoutResponse {
        // Validate and convert boundary IDs to domain ID types
        let scoutId = try UserId(request.scoutId)
        let requestingUserId = try UserId(request.requestingUserId)
        
        // Validate scout exists
        let scout = try await userRepository.getUser(id: scoutId)
        
        // Validate household exists via link code
        guard let targetHousehold = try await householdRepository.getHouseholdByLinkCode(linkCode: request.householdLinkCode) else {
            return LinkScoutResponse(
                success: false,
                householdId: nil,
                message: "Invalid household link code",
                householdIds: nil
            )
        }
        
        // Validate requesting user is in target household
        let requestingUser = try await userRepository.getUser(id: requestingUserId)
        guard requestingUser.households.contains(targetHousehold.id) else {
            throw DomainError.unauthorized
        }
        
        // Check if scout is already in this household
        if scout.households.contains(targetHousehold.id) {
            return LinkScoutResponse(
                success: false,
                householdId: targetHousehold.id,
                message: "Scout is already a member of this household",
                householdIds: scout.households
            )
        }
        
        // Call service to link scout (Cloud Function handles updates)
        let result = try await familyManagementService.linkScoutToHousehold(
            scoutId: scoutId,
            linkCode: request.householdLinkCode
        )
        
        // Fetch updated scout to get new household list
        let updatedScout = try await userRepository.getUser(id: scoutId)
        
        return LinkScoutResponse(
            success: result.success,
            householdId: result.householdId,
            message: result.message,
            householdIds: updatedScout.households
        )
    }
}
