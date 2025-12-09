import Foundation

/// Represents a user in the system (scout, parent, or leadership).
public struct User: Identifiable, Equatable, Sendable, Codable {
    public let id: UserId
    public let email: String
    public let firstName: String
    public let lastName: String
    public let role: UserRole
    public let accountStatus: AccountStatus
    public let households: [String]
    public let canManageHouseholds: [String]
    public let familyUnitId: String?
    public let isClaimed: Bool
    public let claimCode: String?
    public let householdLinkCode: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UserId,
        email: String,
        firstName: String,
        lastName: String,
        role: UserRole,
        accountStatus: AccountStatus,
        households: [String],
        canManageHouseholds: [String],
        familyUnitId: String?,
        isClaimed: Bool,
        claimCode: String?,
        householdLinkCode: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.accountStatus = accountStatus
        self.households = households
        self.canManageHouseholds = canManageHouseholds
        self.familyUnitId = familyUnitId
        self.isClaimed = isClaimed
        self.claimCode = claimCode
        self.householdLinkCode = householdLinkCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    public var isAdmin: Bool {
        role.isLeadership
    }
    
    public var canSignUpForShifts: Bool {
        accountStatus.canSignUpForShifts && isClaimed
    }
}
