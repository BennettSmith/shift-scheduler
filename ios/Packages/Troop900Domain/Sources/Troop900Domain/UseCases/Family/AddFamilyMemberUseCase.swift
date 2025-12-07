import Foundation

/// Protocol for adding a family member.
public protocol AddFamilyMemberUseCaseProtocol: Sendable {
    func execute(request: AddFamilyMemberRequest) async throws -> AddFamilyMemberResponse
}

/// Use case for adding a new family member to a household.
public final class AddFamilyMemberUseCase: AddFamilyMemberUseCaseProtocol, Sendable {
    private let familyManagementService: FamilyManagementService
    private let householdRepository: HouseholdRepository
    
    public init(
        familyManagementService: FamilyManagementService,
        householdRepository: HouseholdRepository
    ) {
        self.familyManagementService = familyManagementService
        self.householdRepository = householdRepository
    }
    
    public func execute(request: AddFamilyMemberRequest) async throws -> AddFamilyMemberResponse {
        // Validate household exists
        _ = try await householdRepository.getHousehold(id: request.householdId)
        
        // Call service to add family member (Cloud Function handles creation)
        let result = try await familyManagementService.addFamilyMember(request: request)
        
        return AddFamilyMemberResponse(
            success: result.success,
            userId: result.userId,
            claimCode: result.claimCode,
            message: result.message
        )
    }
}
