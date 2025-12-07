import Foundation

/// Request to generate invite codes.
public struct GenerateInviteCodesRequest: Sendable, Equatable {
    public let householdId: String
    public let role: UserRole
    public let count: Int
    public let expirationDays: Int?
    
    public init(householdId: String, role: UserRole, count: Int, expirationDays: Int?) {
        self.householdId = householdId
        self.role = role
        self.count = count
        self.expirationDays = expirationDays
    }
}
