import Foundation

/// Protocol for family management remote operations (Cloud Functions).
public protocol FamilyManagementService: Sendable {
    /// Add a new family member to a household.
    /// - Parameter request: The request containing family member details.
    /// - Returns: The result of adding the family member.
    func addFamilyMember(request: AddFamilyMemberRequest) async throws -> AddFamilyMemberResult
    
    /// Link a scout to a household using a household link code.
    /// - Parameters:
    ///   - scoutId: The scout's user ID.
    ///   - linkCode: The household link code.
    /// - Returns: The result of linking the scout.
    func linkScoutToHousehold(scoutId: String, linkCode: String) async throws -> LinkScoutResult
    
    /// Regenerate a household's link code.
    /// - Parameter householdId: The household's ID.
    /// - Returns: The new link code.
    func regenerateHouseholdLinkCode(householdId: String) async throws -> String
    
    /// Deactivate a family unit or household member.
    /// - Parameter request: The deactivation request.
    func deactivateFamily(request: DeactivateFamilyRequest) async throws
}

/// Request to add a new family member.
public struct AddFamilyMemberRequest: Sendable, Codable {
    public let householdId: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let role: UserRole
    public let familyUnitId: String?
    
    public init(
        householdId: String,
        firstName: String,
        lastName: String,
        email: String,
        role: UserRole,
        familyUnitId: String?
    ) {
        self.householdId = householdId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.role = role
        self.familyUnitId = familyUnitId
    }
}

/// Result of adding a family member.
public struct AddFamilyMemberResult: Sendable, Codable {
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

/// Result of linking a scout to a household.
public struct LinkScoutResult: Sendable, Codable {
    public let success: Bool
    public let householdId: String?
    public let message: String
    
    public init(success: Bool, householdId: String?, message: String) {
        self.success = success
        self.householdId = householdId
        self.message = message
    }
}

/// Request to deactivate a family unit or member.
public struct DeactivateFamilyRequest: Sendable, Codable {
    public let userId: String
    public let reason: String?
    
    public init(userId: String, reason: String?) {
        self.userId = userId
        self.reason = reason
    }
}
