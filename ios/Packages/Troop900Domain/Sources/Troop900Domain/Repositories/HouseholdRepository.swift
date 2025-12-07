import Foundation

/// Protocol for household data persistence operations.
public protocol HouseholdRepository: Sendable {
    /// Get a household by ID.
    /// - Parameter id: The household's ID.
    /// - Returns: The household entity.
    func getHousehold(id: String) async throws -> Household
    
    /// Get a household by link code.
    /// - Parameter linkCode: The household's link code.
    /// - Returns: The household entity, or nil if not found.
    func getHouseholdByLinkCode(linkCode: String) async throws -> Household?
    
    /// Get all households managed by a user.
    /// - Parameter userId: The user's ID.
    /// - Returns: An array of households the user can manage.
    func getHouseholdsManagedByUser(userId: String) async throws -> [Household]
    
    /// Observe a household by ID for real-time updates.
    /// - Parameter id: The household's ID.
    /// - Returns: A stream of household entities.
    func observeHousehold(id: String) -> AsyncThrowingStream<Household, Error>
    
    /// Update a household entity.
    /// - Parameter household: The household entity to update.
    func updateHousehold(_ household: Household) async throws
    
    /// Create a new household entity.
    /// - Parameter household: The household entity to create.
    /// - Returns: The created household's ID.
    func createHousehold(_ household: Household) async throws -> String
}
