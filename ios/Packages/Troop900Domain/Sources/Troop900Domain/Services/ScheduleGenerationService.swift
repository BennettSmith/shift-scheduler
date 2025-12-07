import Foundation

/// Protocol for schedule generation remote operations (Cloud Functions).
public protocol ScheduleGenerationService: Sendable {
    /// Generate a schedule for a season.
    /// - Parameter request: The schedule generation request.
    /// - Returns: The schedule generation result.
    func generateSchedule(request: ScheduleGenerationRequest) async throws -> ScheduleGenerationResult
    
    /// Publish a generated schedule (make shifts visible to users).
    /// - Parameters:
    ///   - seasonId: The season's ID.
    ///   - shiftIds: The IDs of shifts to publish.
    func publishSchedule(seasonId: String, shiftIds: [String]) async throws
}

/// Request to generate a schedule.
public struct ScheduleGenerationRequest: Sendable, Codable {
    public let seasonId: String
    public let startDate: Date
    public let endDate: Date
    public let templateIds: [String]
    public let daysOfWeek: [Int] // 1-7 (Sunday-Saturday)
    
    public init(
        seasonId: String,
        startDate: Date,
        endDate: Date,
        templateIds: [String],
        daysOfWeek: [Int]
    ) {
        self.seasonId = seasonId
        self.startDate = startDate
        self.endDate = endDate
        self.templateIds = templateIds
        self.daysOfWeek = daysOfWeek
    }
}

/// Result of schedule generation.
public struct ScheduleGenerationResult: Sendable, Codable {
    public let success: Bool
    public let shiftIds: [String]
    public let message: String
    
    public init(success: Bool, shiftIds: [String], message: String) {
        self.success = success
        self.shiftIds = shiftIds
        self.message = message
    }
}
