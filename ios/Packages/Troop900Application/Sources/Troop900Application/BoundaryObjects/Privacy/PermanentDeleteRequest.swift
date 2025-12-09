import Foundation

/// Request to permanently delete all user data (right to be forgotten).
/// This is an admin-only operation for GDPR/CCPA compliance.
public struct PermanentDeleteRequest: Sendable, Equatable {
    /// The ID of the user whose data will be permanently deleted
    public let userId: String
    
    /// The ID of the admin performing the deletion
    public let adminUserId: String
    
    /// Reason for permanent deletion
    public let reason: String
    
    /// Confirmation that admin understands data will be permanently deleted
    public let confirmed: Bool
    
    /// User's written request (e.g., email, ticket number)
    public let userRequestReference: String?
    
    public init(
        userId: String,
        adminUserId: String,
        reason: String,
        confirmed: Bool,
        userRequestReference: String?
    ) {
        self.userId = userId
        self.adminUserId = adminUserId
        self.reason = reason
        self.confirmed = confirmed
        self.userRequestReference = userRequestReference
    }
}
