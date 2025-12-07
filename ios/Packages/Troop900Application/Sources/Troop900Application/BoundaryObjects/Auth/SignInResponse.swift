import Foundation
import Troop900Domain

/// Response after successful sign-in.
public struct SignInResponse: Sendable, Equatable {
    public let userId: String
    public let isNewUser: Bool
    public let needsOnboarding: Bool
    
    public init(userId: String, isNewUser: Bool, needsOnboarding: Bool) {
        self.userId = userId
        self.isNewUser = isNewUser
        self.needsOnboarding = needsOnboarding
    }
}
