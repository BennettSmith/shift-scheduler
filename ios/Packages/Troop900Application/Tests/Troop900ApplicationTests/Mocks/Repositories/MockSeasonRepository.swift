import Foundation
import Troop900Domain

/// Mock implementation of SeasonRepository for testing
public final class MockSeasonRepository: SeasonRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Seasons stored by ID
    public var seasonsById: [String: Season] = [:]
    
    /// The currently active season
    public var activeSeason: Season?
    
    // MARK: - Configurable Results
    
    public var getSeasonResult: Result<Season, Error>?
    public var getActiveSeasonResult: Result<Season?, Error>?
    public var getAllSeasonsResult: Result<[Season], Error>?
    public var createSeasonResult: Result<String, Error>?
    public var updateSeasonError: Error?
    
    // MARK: - Call Tracking
    
    public var getSeasonCallCount = 0
    public var getSeasonCalledWith: [String] = []
    
    public var getActiveSeasonCallCount = 0
    
    public var getAllSeasonsCallCount = 0
    
    public var createSeasonCallCount = 0
    public var createSeasonCalledWith: [Season] = []
    
    public var updateSeasonCallCount = 0
    public var updateSeasonCalledWith: [Season] = []
    
    // MARK: - SeasonRepository Implementation
    
    public func getSeason(id: String) async throws -> Season {
        getSeasonCallCount += 1
        getSeasonCalledWith.append(id)
        
        if let result = getSeasonResult {
            return try result.get()
        }
        
        guard let season = seasonsById[id] else {
            throw DomainError.seasonNotFound
        }
        return season
    }
    
    public func getActiveSeason() async throws -> Season? {
        getActiveSeasonCallCount += 1
        
        if let result = getActiveSeasonResult {
            return try result.get()
        }
        
        // Use explicitly set activeSeason or find from storage
        if let active = activeSeason {
            return active
        }
        return seasonsById.values.first { $0.status == .active }
    }
    
    public func getAllSeasons() async throws -> [Season] {
        getAllSeasonsCallCount += 1
        
        if let result = getAllSeasonsResult {
            return try result.get()
        }
        
        return Array(seasonsById.values).sorted { $0.startDate > $1.startDate }
    }
    
    public func observeSeason(id: String) -> AsyncThrowingStream<Season, Error> {
        AsyncThrowingStream { continuation in
            if let season = seasonsById[id] {
                continuation.yield(season)
            }
            continuation.finish()
        }
    }
    
    public func observeActiveSeason() -> AsyncThrowingStream<Season?, Error> {
        AsyncThrowingStream { continuation in
            let active = activeSeason ?? seasonsById.values.first { $0.status == .active }
            continuation.yield(active)
            continuation.finish()
        }
    }
    
    public func updateSeason(_ season: Season) async throws {
        updateSeasonCallCount += 1
        updateSeasonCalledWith.append(season)
        
        if let error = updateSeasonError {
            throw error
        }
        
        seasonsById[season.id] = season
        
        // Update active season reference if this is now active
        if season.status == .active {
            activeSeason = season
        } else if activeSeason?.id == season.id {
            activeSeason = nil
        }
    }
    
    public func createSeason(_ season: Season) async throws -> String {
        createSeasonCallCount += 1
        createSeasonCalledWith.append(season)
        
        if let result = createSeasonResult {
            return try result.get()
        }
        
        seasonsById[season.id] = season
        
        if season.status == .active {
            activeSeason = season
        }
        
        return season.id
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        seasonsById.removeAll()
        activeSeason = nil
        getSeasonResult = nil
        getActiveSeasonResult = nil
        getAllSeasonsResult = nil
        createSeasonResult = nil
        updateSeasonError = nil
        getSeasonCallCount = 0
        getSeasonCalledWith.removeAll()
        getActiveSeasonCallCount = 0
        getAllSeasonsCallCount = 0
        createSeasonCallCount = 0
        createSeasonCalledWith.removeAll()
        updateSeasonCallCount = 0
        updateSeasonCalledWith.removeAll()
    }
}
