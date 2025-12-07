import Foundation
import Troop900Domain

/// Response after adding a family member.
public struct AddFamilyMemberResponse: Sendable, Equatable {
    public let success: Bool
    public let userId: String?
    public let claimCode: String?
    public let message: String
    
    public init(success: Bool, userId: String?, claimCode: String?, message: String) {
        self.success = success
        self.userId = userId
        self.claimCode = claimCode
        self.message = message
    }
}
