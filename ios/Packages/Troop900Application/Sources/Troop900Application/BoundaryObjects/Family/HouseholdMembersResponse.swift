import Foundation
import Troop900Domain

/// Response containing household members.
public struct HouseholdMembersResponse: Sendable, Equatable {
    public let household: Household
    public let members: [User]
    public let familyUnits: [FamilyUnit]
    
    public init(household: Household, members: [User], familyUnits: [FamilyUnit]) {
        self.household = household
        self.members = members
        self.familyUnits = familyUnits
    }
}
