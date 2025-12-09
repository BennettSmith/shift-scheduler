import Foundation

/// Response containing Scout Bucks report for end-of-season.
public struct ScoutBucksReportResponse: Sendable, Equatable {
    /// The season ID this report is for
    public let seasonId: String
    
    /// Season name or label
    public let seasonName: String
    
    /// Date range of the season
    public let startDate: Date
    public let endDate: Date
    
    /// Scout Bucks rate used for calculation
    public let bucksPerHour: Double
    
    /// Minimum hours requirement (if any)
    public let minimumHours: Double?
    
    /// Individual Scout Bucks entries
    public let entries: [ScoutBucksEntry]
    
    /// Total Scout Bucks awarded across all scouts
    public let totalBucksAwarded: Double
    
    /// Total hours worked by all scouts
    public let totalHoursWorked: Double
    
    /// Number of scouts who qualified for Scout Bucks
    public let qualifiedScouts: Int
    
    /// Number of scouts who didn't meet minimum hours
    public let ineligibleScouts: Int
    
    /// When the report was generated
    public let generatedAt: Date
    
    public init(
        seasonId: String,
        seasonName: String,
        startDate: Date,
        endDate: Date,
        bucksPerHour: Double,
        minimumHours: Double?,
        entries: [ScoutBucksEntry],
        totalBucksAwarded: Double,
        totalHoursWorked: Double,
        qualifiedScouts: Int,
        ineligibleScouts: Int,
        generatedAt: Date
    ) {
        self.seasonId = seasonId
        self.seasonName = seasonName
        self.startDate = startDate
        self.endDate = endDate
        self.bucksPerHour = bucksPerHour
        self.minimumHours = minimumHours
        self.entries = entries
        self.totalBucksAwarded = totalBucksAwarded
        self.totalHoursWorked = totalHoursWorked
        self.qualifiedScouts = qualifiedScouts
        self.ineligibleScouts = ineligibleScouts
        self.generatedAt = generatedAt
    }
}

/// A single scout's entry in the Scout Bucks report.
public struct ScoutBucksEntry: Sendable, Equatable, Identifiable {
    /// Scout's user ID
    public let id: String
    
    /// Scout's name
    public let scoutName: String
    
    /// Total hours worked
    public let totalHours: Double
    
    /// Total shifts completed
    public let totalShifts: Int
    
    /// Scout Bucks earned
    public let bucksEarned: Double
    
    /// Whether scout met minimum hours requirement
    public let isEligible: Bool
    
    /// Rank by hours (1 = most hours)
    public let rank: Int
    
    public init(
        id: String,
        scoutName: String,
        totalHours: Double,
        totalShifts: Int,
        bucksEarned: Double,
        isEligible: Bool,
        rank: Int
    ) {
        self.id = id
        self.scoutName = scoutName
        self.totalHours = totalHours
        self.totalShifts = totalShifts
        self.bucksEarned = bucksEarned
        self.isEligible = isEligible
        self.rank = rank
    }
}
