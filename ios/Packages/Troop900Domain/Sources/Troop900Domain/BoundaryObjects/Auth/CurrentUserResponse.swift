import Foundation

/// Response containing the current authenticated user's information.
public struct CurrentUserResponse: Sendable, Equatable {
    public let user: User
    public let households: [Household]
    
    public init(user: User, households: [Household]) {
        self.user = user
        self.households = households
    }
}
