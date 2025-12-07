import Foundation

/// Protocol for season data persistence operations.
public protocol SeasonRepository: Sendable {
    /// Get a season by ID.
    /// - Parameter id: The season's ID.
    /// - Returns: The season entity.
    func getSeason(id: String) async throws -> Season
    
    /// Get the currently active season.
    /// - Returns: The active season entity, or nil if no season is active.
    func getActiveSeason() async throws -> Season?
    
    /// Get all seasons.
    /// - Returns: An array of all seasons.
    func getAllSeasons() async throws -> [Season]
    
    /// Observe a season by ID for real-time updates.
    /// - Parameter id: The season's ID.
    /// - Returns: A stream of season entities.
    func observeSeason(id: String) -> AsyncThrowingStream<Season, Error>
    
    /// Observe the active season for real-time updates.
    /// - Returns: A stream of the active season entity (or nil).
    func observeActiveSeason() -> AsyncThrowingStream<Season?, Error>
    
    /// Update a season entity.
    /// - Parameter season: The season entity to update.
    func updateSeason(_ season: Season) async throws
    
    /// Create a new season entity.
    /// - Parameter season: The season entity to create.
    /// - Returns: The created season's ID.
    func createSeason(_ season: Season) async throws -> String
}
