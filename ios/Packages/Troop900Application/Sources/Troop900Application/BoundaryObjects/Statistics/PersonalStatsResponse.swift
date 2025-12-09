import Foundation

/// Response containing a user's personal statistics and achievements.
public struct PersonalStatsResponse: Sendable, Equatable {
    /// User's ID
    public let userId: String
    
    /// User's name
    public let userName: String
    
    /// Current season statistics
    public let currentSeasonStats: SeasonStats
    
    /// All-time statistics (across all seasons)
    public let allTimeStats: SeasonStats
    
    /// Current rank in the season leaderboard
    public let currentSeasonRank: Int?
    
    /// Total number of participants in season
    public let totalParticipantsInSeason: Int?
    
    /// Recent shift history (last 5-10 shifts)
    public let recentShifts: [ShiftHistoryEntry]
    
    /// Achievements and milestones
    public let achievements: [Achievement]
    
    public init(
        userId: String,
        userName: String,
        currentSeasonStats: SeasonStats,
        allTimeStats: SeasonStats,
        currentSeasonRank: Int?,
        totalParticipantsInSeason: Int?,
        recentShifts: [ShiftHistoryEntry],
        achievements: [Achievement]
    ) {
        self.userId = userId
        self.userName = userName
        self.currentSeasonStats = currentSeasonStats
        self.allTimeStats = allTimeStats
        self.currentSeasonRank = currentSeasonRank
        self.totalParticipantsInSeason = totalParticipantsInSeason
        self.recentShifts = recentShifts
        self.achievements = achievements
    }
}

/// Statistics for a specific season or all-time.
public struct SeasonStats: Sendable, Equatable {
    public let totalHours: Double
    public let totalShifts: Int
    public let completedShifts: Int
    public let noShows: Int
    public let averageHoursPerShift: Double
    
    public init(
        totalHours: Double,
        totalShifts: Int,
        completedShifts: Int,
        noShows: Int,
        averageHoursPerShift: Double
    ) {
        self.totalHours = totalHours
        self.totalShifts = totalShifts
        self.completedShifts = completedShifts
        self.noShows = noShows
        self.averageHoursPerShift = averageHoursPerShift
    }
}

/// A single shift in the user's history.
public struct ShiftHistoryEntry: Sendable, Equatable, Identifiable {
    public let id: String
    public let shiftDate: Date
    public let shiftLabel: String?
    public let hoursWorked: Double?
    public let status: AttendanceStatusType
    
    public init(
        id: String,
        shiftDate: Date,
        shiftLabel: String?,
        hoursWorked: Double?,
        status: AttendanceStatusType
    ) {
        self.id = id
        self.shiftDate = shiftDate
        self.shiftLabel = shiftLabel
        self.hoursWorked = hoursWorked
        self.status = status
    }
}

/// An achievement or milestone earned by the user.
public struct Achievement: Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let earnedAt: Date
    public let category: AchievementCategory
    
    public init(
        id: String,
        title: String,
        description: String,
        earnedAt: Date,
        category: AchievementCategory
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.earnedAt = earnedAt
        self.category = category
    }
}

/// Category of achievement.
public enum AchievementCategory: String, Sendable, Codable {
    case hours      // Hour milestones (10, 25, 50, 100 hours)
    case shifts     // Shift milestones (5, 10, 25, 50 shifts)
    case streak     // Consecutive shifts or weeks
    case special    // Special achievements (first shift, perfect attendance, etc.)
}
