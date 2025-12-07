import Foundation
import Troop900Domain

/// Request to link an existing scout to an additional household.
/// Used when a scout is part of multiple households (e.g., divorced parents).
public struct LinkScoutRequest: Sendable, Equatable {
    /// The ID of the scout to link to the household
    public let scoutId: String
    
    /// The household link code provided by the other household
    public let householdLinkCode: String
    
    /// The ID of the user making the request (must be in the target household)
    public let requestingUserId: String
    
    public init(scoutId: String, householdLinkCode: String, requestingUserId: String) {
        self.scoutId = scoutId
        self.householdLinkCode = householdLinkCode
        self.requestingUserId = requestingUserId
    }
}
