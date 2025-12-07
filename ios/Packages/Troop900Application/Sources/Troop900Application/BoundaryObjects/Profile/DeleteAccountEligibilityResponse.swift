import Foundation
import Troop900Domain

/// Response indicating whether account can be deleted and any blockers.
public struct DeleteAccountEligibilityResponse: Sendable, Equatable {
    /// Whether account can be deleted
    public let canDelete: Bool
    
    /// List of reasons preventing deletion (if any)
    public let blockers: [String]
    
    /// Number of future shift assignments
    public let futureAssignments: Int
    
    /// Whether user has active roles (e.g., committee member)
    public let hasActiveRoles: Bool
    
    /// Warning message about data retention
    public let dataRetentionWarning: String
    
    public init(
        canDelete: Bool,
        blockers: [String],
        futureAssignments: Int,
        hasActiveRoles: Bool,
        dataRetentionWarning: String
    ) {
        self.canDelete = canDelete
        self.blockers = blockers
        self.futureAssignments = futureAssignments
        self.hasActiveRoles = hasActiveRoles
        self.dataRetentionWarning = dataRetentionWarning
    }
}
