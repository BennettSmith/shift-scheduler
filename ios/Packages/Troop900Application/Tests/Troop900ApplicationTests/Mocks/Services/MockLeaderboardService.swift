import Foundation
import Troop900Domain

/// Mock implementation of LeaderboardService for testing
public final class MockLeaderboardService: LeaderboardService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var getLeaderboardResult: Result<LeaderboardResult, Error>?
    public var getUserStatisticsResult: Result<UserStatistics, Error>?
    
    /// Pre-configured leaderboard entries
    public var leaderboardEntries: [LeaderboardEntry] = []
    
    /// Pre-configured user statistics by user ID
    public var userStatisticsById: [String: UserStatistics] = [:]
    
    // MARK: - Call Tracking
    
    public var getLeaderboardCallCount = 0
    public var getLeaderboardCalledWith: [String?] = []
    
    public var getUserStatisticsCallCount = 0
    public var getUserStatisticsCalledWith: [(userId: String, seasonId: String?)] = []
    
    // MARK: - LeaderboardService Implementation
    
    public func getLeaderboard(seasonId: String?) async throws -> LeaderboardResult {
        getLeaderboardCallCount += 1
        getLeaderboardCalledWith.append(seasonId)
        
        if let result = getLeaderboardResult {
            return try result.get()
        }
        
        // Return pre-configured entries or default
        return LeaderboardResult(
            entries: leaderboardEntries,
            seasonId: seasonId,
            generatedAt: Date()
        )
    }
    
    public func getUserStatistics(userId: String, seasonId: String?) async throws -> UserStatistics {
        getUserStatisticsCallCount += 1
        getUserStatisticsCalledWith.append((userId, seasonId))
        
        if let result = getUserStatisticsResult {
            return try result.get()
        }
        
        // Return pre-configured stats or default
        if let stats = userStatisticsById[userId] {
            return stats
        }
        
        return UserStatistics(
            userId: userId,
            totalHours: 0,
            totalShifts: 0,
            completedShifts: 0,
            noShows: 0,
            rank: nil
        )
    }
    
    // MARK: - Test Helpers
    
    /// Adds a leaderboard entry
    public func addLeaderboardEntry(_ entry: LeaderboardEntry) {
        leaderboardEntries.append(entry)
    }
    
    /// Adds user statistics
    public func addUserStatistics(_ stats: UserStatistics) {
        userStatisticsById[stats.userId] = stats
    }
    
    /// Creates a default leaderboard entry
    public static func createLeaderboardEntry(
        id: String = "user-1",
        name: String = "Test User",
        totalHours: Double = 10.0,
        totalShifts: Int = 3,
        rank: Int = 1
    ) -> LeaderboardEntry {
        LeaderboardEntry(
            id: id,
            name: name,
            totalHours: totalHours,
            totalShifts: totalShifts,
            rank: rank
        )
    }
    
    /// Resets all state and call tracking
    public func reset() {
        getLeaderboardResult = nil
        getUserStatisticsResult = nil
        leaderboardEntries.removeAll()
        userStatisticsById.removeAll()
        getLeaderboardCallCount = 0
        getLeaderboardCalledWith.removeAll()
        getUserStatisticsCallCount = 0
        getUserStatisticsCalledWith.removeAll()
    }
}
