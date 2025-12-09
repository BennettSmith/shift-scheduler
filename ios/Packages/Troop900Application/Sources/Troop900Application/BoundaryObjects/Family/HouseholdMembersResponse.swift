import Foundation

/// Flattened member info for household members response.
public struct MemberInfo: Sendable, Equatable, Identifiable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let role: UserRoleType
    public let isClaimed: Bool
    
    public init(id: String, firstName: String, lastName: String, fullName: String, role: UserRoleType, isClaimed: Bool) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.role = role
        self.isClaimed = isClaimed
    }
}

/// Flattened family unit info for household members response.
public struct FamilyUnitInfo: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String?
    public let scoutIds: [String]
    public let parentIds: [String]
    
    public init(id: String, name: String?, scoutIds: [String], parentIds: [String]) {
        self.id = id
        self.name = name
        self.scoutIds = scoutIds
        self.parentIds = parentIds
    }
}

/// Response containing household members.
public struct HouseholdMembersResponse: Sendable, Equatable {
    public let householdId: String
    public let householdName: String
    public let isActive: Bool
    public let linkCode: String?
    public let members: [MemberInfo]
    public let familyUnits: [FamilyUnitInfo]
    
    public init(
        householdId: String,
        householdName: String,
        isActive: Bool,
        linkCode: String?,
        members: [MemberInfo],
        familyUnits: [FamilyUnitInfo]
    ) {
        self.householdId = householdId
        self.householdName = householdName
        self.isActive = isActive
        self.linkCode = linkCode
        self.members = members
        self.familyUnits = familyUnits
    }
}
