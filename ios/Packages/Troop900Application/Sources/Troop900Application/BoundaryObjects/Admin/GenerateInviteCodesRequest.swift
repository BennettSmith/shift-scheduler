import Foundation

/// Request to generate invite codes.
public struct GenerateInviteCodesRequest: Sendable, Equatable {
    public let householdId: String
    public let role: UserRoleType
    public let count: Int
    public let expirationDays: Int?
    
    public init(householdId: String, role: UserRoleType, count: Int, expirationDays: Int?) {
        self.householdId = householdId
        self.role = role
        self.count = count
        self.expirationDays = expirationDays
    }
}
