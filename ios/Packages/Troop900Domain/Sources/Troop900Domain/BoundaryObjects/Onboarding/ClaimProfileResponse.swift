import Foundation

/// Response after claiming a profile.
public struct ClaimProfileResponse: Sendable, Equatable {
    public let success: Bool
    public let user: User?
    public let message: String
    
    public init(success: Bool, user: User?, message: String) {
        self.success = success
        self.user = user
        self.message = message
    }
}
