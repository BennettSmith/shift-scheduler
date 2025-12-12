import Foundation
import Troop900Domain

/// In-memory implementation of SeasonRepository for testing and local development.
public final class InMemorySeasonRepository: SeasonRepository, @unchecked Sendable {
    private var seasons: [String: Season] = [:]
    private var activeSeasonId: String?
    private let lock = AsyncLock()
    
    public init(initialSeasons: [Season] = []) {
        for season in initialSeasons {
            seasons[season.id] = season
            if season.isActive {
                activeSeasonId = season.id
            }
        }
    }
    
    public func getSeason(id: String) async throws -> Season {
        lock.lock()
        defer { lock.unlock() }
        guard let season = seasons[id] else {
            throw DomainError.seasonNotFound
        }
        return season
    }
    
    public func getActiveSeason() async throws -> Season? {
        lock.lock()
        defer { lock.unlock() }
        guard let activeId = activeSeasonId else {
            return nil
        }
        return seasons[activeId]
    }
    
    public func getAllSeasons() async throws -> [Season] {
        lock.lock()
        defer { lock.unlock() }
        return Array(seasons.values)
    }
    
    public func observeSeason(id: String) -> AsyncThrowingStream<Season, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let season = try await getSeason(id: id)
                    continuation.yield(season)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func observeActiveSeason() -> AsyncThrowingStream<Season?, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let season = try await getActiveSeason()
                    continuation.yield(season)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func updateSeason(_ season: Season) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard seasons[season.id] != nil else {
            throw DomainError.seasonNotFound
        }
        
        seasons[season.id] = season
        
        // Update active season tracking
        if season.isActive {
            // Deactivate other seasons
            for (id, existingSeason) in seasons where id != season.id && existingSeason.isActive {
                var updated = existingSeason
                // Note: Would need to update status to non-active, but Season is immutable
                // This is a limitation of the in-memory stub
            }
            activeSeasonId = season.id
        } else if activeSeasonId == season.id {
            activeSeasonId = nil
        }
    }
    
    public func createSeason(_ season: Season) async throws -> String {
        lock.lock()
        defer { lock.unlock() }
        
        guard seasons[season.id] == nil else {
            throw DomainError.invalidInput("Season with id \(season.id) already exists")
        }
        
        seasons[season.id] = season
        if season.isActive {
            activeSeasonId = season.id
        }
        
        return season.id
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        seasons.removeAll()
        activeSeasonId = nil
    }
    
    public func getAllSeasons() -> [Season] {
        lock.lock()
        defer { lock.unlock() }
        return Array(seasons.values)
    }
    
    public func setActiveSeason(_ seasonId: String?) {
        lock.lock()
        defer { lock.unlock() }
        activeSeasonId = seasonId
    }
}
