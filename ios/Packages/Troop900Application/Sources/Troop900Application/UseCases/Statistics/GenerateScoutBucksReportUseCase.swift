import Foundation
import Troop900Domain

/// Protocol for generating Scout Bucks report.
public protocol GenerateScoutBucksReportUseCaseProtocol: Sendable {
    func execute(request: ScoutBucksReportRequest) async throws -> ScoutBucksReportResponse
}

/// Use case for generating end-of-season Scout Bucks report.
/// Used by UC 40 for committee to calculate Scout Bucks earnings.
public final class GenerateScoutBucksReportUseCase: GenerateScoutBucksReportUseCaseProtocol, Sendable {
    private let attendanceRepository: AttendanceRepository
    private let userRepository: UserRepository
    private let leaderboardService: LeaderboardService
    
    public init(
        attendanceRepository: AttendanceRepository,
        userRepository: UserRepository,
        leaderboardService: LeaderboardService
    ) {
        self.attendanceRepository = attendanceRepository
        self.userRepository = userRepository
        self.leaderboardService = leaderboardService
    }
    
    public func execute(request: ScoutBucksReportRequest) async throws -> ScoutBucksReportResponse {
        // Validate and convert boundary ID to domain ID type
        let requestingUserId = try UserId(request.requestingUserId)
        
        // Validate requesting user has permission (must be committee)
        let requestingUser = try await userRepository.getUser(id: requestingUserId)
        guard requestingUser.role.isLeadership else {
            throw DomainError.unauthorized
        }
        
        // Get leaderboard for the season (contains volunteer hours)
        let leaderboard = try await leaderboardService.getLeaderboard(seasonId: request.seasonId)
        
        // Filter to only scouts
        var scoutEntries: [ScoutBucksEntry] = []
        var totalBucksAwarded = 0.0
        var totalHoursWorked = 0.0
        var qualifiedCount = 0
        var ineligibleCount = 0
        
        for (index, entry) in leaderboard.entries.enumerated() {
            // In real implementation, we'd check if user is a scout
            // For now, we'll include all users
            let user = try? await userRepository.getUser(id: entry.id)
            guard let user = user, user.role == .scout else {
                continue
            }
            
            let hours = entry.totalHours
            let shifts = entry.totalShifts
            let isEligible: Bool
            
            // Check if scout meets minimum hours requirement
            if let minHours = request.minimumHours {
                isEligible = hours >= minHours
            } else {
                isEligible = true
            }
            
            // Calculate Scout Bucks
            let bucksEarned = isEligible ? hours * request.bucksPerHour : 0.0
            
            // Only include if eligible or if includeIneligible is true
            if isEligible || request.includeIneligible {
                scoutEntries.append(ScoutBucksEntry(
                    id: user.id.value,
                    scoutName: user.fullName,
                    totalHours: hours,
                    totalShifts: shifts,
                    bucksEarned: bucksEarned,
                    isEligible: isEligible,
                    rank: index + 1
                ))
                
                if isEligible {
                    totalBucksAwarded += bucksEarned
                    qualifiedCount += 1
                } else {
                    ineligibleCount += 1
                }
                
                totalHoursWorked += hours
            }
        }
        
        // Sort entries by hours (rank)
        scoutEntries.sort { $0.totalHours > $1.totalHours }
        
        // Re-assign ranks after sorting
        for (index, _) in scoutEntries.enumerated() {
            scoutEntries[index] = ScoutBucksEntry(
                id: scoutEntries[index].id,
                scoutName: scoutEntries[index].scoutName,
                totalHours: scoutEntries[index].totalHours,
                totalShifts: scoutEntries[index].totalShifts,
                bucksEarned: scoutEntries[index].bucksEarned,
                isEligible: scoutEntries[index].isEligible,
                rank: index + 1
            )
        }
        
        // For now, use placeholder dates (would fetch from season entity)
        let seasonName = "2024 Christmas Tree Season"
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 60, to: startDate)!
        
        return ScoutBucksReportResponse(
            seasonId: request.seasonId,
            seasonName: seasonName,
            startDate: startDate,
            endDate: endDate,
            bucksPerHour: request.bucksPerHour,
            minimumHours: request.minimumHours,
            entries: scoutEntries,
            totalBucksAwarded: totalBucksAwarded,
            totalHoursWorked: totalHoursWorked,
            qualifiedScouts: qualifiedCount,
            ineligibleScouts: ineligibleCount,
            generatedAt: Date()
        )
    }
}
