import Foundation

/// Protocol for getting household members.
public protocol GetHouseholdMembersUseCaseProtocol: Sendable {
    func execute(householdId: String) async throws -> HouseholdMembersResponse
}

/// Use case for retrieving all members of a household.
public final class GetHouseholdMembersUseCase: GetHouseholdMembersUseCaseProtocol, Sendable {
    private let householdRepository: HouseholdRepository
    private let familyUnitRepository: FamilyUnitRepository
    private let userRepository: UserRepository
    
    public init(
        householdRepository: HouseholdRepository,
        familyUnitRepository: FamilyUnitRepository,
        userRepository: UserRepository
    ) {
        self.householdRepository = householdRepository
        self.familyUnitRepository = familyUnitRepository
        self.userRepository = userRepository
    }
    
    public func execute(householdId: String) async throws -> HouseholdMembersResponse {
        let household = try await householdRepository.getHousehold(id: householdId)
        
        // Fetch all members
        var members: [User] = []
        for memberId in household.members {
            if let user = try? await userRepository.getUser(id: memberId) {
                members.append(user)
            }
        }
        
        // Fetch all family units
        let familyUnits = try await familyUnitRepository.getFamilyUnitsInHousehold(householdId: householdId)
        
        return HouseholdMembersResponse(
            household: household,
            members: members,
            familyUnits: familyUnits
        )
    }
}
