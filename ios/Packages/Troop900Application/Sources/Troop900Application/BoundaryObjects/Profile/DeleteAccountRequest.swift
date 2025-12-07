import Foundation
import Troop900Domain

/// Request to delete a user's account.
/// This is a soft delete - data is marked inactive but not immediately removed.
public struct DeleteAccountRequest: Sendable, Equatable {
    /// The ID of the user requesting deletion
    public let userId: String
    
    /// Reason for deletion (optional)
    public let reason: String?
    
    /// Confirmation that user understands implications
    public let confirmed: Bool
    
    public init(
        userId: String,
        reason: String?,
        confirmed: Bool
    ) {
        self.userId = userId
        self.reason = reason
        self.confirmed = confirmed
    }
}
