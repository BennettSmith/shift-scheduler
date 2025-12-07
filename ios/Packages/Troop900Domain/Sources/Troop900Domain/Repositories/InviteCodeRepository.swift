import Foundation

/// Protocol for invite code data persistence operations.
public protocol InviteCodeRepository: Sendable {
    /// Get an invite code by ID.
    /// - Parameter id: The invite code's ID.
    /// - Returns: The invite code entity.
    func getInviteCode(id: String) async throws -> InviteCode
    
    /// Get an invite code by the code string.
    /// - Parameter code: The invite code string.
    /// - Returns: The invite code entity, or nil if not found.
    func getInviteCodeByCode(code: String) async throws -> InviteCode?
    
    /// Get all invite codes for a household.
    /// - Parameter householdId: The household's ID.
    /// - Returns: An array of invite codes for the household.
    func getInviteCodesForHousehold(householdId: String) async throws -> [InviteCode]
    
    /// Update an invite code entity.
    /// - Parameter inviteCode: The invite code entity to update.
    func updateInviteCode(_ inviteCode: InviteCode) async throws
    
    /// Create a new invite code entity.
    /// - Parameter inviteCode: The invite code entity to create.
    /// - Returns: The created invite code's ID.
    func createInviteCode(_ inviteCode: InviteCode) async throws -> String
}
