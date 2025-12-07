import Foundation

/// Response after processing an invite code.
public struct ProcessInviteCodeResponse: Sendable, Equatable {
    public let success: Bool
    public let householdId: String?
    public let householdName: String?
    public let role: UserRole?
    public let message: String
    
    public init(
        success: Bool,
        householdId: String?,
        householdName: String?,
        role: UserRole?,
        message: String
    ) {
        self.success = success
        self.householdId = householdId
        self.householdName = householdName
        self.role = role
        self.message = message
    }
}
