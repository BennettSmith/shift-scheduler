import Foundation

/// Info about a generated invite code.
public struct InviteCodeInfo: Sendable, Equatable {
    public let code: String
    public let role: UserRoleType
    public let expiresAt: Date?
    public let createdAt: Date
    
    public init(code: String, role: UserRoleType, expiresAt: Date?, createdAt: Date) {
        self.code = code
        self.role = role
        self.expiresAt = expiresAt
        self.createdAt = createdAt
    }
}

/// Response after generating invite codes.
public struct GenerateInviteCodesResponse: Sendable, Equatable {
    public let codes: [InviteCodeInfo]
    public let message: String
    
    public init(codes: [InviteCodeInfo], message: String) {
        self.codes = codes
        self.message = message
    }
}
