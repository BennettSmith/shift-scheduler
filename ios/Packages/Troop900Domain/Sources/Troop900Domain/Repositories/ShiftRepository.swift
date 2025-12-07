import Foundation

/// Protocol for shift data persistence operations.
public protocol ShiftRepository: Sendable {
    /// Get a shift by ID.
    /// - Parameter id: The shift's ID.
    /// - Returns: The shift entity.
    func getShift(id: String) async throws -> Shift
    
    /// Get all shifts within a date range.
    /// - Parameters:
    ///   - start: The start date.
    ///   - end: The end date.
    /// - Returns: An array of shifts in the date range.
    func getShiftsForDateRange(start: Date, end: Date) async throws -> [Shift]
    
    /// Get all shifts for a season.
    /// - Parameter seasonId: The season's ID.
    /// - Returns: An array of shifts in the season.
    func getShiftsForSeason(seasonId: String) async throws -> [Shift]
    
    /// Observe a shift by ID for real-time updates.
    /// - Parameter id: The shift's ID.
    /// - Returns: A stream of shift entities.
    func observeShift(id: String) -> AsyncThrowingStream<Shift, Error>
    
    /// Observe all shifts within a date range for real-time updates.
    /// - Parameters:
    ///   - start: The start date.
    ///   - end: The end date.
    /// - Returns: A stream of shift arrays.
    func observeShiftsForDateRange(start: Date, end: Date) -> AsyncThrowingStream<[Shift], Error>
    
    /// Update a shift entity.
    /// - Parameter shift: The shift entity to update.
    func updateShift(_ shift: Shift) async throws
    
    /// Create a new shift entity.
    /// - Parameter shift: The shift entity to create.
    /// - Returns: The created shift's ID.
    func createShift(_ shift: Shift) async throws -> String
    
    /// Delete a shift by ID.
    /// - Parameter id: The shift's ID.
    func deleteShift(id: String) async throws
}
