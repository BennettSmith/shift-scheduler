import Foundation

/// Information about a user for the current user response.
public struct UserInfo: Sendable, Equatable, Identifiable {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let role: UserRoleType
    public let accountStatus: AccountStatusType
    public let householdIds: [String]
    public let canManageHouseholdIds: [String]
    public let familyUnitId: String?
    public let isClaimed: Bool
    public let isAdmin: Bool
    public let canSignUpForShifts: Bool
    
    public init(
        id: String,
        email: String,
        firstName: String,
        lastName: String,
        fullName: String,
        role: UserRoleType,
        accountStatus: AccountStatusType,
        householdIds: [String],
        canManageHouseholdIds: [String],
        familyUnitId: String?,
        isClaimed: Bool,
        isAdmin: Bool,
        canSignUpForShifts: Bool
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.role = role
        self.accountStatus = accountStatus
        self.householdIds = householdIds
        self.canManageHouseholdIds = canManageHouseholdIds
        self.familyUnitId = familyUnitId
        self.isClaimed = isClaimed
        self.isAdmin = isAdmin
        self.canSignUpForShifts = canSignUpForShifts
    }
}

/// Information about a household for the current user response.
public struct HouseholdInfo: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let memberCount: Int
    public let isActive: Bool
    public let linkCode: String?
    
    public init(
        id: String,
        name: String,
        memberCount: Int,
        isActive: Bool,
        linkCode: String?
    ) {
        self.id = id
        self.name = name
        self.memberCount = memberCount
        self.isActive = isActive
        self.linkCode = linkCode
    }
}

/// Response containing the current authenticated user's information.
public struct CurrentUserResponse: Sendable, Equatable {
    public let user: UserInfo
    public let households: [HouseholdInfo]
    
    public init(user: UserInfo, households: [HouseholdInfo]) {
        self.user = user
        self.households = households
    }
}
