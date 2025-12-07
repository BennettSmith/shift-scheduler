import Foundation
import Troop900Domain

/// Protocol for getting season-wide statistics.
public protocol GetSeasonStatisticsUseCaseProtocol: Sendable {
    func execute(seasonId: String, requestingUserId: String) async throws -> SeasonStatisticsResponse
}

/// Use case for retrieving comprehensive season statistics.
/// Used by UC 39 for committee to view season metrics and trends.
public final class GetSeasonStatisticsUseCase: GetSeasonStatisticsUseCaseProtocol, Sendable {
    private let attendanceRepository: AttendanceRepository
    private let assignmentRepository: AssignmentRepository
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    private let shiftRepository: ShiftRepository
    private let leaderboardService: LeaderboardService
    
    public init(
        attendanceRepository: AttendanceRepository,
        assignmentRepository: AssignmentRepository,
        userRepository: UserRepository,
        householdRepository: HouseholdRepository,
        shiftRepository: ShiftRepository,
        leaderboardService: LeaderboardService
    ) {
        self.attendanceRepository = attendanceRepository
        self.assignmentRepository = assignmentRepository
        self.userRepository = userRepository
        self.householdRepository = householdRepository
        self.shiftRepository = shiftRepository
        self.leaderboardService = leaderboardService
    }
    
    public func execute(seasonId: String, requestingUserId: String) async throws -> SeasonStatisticsResponse {
        // Validate requesting user has permission (must be committee)
        let requestingUser = try await userRepository.getUser(id: requestingUserId)
        guard requestingUser.role.isLeadership else {
            throw DomainError.unauthorized
        }
        
        // For now, use placeholder dates (would fetch from season entity in real implementation)
        let seasonName = "2024 Christmas Tree Season"
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 60, to: startDate)!
        
        // Get all shifts for the season
        let shifts = try await shiftRepository.getShiftsForDateRange(start: startDate, end: endDate)
        
        // Get all assignments for the season
        // Note: In real implementation, we'd have a method to get assignments by season
        // For now, we'll approximate by getting assignments for all users
        
        // Get leaderboard which gives us volunteer data
        let leaderboard = try await leaderboardService.getLeaderboard(seasonId: seasonId)
        
        // Calculate participation stats
        let totalVolunteers = leaderboard.entries.count
        let activeVolunteers = leaderboard.entries.filter { $0.totalShifts > 0 }.count
        
        let participation = ParticipationStats(
            totalFamilies: 0, // Would need to query households
            activeFamilies: 0,
            totalVolunteers: totalVolunteers,
            activeVolunteers: activeVolunteers,
            totalScouts: 0, // Would need role filtering
            totalParents: 0
        )
        
        // Calculate shift stats
        let completedShifts = shifts.filter { $0.status == .completed }.count
        let totalSlots = shifts.reduce(0) { $0 + $1.requiredScouts + $1.requiredParents }
        let filledSlots = shifts.reduce(0) { $0 + $1.currentScouts + $1.currentParents }
        let averageStaffingRate = totalSlots > 0 ? (Double(filledSlots) / Double(totalSlots)) * 100 : 0
        
        let shiftStats = ShiftStats(
            totalShifts: shifts.count,
            completedShifts: completedShifts,
            totalSlots: totalSlots,
            filledSlots: filledSlots,
            averageStaffingRate: averageStaffingRate
        )
        
        // Calculate hour stats
        let totalHours = leaderboard.entries.reduce(0) { $0 + $1.totalHours }
        let averageHoursPerVolunteer = totalVolunteers > 0 ? totalHours / Double(totalVolunteers) : 0
        
        let hourStats = HourStats(
            totalHours: totalHours,
            scoutHours: 0, // Would need role-based calculation
            parentHours: 0,
            averageHoursPerVolunteer: averageHoursPerVolunteer,
            averageHoursPerFamily: 0 // Would need family aggregation
        )
        
        // Get top volunteers (from leaderboard)
        let topVolunteers = Array(leaderboard.entries.prefix(10)).map { entry in
            TopVolunteerEntry(
                id: entry.id,
                name: entry.name,
                role: .scout, // Would need to fetch actual role
                totalHours: entry.totalHours,
                totalShifts: entry.totalShifts,
                rank: entry.rank
            )
        }
        
        // Top families - placeholder
        let topFamilies: [TopFamilyEntry] = []
        
        // Attendance stats - placeholder
        let attendanceStats = AttendanceStats(
            totalAssignments: 0,
            completedAssignments: 0,
            noShows: 0,
            completionRate: 0
        )
        
        return SeasonStatisticsResponse(
            seasonId: seasonId,
            seasonName: seasonName,
            startDate: startDate,
            endDate: endDate,
            participation: participation,
            shifts: shiftStats,
            hours: hourStats,
            topVolunteers: topVolunteers,
            topFamilies: topFamilies,
            attendance: attendanceStats
        )
    }
}
