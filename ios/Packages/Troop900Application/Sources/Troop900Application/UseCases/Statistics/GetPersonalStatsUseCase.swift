import Foundation
import Troop900Domain

/// Protocol for getting a user's personal statistics.
public protocol GetPersonalStatsUseCaseProtocol: Sendable {
    func execute(userId: String, seasonId: String?) async throws -> PersonalStatsResponse
}

/// Use case for retrieving a user's personal statistics and achievements.
/// Used by UC 36 for scouts and parents to view their volunteer history.
public final class GetPersonalStatsUseCase: GetPersonalStatsUseCaseProtocol, Sendable {
    private let attendanceRepository: AttendanceRepository
    private let assignmentRepository: AssignmentRepository
    private let userRepository: UserRepository
    private let shiftRepository: ShiftRepository
    private let leaderboardService: LeaderboardService
    
    public init(
        attendanceRepository: AttendanceRepository,
        assignmentRepository: AssignmentRepository,
        userRepository: UserRepository,
        shiftRepository: ShiftRepository,
        leaderboardService: LeaderboardService
    ) {
        self.attendanceRepository = attendanceRepository
        self.assignmentRepository = assignmentRepository
        self.userRepository = userRepository
        self.shiftRepository = shiftRepository
        self.leaderboardService = leaderboardService
    }
    
    public func execute(userId: String, seasonId: String?) async throws -> PersonalStatsResponse {
        // Get user
        let user = try await userRepository.getUser(id: userId)
        
        // Get all attendance records for user
        let allAttendanceRecords = try await attendanceRepository.getAttendanceRecordsForUser(userId: userId)
        
        // Get all assignments for user
        let allAssignments = try await assignmentRepository.getAssignmentsForUser(userId: userId)
        
        // Calculate current season stats
        let currentSeasonRecords = seasonId != nil ? filterRecordsBySeason(allAttendanceRecords, seasonId: seasonId!) : allAttendanceRecords
        let currentSeasonAssignments = seasonId != nil ? filterAssignmentsBySeason(allAssignments, seasonId: seasonId!) : allAssignments
        let currentSeasonStats = calculateSeasonStats(
            attendanceRecords: currentSeasonRecords,
            assignments: currentSeasonAssignments
        )
        
        // Calculate all-time stats
        let allTimeStats = calculateSeasonStats(
            attendanceRecords: allAttendanceRecords,
            assignments: allAssignments
        )
        
        // Get leaderboard rank for current season
        var currentSeasonRank: Int?
        var totalParticipants: Int?
        if seasonId != nil {
            let leaderboard = try? await leaderboardService.getLeaderboard(seasonId: seasonId)
            if let leaderboard = leaderboard {
                currentSeasonRank = leaderboard.entries.firstIndex(where: { $0.id == userId }).map { $0 + 1 }
                totalParticipants = leaderboard.entries.count
            }
        }
        
        // Get recent shift history (last 10 completed)
        let recentShifts = createRecentShiftsHistory(from: currentSeasonRecords)
        
        // Calculate achievements
        let achievements = calculateAchievements(
            currentSeasonStats: currentSeasonStats,
            allTimeStats: allTimeStats
        )
        
        return PersonalStatsResponse(
            userId: user.id,
            userName: user.fullName,
            currentSeasonStats: currentSeasonStats,
            allTimeStats: allTimeStats,
            currentSeasonRank: currentSeasonRank,
            totalParticipantsInSeason: totalParticipants,
            recentShifts: recentShifts,
            achievements: achievements
        )
    }
    
    private func filterRecordsBySeason(_ records: [AttendanceRecord], seasonId: String) -> [AttendanceRecord] {
        // In a real implementation, we'd filter by season dates
        // For now, return all records
        records
    }
    
    private func filterAssignmentsBySeason(_ assignments: [Assignment], seasonId: String) -> [Assignment] {
        // In a real implementation, we'd filter by season dates
        // For now, return all assignments
        assignments
    }
    
    private func calculateSeasonStats(
        attendanceRecords: [AttendanceRecord],
        assignments: [Assignment]
    ) -> SeasonStats {
        let completedRecords = attendanceRecords.filter { $0.status == .checkedOut }
        let noShowRecords = attendanceRecords.filter { $0.status == .noShow }
        
        let totalHours = completedRecords.compactMap { $0.hoursWorked }.reduce(0, +)
        let totalShifts = assignments.count
        let completedShifts = completedRecords.count
        let noShows = noShowRecords.count
        let averageHoursPerShift = completedShifts > 0 ? totalHours / Double(completedShifts) : 0
        
        return SeasonStats(
            totalHours: totalHours,
            totalShifts: totalShifts,
            completedShifts: completedShifts,
            noShows: noShows,
            averageHoursPerShift: averageHoursPerShift
        )
    }
    
    private func createRecentShiftsHistory(from records: [AttendanceRecord]) -> [ShiftHistoryEntry] {
        let sortedRecords = records.sorted { $0.checkInTime ?? Date.distantPast > $1.checkInTime ?? Date.distantPast }
        
        return Array(sortedRecords.prefix(10)).map { record in
            ShiftHistoryEntry(
                id: record.id,
                shiftDate: record.checkInTime ?? Date(),
                shiftLabel: nil, // Would need to fetch shift details
                hoursWorked: record.hoursWorked,
                status: record.status
            )
        }
    }
    
    private func calculateAchievements(
        currentSeasonStats: SeasonStats,
        allTimeStats: SeasonStats
    ) -> [Achievement] {
        var achievements: [Achievement] = []
        let now = Date()
        
        // Hour milestones
        let hourMilestones = [10.0, 25.0, 50.0, 100.0, 200.0]
        for milestone in hourMilestones where allTimeStats.totalHours >= milestone {
            achievements.append(Achievement(
                id: "hours-\(Int(milestone))",
                title: "\(Int(milestone)) Hours",
                description: "Volunteered for \(Int(milestone)) total hours",
                earnedAt: now,
                category: .hours
            ))
        }
        
        // Shift milestones
        let shiftMilestones = [5, 10, 25, 50, 100]
        for milestone in shiftMilestones where allTimeStats.completedShifts >= milestone {
            achievements.append(Achievement(
                id: "shifts-\(milestone)",
                title: "\(milestone) Shifts",
                description: "Completed \(milestone) shifts",
                earnedAt: now,
                category: .shifts
            ))
        }
        
        // First shift achievement
        if allTimeStats.completedShifts >= 1 {
            achievements.append(Achievement(
                id: "first-shift",
                title: "First Shift",
                description: "Completed your first shift",
                earnedAt: now,
                category: .special
            ))
        }
        
        return achievements
    }
}
