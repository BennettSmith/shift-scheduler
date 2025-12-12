import Foundation
import Troop900Domain

/// Simulated implementation of LeaderboardService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedLeaderboardService: LeaderboardService, @unchecked Sendable {
    private let attendanceRepository: AttendanceRepository
    private let assignmentRepository: AssignmentRepository
    private let userRepository: UserRepository
    private let shiftRepository: ShiftRepository
    private let lock = AsyncLock()
    
    public init(
        attendanceRepository: AttendanceRepository,
        assignmentRepository: AssignmentRepository,
        userRepository: UserRepository,
        shiftRepository: ShiftRepository
    ) {
        self.attendanceRepository = attendanceRepository
        self.assignmentRepository = assignmentRepository
        self.userRepository = userRepository
        self.shiftRepository = shiftRepository
    }
    
    public func getLeaderboard(seasonId: String?) async throws -> LeaderboardResult {
        // Get all attendance records
        let allRecords = try await attendanceRepository.getAttendanceRecordsForUser(
            userId: try UserId(unchecked: "dummy") // Would need different approach
        )
        
        // Simplified: would need to aggregate across all users
        // For stub, return empty leaderboard
        return LeaderboardResult(
            entries: [],
            seasonId: seasonId,
            generatedAt: Date()
        )
    }
    
    public func getUserStatistics(userId: UserId, seasonId: String?) async throws -> UserStatistics {
        // Get user's assignments
        let assignments = try await assignmentRepository.getAssignmentsForUser(userId: userId)
        
        // Get attendance records
        let attendanceRecords = try await attendanceRepository.getAttendanceRecordsForUser(userId: userId)
        
        // Calculate statistics
        let totalShifts = assignments.count
        let completedShifts = attendanceRecords.filter { $0.isComplete }.count
        let noShows = attendanceRecords.filter { $0.status == .noShow }.count
        let totalHours = attendanceRecords.compactMap { $0.hoursWorked }.reduce(0, +)
        
        return UserStatistics(
            userId: userId,
            totalHours: totalHours,
            totalShifts: totalShifts,
            completedShifts: completedShifts,
            noShows: noShows,
            rank: nil // Would calculate rank in real implementation
        )
    }
}
