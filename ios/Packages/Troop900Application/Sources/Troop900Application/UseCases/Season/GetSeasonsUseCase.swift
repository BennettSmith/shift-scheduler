import Foundation
import Troop900Domain

/// Protocol for getting seasons.
public protocol GetSeasonsUseCaseProtocol: Sendable {
    /// Get all seasons with optional status filter.
    func execute(statusFilter: SeasonStatusType?) async throws -> SeasonsResponse
}

/// Use case for retrieving seasons.
/// Used by admins when publishing schedules, generating reports, or viewing season history.
public final class GetSeasonsUseCase: GetSeasonsUseCaseProtocol, Sendable {
    private let seasonRepository: SeasonRepository
    
    public init(seasonRepository: SeasonRepository) {
        self.seasonRepository = seasonRepository
    }
    
    public func execute(statusFilter: SeasonStatusType?) async throws -> SeasonsResponse {
        let allSeasons = try await seasonRepository.getAllSeasons()
        let activeSeason = try await seasonRepository.getActiveSeason()
        
        // Filter by status if requested
        let filteredSeasons: [Season]
        if let filter = statusFilter {
            let domainStatus = filter.toDomain()
            filteredSeasons = allSeasons.filter { $0.status == domainStatus }
        } else {
            filteredSeasons = allSeasons
        }
        
        // Convert to boundary types
        let seasonSummaries = filteredSeasons
            .map { SeasonSummary(from: $0) }
            .sorted { $0.startDate > $1.startDate } // Most recent first
        
        let activeSeasonSummary = activeSeason.map { SeasonSummary(from: $0) }
        
        return SeasonsResponse(
            seasons: seasonSummaries,
            activeSeason: activeSeasonSummary
        )
    }
}

// MARK: - SeasonStatusType to Domain conversion

private extension SeasonStatusType {
    func toDomain() -> SeasonStatus {
        switch self {
        case .draft:
            return .draft
        case .active:
            return .active
        case .completed:
            return .completed
        case .archived:
            return .archived
        }
    }
}
