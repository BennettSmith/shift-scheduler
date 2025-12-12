import Foundation
import Troop900Domain

/// Simulated implementation of SeasonManagementService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedSeasonManagementService: SeasonManagementService, @unchecked Sendable {
    private let seasonRepository: SeasonRepository
    private let lock = AsyncLock()
    
    public init(seasonRepository: SeasonRepository) {
        self.seasonRepository = seasonRepository
    }
    
    public func createSeason(request: CreateSeasonRequest) async throws -> String {
        let seasonId = UUID().uuidString
        let season = Season(
            id: seasonId,
            name: request.name,
            year: request.year,
            startDate: request.startDate,
            endDate: request.endDate,
            status: .draft,
            description: request.description,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await seasonRepository.createSeason(season)
        
        return seasonId
    }
    
    public func publishSeason(seasonId: String) async throws {
        var season = try await seasonRepository.getSeason(id: seasonId)
        
        // Deactivate other active seasons
        let allSeasons = try await seasonRepository.getAllSeasons()
        for existingSeason in allSeasons where existingSeason.id != seasonId && existingSeason.isActive {
            // Would need to update status - simplified for stub
        }
        
        // Update season to active
        let updatedSeason = Season(
            id: season.id,
            name: season.name,
            year: season.year,
            startDate: season.startDate,
            endDate: season.endDate,
            status: .active,
            description: season.description,
            createdAt: season.createdAt,
            updatedAt: Date()
        )
        
        try await seasonRepository.updateSeason(updatedSeason)
    }
    
    public func completeSeason(seasonId: String) async throws {
        let season = try await seasonRepository.getSeason(id: seasonId)
        
        let updatedSeason = Season(
            id: season.id,
            name: season.name,
            year: season.year,
            startDate: season.startDate,
            endDate: season.endDate,
            status: .completed,
            description: season.description,
            createdAt: season.createdAt,
            updatedAt: Date()
        )
        
        try await seasonRepository.updateSeason(updatedSeason)
    }
    
    public func archiveSeason(seasonId: String) async throws {
        let season = try await seasonRepository.getSeason(id: seasonId)
        
        let updatedSeason = Season(
            id: season.id,
            name: season.name,
            year: season.year,
            startDate: season.startDate,
            endDate: season.endDate,
            status: .archived,
            description: season.description,
            createdAt: season.createdAt,
            updatedAt: Date()
        )
        
        try await seasonRepository.updateSeason(updatedSeason)
    }
}
