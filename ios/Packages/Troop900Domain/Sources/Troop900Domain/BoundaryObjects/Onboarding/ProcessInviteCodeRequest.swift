import Foundation

/// Request to process an invite code.
public struct ProcessInviteCodeRequest: Sendable, Equatable {
    public let code: String
    public let userId: String
    
    public init(code: String, userId: String) {
        self.code = code
        self.userId = userId
    }
}
