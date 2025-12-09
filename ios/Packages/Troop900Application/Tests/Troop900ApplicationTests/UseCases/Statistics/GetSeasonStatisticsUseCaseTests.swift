import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetSeasonStatisticsUseCase Tests")
struct GetSeasonStatisticsUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockUserRepository = MockUserRepository()
    private let mockHouseholdRepository = MockHouseholdRepository()
    private let mockShiftRepository = MockShiftRepository()
    private let mockLeaderboardService = MockLeaderboardService()
    
    private var useCase: GetSeasonStatisticsUseCase {
        GetSeasonStatisticsUseCase(
            attendanceRepository: mockAttendanceRepository,
            assignmentRepository: mockAssignmentRepository,
            userRepository: mockUserRepository,
            householdRepository: mockHouseholdRepository,
            shiftRepository: mockShiftRepository,
            leaderboardService: mockLeaderboardService
        )
    }
    
    // MARK: - Permission Tests
    
    @Test("Get season statistics succeeds for committee member")
    func getSeasonStatisticsSucceedsForCommittee() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        // When
        let response = try await useCase.execute(seasonId: "season-1", requestingUserId: committeeId)
        
        // Then
        #expect(response.seasonId == "season-1")
        #expect(mockLeaderboardService.getLeaderboardCallCount == 1)
    }
    
    @Test("Get season statistics fails for non-committee user")
    func getSeasonStatisticsFailsForNonCommittee() async throws {
        // Given
        let parentId = "parent-1"
        let parentUser = TestFixtures.createParent(id: parentId)
        mockUserRepository.usersById[parentId] = parentUser
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(seasonId: "season-1", requestingUserId: parentId)
        }
    }
    
    // MARK: - Statistics Tests
    
    @Test("Get season statistics calculates participation stats from leaderboard")
    func getSeasonStatisticsCalculatesParticipation() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let activeEntry = MockLeaderboardService.createLeaderboardEntry(id: "active", totalShifts: 5, rank: 1)
        let inactiveEntry = LeaderboardEntry(id: UserId(unchecked: "inactive"), name: "Inactive", totalHours: 0, totalShifts: 0, rank: 2)
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [activeEntry, inactiveEntry],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        // When
        let response = try await useCase.execute(seasonId: "season-1", requestingUserId: committeeId)
        
        // Then
        #expect(response.participation.totalVolunteers == 2)
        #expect(response.participation.activeVolunteers == 1)
    }
    
    @Test("Get season statistics calculates shift stats")
    func getSeasonStatisticsCalculatesShiftStats() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let completedShift = TestFixtures.createShift(
            id: "completed",
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 4,
            currentParents: 2,
            status: .completed
        )
        let publishedShift = TestFixtures.createShift(
            id: "published",
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 2,
            currentParents: 1,
            status: .published
        )
        
        mockShiftRepository.getShiftsForDateRangeResult = .success([completedShift, publishedShift])
        
        // When
        let response = try await useCase.execute(seasonId: "season-1", requestingUserId: committeeId)
        
        // Then
        #expect(response.shifts.totalShifts == 2)
        #expect(response.shifts.completedShifts == 1)
        #expect(response.shifts.totalSlots == 12) // (4+2) + (4+2) = 12
        #expect(response.shifts.filledSlots == 9) // (4+2) + (2+1) = 9
    }
    
    @Test("Get season statistics calculates average staffing rate")
    func getSeasonStatisticsCalculatesStaffingRate() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        // 80% staffed shift
        let shift = TestFixtures.createShift(
            id: "shift-1",
            requiredScouts: 5,
            requiredParents: 5,
            currentScouts: 4,
            currentParents: 4,
            status: .published
        )
        
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        
        // When
        let response = try await useCase.execute(seasonId: "season-1", requestingUserId: committeeId)
        
        // Then
        #expect(response.shifts.averageStaffingRate == 80.0) // 8/10 * 100
    }
    
    @Test("Get season statistics calculates hour stats from leaderboard")
    func getSeasonStatisticsCalculatesHourStats() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let entry1 = MockLeaderboardService.createLeaderboardEntry(id: "u1", totalHours: 20.0, rank: 1)
        let entry2 = MockLeaderboardService.createLeaderboardEntry(id: "u2", totalHours: 10.0, rank: 2)
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [entry1, entry2],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        // When
        let response = try await useCase.execute(seasonId: "season-1", requestingUserId: committeeId)
        
        // Then
        #expect(response.hours.totalHours == 30.0)
        #expect(response.hours.averageHoursPerVolunteer == 15.0)
    }
    
    @Test("Get season statistics returns top volunteers")
    func getSeasonStatisticsReturnsTopVolunteers() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        var entries: [LeaderboardEntry] = []
        for i in 1...15 {
            entries.append(MockLeaderboardService.createLeaderboardEntry(
                id: "user-\(i)",
                name: "User \(i)",
                totalHours: Double(100 - i),
                rank: i
            ))
        }
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: entries,
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        // When
        let response = try await useCase.execute(seasonId: "season-1", requestingUserId: committeeId)
        
        // Then
        #expect(response.topVolunteers.count == 10) // Top 10 only
        #expect(response.topVolunteers[0].rank == 1)
        #expect(response.topVolunteers[9].rank == 10)
    }
    
    // MARK: - Error Tests
    
    @Test("Get season statistics fails when user not found")
    func getSeasonStatisticsFailsWhenUserNotFound() async throws {
        // Given - no user in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(seasonId: "season-1", requestingUserId: "non-existent")
        }
    }
    
    @Test("Get season statistics propagates leaderboard service error")
    func getSeasonStatisticsPropagatesError() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        mockLeaderboardService.getLeaderboardResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(seasonId: "season-1", requestingUserId: committeeId)
        }
    }
}
