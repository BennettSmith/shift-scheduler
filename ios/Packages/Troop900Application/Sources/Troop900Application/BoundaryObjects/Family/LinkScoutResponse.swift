import Foundation
import Troop900Domain

/// Response after linking a scout to an additional household.
public struct LinkScoutResponse: Sendable, Equatable {
    /// Whether the link operation succeeded
    public let success: Bool
    
    /// The ID of the household the scout was linked to
    public let householdId: String?
    
    /// Human-readable message describing the result
    public let message: String
    
    /// The scout's updated household IDs
    public let householdIds: [String]?
    
    public init(success: Bool, householdId: String?, message: String, householdIds: [String]?) {
        self.success = success
        self.householdId = householdId
        self.message = message
        self.householdIds = householdIds
    }
}
