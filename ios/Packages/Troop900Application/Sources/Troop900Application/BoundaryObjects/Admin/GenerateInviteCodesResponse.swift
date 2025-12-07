import Foundation
import Troop900Domain

/// Response after generating invite codes.
public struct GenerateInviteCodesResponse: Sendable, Equatable {
    public let codes: [InviteCode]
    public let message: String
    
    public init(codes: [InviteCode], message: String) {
        self.codes = codes
        self.message = message
    }
}
