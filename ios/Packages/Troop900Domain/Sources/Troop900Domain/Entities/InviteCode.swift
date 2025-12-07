import Foundation

/// Represents an invite code for new users to join the system.
public struct InviteCode: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let code: String
    public let householdId: String
    public let role: UserRole
    public let createdBy: String
    public let usedBy: String?
    public let usedAt: Date?
    public let expiresAt: Date?
    public let isUsed: Bool
    public let createdAt: Date
    
    public init(
        id: String,
        code: String,
        householdId: String,
        role: UserRole,
        createdBy: String,
        usedBy: String?,
        usedAt: Date?,
        expiresAt: Date?,
        isUsed: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.code = code
        self.householdId = householdId
        self.role = role
        self.createdBy = createdBy
        self.usedBy = usedBy
        self.usedAt = usedAt
        self.expiresAt = expiresAt
        self.isUsed = isUsed
        self.createdAt = createdAt
    }
    
    public var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    public var isValid: Bool {
        !isUsed && !isExpired
    }
}
