import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetPersonalStatsUseCase Tests")
struct GetPersonalStatsUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockUserRepository = MockUserRepository()
    private let mockShiftRepository = MockShiftRepository()
    private let mockLeaderboardService = MockLeaderboardService()
    
    private var useCase: GetPersonalStatsUseCase {
        GetPersonalStatsUseCase(
            attendanceRepository: mockAttendanceRepository,
            assignmentRepository: mockAssignmentRepository,
            userRepository: mockUserRepository,
            shiftRepository: mockShiftRepository,
            leaderboardService: mockLeaderboardService
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Get personal stats succeeds for user")
    func getPersonalStatsSucceeds() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId, firstName: "John", lastName: "Doe")
        mockUserRepository.usersById[userId] = user
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: nil)
        
        // Then
        #expect(response.userId == userId)
        #expect(response.userName == "John Doe")
        #expect(mockAttendanceRepository.getAttendanceRecordsForUserCallCount == 1)
        #expect(mockAssignmentRepository.getAssignmentsForUserCallCount == 1)
    }
    
    @Test("Get personal stats calculates total hours from completed attendance")
    func getPersonalStatsCalculatesTotalHours() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        // Create attendance records with hours
        let record1 = TestFixtures.createCompletedRecord(
            id: "record-1",
            userId: userId,
            hoursWorked: 4.0
        )
        let record2 = TestFixtures.createCompletedRecord(
            id: "record-2",
            userId: userId,
            hoursWorked: 3.5
        )
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([record1, record2])
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: nil)
        
        // Then
        #expect(response.allTimeStats.totalHours == 7.5)
        #expect(response.allTimeStats.completedShifts == 2)
    }
    
    @Test("Get personal stats calculates average hours per shift")
    func getPersonalStatsCalculatesAverageHours() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let record1 = TestFixtures.createCompletedRecord(id: "r1", userId: userId, hoursWorked: 4.0)
        let record2 = TestFixtures.createCompletedRecord(id: "r2", userId: userId, hoursWorked: 6.0)
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([record1, record2])
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: nil)
        
        // Then
        #expect(response.allTimeStats.averageHoursPerShift == 5.0) // (4 + 6) / 2
    }
    
    @Test("Get personal stats counts no-shows correctly")
    func getPersonalStatsCountsNoShows() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let completedRecord = TestFixtures.createCompletedRecord(id: "r1", userId: userId, hoursWorked: 4.0)
        let noShowRecord = TestFixtures.createAttendanceRecord(id: "r2", userId: userId, status: .noShow)
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([completedRecord, noShowRecord])
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: nil)
        
        // Then
        #expect(response.allTimeStats.completedShifts == 1)
        #expect(response.allTimeStats.noShows == 1)
    }
    
    @Test("Get personal stats includes leaderboard rank when season provided")
    func getPersonalStatsIncludesLeaderboardRank() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let entry1 = MockLeaderboardService.createLeaderboardEntry(id: "other-user", rank: 1)
        let entry2 = MockLeaderboardService.createLeaderboardEntry(id: userId, rank: 2)
        let entry3 = MockLeaderboardService.createLeaderboardEntry(id: "another-user", rank: 3)
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [entry1, entry2, entry3],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: "season-1")
        
        // Then
        #expect(response.currentSeasonRank == 2)
        #expect(response.totalParticipantsInSeason == 3)
    }
    
    @Test("Get personal stats returns recent shifts sorted by date")
    func getPersonalStatsReturnsRecentShifts() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let oldRecord = TestFixtures.createAttendanceRecord(
            id: "old",
            userId: userId,
            checkInTime: DateTestHelpers.date(2024, 1, 1),
            hoursWorked: 2.0,
            status: .checkedOut
        )
        let newRecord = TestFixtures.createAttendanceRecord(
            id: "new",
            userId: userId,
            checkInTime: DateTestHelpers.date(2024, 1, 15),
            hoursWorked: 3.0,
            status: .checkedOut
        )
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([oldRecord, newRecord])
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: nil)
        
        // Then
        #expect(response.recentShifts.count == 2)
        #expect(response.recentShifts[0].id == "new") // Most recent first
        #expect(response.recentShifts[1].id == "old")
    }
    
    // MARK: - Achievement Tests
    
    @Test("Get personal stats includes hour milestones")
    func getPersonalStatsIncludesHourMilestones() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        // Create records totaling 30 hours (should unlock 10 and 25 hour milestones)
        let record = TestFixtures.createCompletedRecord(id: "r1", userId: userId, hoursWorked: 30.0)
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([record])
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: nil)
        
        // Then
        let hourAchievements = response.achievements.filter { $0.category == .hours }
        #expect(hourAchievements.count >= 2) // 10 and 25 hours
        #expect(hourAchievements.contains { $0.id == "hours-10" })
        #expect(hourAchievements.contains { $0.id == "hours-25" })
    }
    
    @Test("Get personal stats includes shift milestones")
    func getPersonalStatsIncludesShiftMilestones() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        // Create 12 completed shift records (should unlock 5 and 10 shift milestones)
        var records: [AttendanceRecord] = []
        for i in 0..<12 {
            let record = TestFixtures.createCompletedRecord(id: "r\(i)", userId: userId, hoursWorked: 2.0)
            records.append(record)
        }
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success(records)
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: nil)
        
        // Then
        let shiftAchievements = response.achievements.filter { $0.category == .shifts }
        #expect(shiftAchievements.count >= 2) // 5 and 10 shifts
        #expect(shiftAchievements.contains { $0.id == "shifts-5" })
        #expect(shiftAchievements.contains { $0.id == "shifts-10" })
    }
    
    @Test("Get personal stats includes first shift achievement")
    func getPersonalStatsIncludesFirstShift() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let record = TestFixtures.createCompletedRecord(id: "r1", userId: userId, hoursWorked: 4.0)
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([record])
        
        // When
        let response = try await useCase.execute(userId: userId, seasonId: nil)
        
        // Then
        #expect(response.achievements.contains { $0.id == "first-shift" })
    }
    
    // MARK: - Error Tests
    
    @Test("Get personal stats fails when user not found")
    func getPersonalStatsFailsWhenUserNotFound() async throws {
        // Given - no user in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(userId: "non-existent", seasonId: nil)
        }
    }
    
    @Test("Get personal stats propagates attendance repository error")
    func getPersonalStatsPropagatesAttendanceError() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(userId: userId, seasonId: nil)
        }
    }
}
