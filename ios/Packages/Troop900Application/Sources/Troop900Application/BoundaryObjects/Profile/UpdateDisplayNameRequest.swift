import Foundation
import Troop900Domain

/// Request to update a user's display name.
public struct UpdateDisplayNameRequest: Sendable, Equatable {
    /// The ID of the user updating their name
    public let userId: String
    
    /// The new first name
    public let firstName: String
    
    /// The new last name
    public let lastName: String
    
    public init(
        userId: String,
        firstName: String,
        lastName: String
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
    }
}
