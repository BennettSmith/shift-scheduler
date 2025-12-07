import Foundation
import Troop900Domain

/// Request to deactivate a family (household).
/// Deactivation cancels all future shift assignments and prevents new signups.
public struct DeactivateFamilyRequest: Sendable, Equatable {
    /// The ID of the household to deactivate
    public let householdId: String
    
    /// Reason for deactivation (optional, for record-keeping)
    public let reason: String?
    
    /// Whether to cancel all future shift assignments
    /// If false, existing assignments remain but no new signups allowed
    public let cancelFutureAssignments: Bool
    
    /// The ID of the user making the request (must be admin or household member)
    public let requestingUserId: String
    
    public init(
        householdId: String,
        reason: String?,
        cancelFutureAssignments: Bool,
        requestingUserId: String
    ) {
        self.householdId = householdId
        self.reason = reason
        self.cancelFutureAssignments = cancelFutureAssignments
        self.requestingUserId = requestingUserId
    }
}
