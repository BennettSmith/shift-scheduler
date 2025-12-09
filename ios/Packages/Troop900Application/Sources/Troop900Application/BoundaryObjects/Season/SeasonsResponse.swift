import Foundation

/// Summary information about a season for list displays.
public struct SeasonSummary: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let year: Int
    public let startDate: Date
    public let endDate: Date
    public let status: SeasonStatusType
    public let description: String?
    public let isActive: Bool
    
    public init(
        id: String,
        name: String,
        year: Int,
        startDate: Date,
        endDate: Date,
        status: SeasonStatusType,
        description: String?,
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.year = year
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.description = description
        self.isActive = isActive
    }
}

/// Response containing available seasons.
public struct SeasonsResponse: Sendable, Equatable {
    public let seasons: [SeasonSummary]
    public let activeSeason: SeasonSummary?
    
    public init(seasons: [SeasonSummary], activeSeason: SeasonSummary?) {
        self.seasons = seasons
        self.activeSeason = activeSeason
    }
}
