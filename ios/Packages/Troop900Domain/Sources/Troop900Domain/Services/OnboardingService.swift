import Foundation

/// Protocol for onboarding-related remote operations (Cloud Functions).
public protocol OnboardingService: Sendable {
    /// Process an invite code to join a household.
    /// - Parameters:
    ///   - code: The invite code.
    ///   - userId: The user's ID.
    /// - Returns: The result of processing the invite code.
    func processInviteCode(code: String, userId: UserId) async throws -> InviteCodeResult
    
    /// Claim a pre-created user profile.
    /// - Parameters:
    ///   - claimCode: The claim code.
    ///   - userId: The authenticated user's ID.
    /// - Returns: The result of claiming the profile.
    func claimProfile(claimCode: String, userId: UserId) async throws -> ClaimProfileResult
}

/// Result of processing an invite code.
public struct InviteCodeResult: Sendable {
    public let success: Bool
    public let householdId: String?
    public let userRole: UserRole?
    public let message: String
    
    public init(success: Bool, householdId: String?, userRole: UserRole?, message: String) {
        self.success = success
        self.householdId = householdId
        self.userRole = userRole
        self.message = message
    }
}

/// Result of claiming a profile.
public struct ClaimProfileResult: Sendable {
    public let success: Bool
    public let userId: UserId?
    public let message: String
    
    public init(success: Bool, userId: UserId?, message: String) {
        self.success = success
        self.userId = userId
        self.message = message
    }
}
