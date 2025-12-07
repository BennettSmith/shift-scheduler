import Foundation

/// Protocol for family unit data persistence operations.
public protocol FamilyUnitRepository: Sendable {
    /// Get a family unit by ID.
    /// - Parameter id: The family unit's ID.
    /// - Returns: The family unit entity.
    func getFamilyUnit(id: String) async throws -> FamilyUnit
    
    /// Get all family units in a household.
    /// - Parameter householdId: The household's ID.
    /// - Returns: An array of family units in the household.
    func getFamilyUnitsInHousehold(householdId: String) async throws -> [FamilyUnit]
    
    /// Observe a family unit by ID for real-time updates.
    /// - Parameter id: The family unit's ID.
    /// - Returns: A stream of family unit entities.
    func observeFamilyUnit(id: String) -> AsyncThrowingStream<FamilyUnit, Error>
    
    /// Update a family unit entity.
    /// - Parameter familyUnit: The family unit entity to update.
    func updateFamilyUnit(_ familyUnit: FamilyUnit) async throws
    
    /// Create a new family unit entity.
    /// - Parameter familyUnit: The family unit entity to create.
    /// - Returns: The created family unit's ID.
    func createFamilyUnit(_ familyUnit: FamilyUnit) async throws -> String
}
