import Foundation

/// Protocol for leaderboard remote operations (Cloud Functions).
public protocol LeaderboardService: Sendable {
    /// Get the leaderboard for a season.
    /// - Parameter seasonId: The season's ID, or nil for all-time leaderboard.
    /// - Returns: The leaderboard result.
    func getLeaderboard(seasonId: String?) async throws -> LeaderboardResult
    
    /// Get leaderboard statistics for a specific user.
    /// - Parameters:
    ///   - userId: The user's ID.
    ///   - seasonId: The season's ID, or nil for all-time statistics.
    /// - Returns: The user's statistics.
    func getUserStatistics(userId: String, seasonId: String?) async throws -> UserStatistics
}

/// Result containing leaderboard data.
public struct LeaderboardResult: Sendable, Codable {
    public let entries: [LeaderboardEntry]
    public let seasonId: String?
    public let generatedAt: Date
    
    public init(entries: [LeaderboardEntry], seasonId: String?, generatedAt: Date) {
        self.entries = entries
        self.seasonId = seasonId
        self.generatedAt = generatedAt
    }
}

/// A single entry in the leaderboard.
public struct LeaderboardEntry: Sendable, Codable, Identifiable {
    public let id: String // User ID
    public let name: String
    public let totalHours: Double
    public let totalShifts: Int
    public let rank: Int
    
    public init(id: String, name: String, totalHours: Double, totalShifts: Int, rank: Int) {
        self.id = id
        self.name = name
        self.totalHours = totalHours
        self.totalShifts = totalShifts
        self.rank = rank
    }
}

/// Statistics for a specific user.
public struct UserStatistics: Sendable, Codable {
    public let userId: String
    public let totalHours: Double
    public let totalShifts: Int
    public let completedShifts: Int
    public let noShows: Int
    public let rank: Int?
    
    public init(
        userId: String,
        totalHours: Double,
        totalShifts: Int,
        completedShifts: Int,
        noShows: Int,
        rank: Int?
    ) {
        self.userId = userId
        self.totalHours = totalHours
        self.totalShifts = totalShifts
        self.completedShifts = completedShifts
        self.noShows = noShows
        self.rank = rank
    }
}
