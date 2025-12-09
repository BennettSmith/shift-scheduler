import Foundation

/// Request to claim a pre-created profile.
public struct ClaimProfileRequest: Sendable, Equatable {
    public let claimCode: String
    public let userId: String
    
    public init(claimCode: String, userId: String) {
        self.claimCode = claimCode
        self.userId = userId
    }
}
