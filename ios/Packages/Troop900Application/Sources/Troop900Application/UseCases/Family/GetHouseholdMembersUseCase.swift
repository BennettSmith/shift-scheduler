import Foundation
import Troop900Domain

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
        var memberInfos: [MemberInfo] = []
        for memberId in household.members {
            // Convert string ID to UserId
            if let userId = try? UserId(memberId),
               let user = try? await userRepository.getUser(id: userId) {
                memberInfos.append(MemberInfo(from: user))
            }
        }
        
        // Fetch all family units
        let familyUnits = try await familyUnitRepository.getFamilyUnitsInHousehold(householdId: householdId)
        let familyUnitInfos = familyUnits.map { FamilyUnitInfo(from: $0) }
        
        return HouseholdMembersResponse(
            householdId: household.id,
            householdName: household.name,
            isActive: household.isActive,
            linkCode: household.linkCode,
            members: memberInfos,
            familyUnits: familyUnitInfos
        )
    }
}
