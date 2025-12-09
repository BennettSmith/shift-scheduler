import Foundation

/// Claimed user profile info for the claim profile response.
public struct ClaimedProfileInfo: Sendable, Equatable {
    public let userId: String
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let role: UserRoleType
    public let householdIds: [String]
    
    public init(
        userId: String,
        firstName: String,
        lastName: String,
        fullName: String,
        role: UserRoleType,
        householdIds: [String]
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.role = role
        self.householdIds = householdIds
    }
}

/// Response after claiming a profile.
public struct ClaimProfileResponse: Sendable, Equatable {
    public let success: Bool
    public let profile: ClaimedProfileInfo?
    public let message: String
    
    public init(success: Bool, profile: ClaimedProfileInfo?, message: String) {
        self.success = success
        self.profile = profile
        self.message = message
    }
}
