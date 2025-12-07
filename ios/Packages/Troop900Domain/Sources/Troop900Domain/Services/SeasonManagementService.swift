import Foundation

/// Protocol for season management remote operations (Cloud Functions).
public protocol SeasonManagementService: Sendable {
    /// Create a new season.
    /// - Parameter request: The create season request.
    /// - Returns: The created season's ID.
    func createSeason(request: CreateSeasonRequest) async throws -> String
    
    /// Publish a season (make it active).
    /// - Parameter seasonId: The season's ID.
    func publishSeason(seasonId: String) async throws
    
    /// Complete a season.
    /// - Parameter seasonId: The season's ID.
    func completeSeason(seasonId: String) async throws
    
    /// Archive a season.
    /// - Parameter seasonId: The season's ID.
    func archiveSeason(seasonId: String) async throws
}

/// Request to create a new season.
public struct CreateSeasonRequest: Sendable, Codable {
    public let name: String
    public let year: Int
    public let startDate: Date
    public let endDate: Date
    public let description: String?
    
    public init(
        name: String,
        year: Int,
        startDate: Date,
        endDate: Date,
        description: String?
    ) {
        self.name = name
        self.year = year
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
    }
}
