import Foundation
import Troop900Domain

/// Request to generate Scout Bucks report for end-of-season.
public struct ScoutBucksReportRequest: Sendable, Equatable {
    /// The season ID to generate report for
    public let seasonId: String
    
    /// The ID of the user making the request (must be admin)
    public let requestingUserId: String
    
    /// Scout Bucks rate per hour (e.g., $1.00 per hour)
    public let bucksPerHour: Double
    
    /// Optional minimum hours required to earn Scout Bucks
    public let minimumHours: Double?
    
    /// Whether to include scouts who didn't meet minimum hours
    public let includeIneligible: Bool
    
    public init(
        seasonId: String,
        requestingUserId: String,
        bucksPerHour: Double,
        minimumHours: Double?,
        includeIneligible: Bool
    ) {
        self.seasonId = seasonId
        self.requestingUserId = requestingUserId
        self.bucksPerHour = bucksPerHour
        self.minimumHours = minimumHours
        self.includeIneligible = includeIneligible
    }
}
