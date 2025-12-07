import Foundation
import Troop900Domain

/// Response after deactivating a family.
public struct DeactivateFamilyResponse: Sendable, Equatable {
    /// Whether the deactivation succeeded
    public let success: Bool
    
    /// Number of future assignments that were cancelled
    public let cancelledAssignmentsCount: Int
    
    /// Number of household members affected
    public let affectedMembersCount: Int
    
    /// Human-readable message describing the result
    public let message: String
    
    /// When the household was deactivated
    public let deactivatedAt: Date?
    
    public init(
        success: Bool,
        cancelledAssignmentsCount: Int,
        affectedMembersCount: Int,
        message: String,
        deactivatedAt: Date?
    ) {
        self.success = success
        self.cancelledAssignmentsCount = cancelledAssignmentsCount
        self.affectedMembersCount = affectedMembersCount
        self.message = message
        self.deactivatedAt = deactivatedAt
    }
}
