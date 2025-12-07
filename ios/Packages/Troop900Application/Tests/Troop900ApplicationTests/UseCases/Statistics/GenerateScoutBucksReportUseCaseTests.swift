import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GenerateScoutBucksReportUseCase Tests")
struct GenerateScoutBucksReportUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockUserRepository = MockUserRepository()
    private let mockLeaderboardService = MockLeaderboardService()
    
    private var useCase: GenerateScoutBucksReportUseCase {
        GenerateScoutBucksReportUseCase(
            attendanceRepository: mockAttendanceRepository,
            userRepository: mockUserRepository,
            leaderboardService: mockLeaderboardService
        )
    }
    
    // MARK: - Permission Tests
    
    @Test("Generate Scout Bucks report succeeds for committee member")
    func generateReportSucceedsForCommittee() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: committeeId,
            bucksPerHour: 1.0,
            minimumHours: nil,
            includeIneligible: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.seasonId == "season-1")
        #expect(response.bucksPerHour == 1.0)
    }
    
    @Test("Generate Scout Bucks report fails for non-committee user")
    func generateReportFailsForNonCommittee() async throws {
        // Given
        let parentId = "parent-1"
        let parentUser = TestFixtures.createParent(id: parentId)
        mockUserRepository.usersById[parentId] = parentUser
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: parentId,
            bucksPerHour: 1.0,
            minimumHours: nil,
            includeIneligible: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Calculation Tests
    
    @Test("Generate Scout Bucks report calculates bucks correctly")
    func generateReportCalculatesBucks() async throws {
        // Given
        let committeeId = "committee-1"
        let scoutId = "scout-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        let scoutUser = TestFixtures.createScout(id: scoutId, firstName: "Test", lastName: "Scout")
        
        mockUserRepository.usersById[committeeId] = committeeUser
        mockUserRepository.usersById[scoutId] = scoutUser
        
        let entry = MockLeaderboardService.createLeaderboardEntry(
            id: scoutId,
            name: "Test Scout",
            totalHours: 20.0,
            totalShifts: 5,
            rank: 1
        )
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [entry],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: committeeId,
            bucksPerHour: 2.50,
            minimumHours: nil,
            includeIneligible: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.entries.count == 1)
        #expect(response.entries[0].bucksEarned == 50.0) // 20 hours * $2.50
        #expect(response.totalBucksAwarded == 50.0)
    }
    
    @Test("Generate Scout Bucks report respects minimum hours requirement")
    func generateReportRespectsMinimumHours() async throws {
        // Given
        let committeeId = "committee-1"
        let qualifiedScoutId = "scout-qualified"
        let unqualifiedScoutId = "scout-unqualified"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        let qualifiedScout = TestFixtures.createScout(id: qualifiedScoutId)
        let unqualifiedScout = TestFixtures.createScout(id: unqualifiedScoutId)
        
        mockUserRepository.usersById[committeeId] = committeeUser
        mockUserRepository.usersById[qualifiedScoutId] = qualifiedScout
        mockUserRepository.usersById[unqualifiedScoutId] = unqualifiedScout
        
        let qualifiedEntry = MockLeaderboardService.createLeaderboardEntry(
            id: qualifiedScoutId,
            totalHours: 15.0, // Above minimum
            rank: 1
        )
        let unqualifiedEntry = MockLeaderboardService.createLeaderboardEntry(
            id: unqualifiedScoutId,
            totalHours: 5.0, // Below minimum
            rank: 2
        )
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [qualifiedEntry, unqualifiedEntry],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: committeeId,
            bucksPerHour: 1.0,
            minimumHours: 10.0,
            includeIneligible: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.entries.count == 1) // Only qualified scout
        #expect(response.qualifiedScouts == 1)
        #expect(response.entries[0].isEligible == true)
    }
    
    @Test("Generate Scout Bucks report includes ineligible when requested")
    func generateReportIncludesIneligible() async throws {
        // Given
        let committeeId = "committee-1"
        let qualifiedScoutId = "scout-qualified"
        let unqualifiedScoutId = "scout-unqualified"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        let qualifiedScout = TestFixtures.createScout(id: qualifiedScoutId)
        let unqualifiedScout = TestFixtures.createScout(id: unqualifiedScoutId)
        
        mockUserRepository.usersById[committeeId] = committeeUser
        mockUserRepository.usersById[qualifiedScoutId] = qualifiedScout
        mockUserRepository.usersById[unqualifiedScoutId] = unqualifiedScout
        
        let qualifiedEntry = MockLeaderboardService.createLeaderboardEntry(
            id: qualifiedScoutId,
            totalHours: 15.0,
            rank: 1
        )
        let unqualifiedEntry = MockLeaderboardService.createLeaderboardEntry(
            id: unqualifiedScoutId,
            totalHours: 5.0,
            rank: 2
        )
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [qualifiedEntry, unqualifiedEntry],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: committeeId,
            bucksPerHour: 1.0,
            minimumHours: 10.0,
            includeIneligible: true // Include ineligible
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.entries.count == 2) // Both scouts included
        #expect(response.qualifiedScouts == 1)
        #expect(response.ineligibleScouts == 1)
        
        let ineligibleEntry = response.entries.first { $0.id == unqualifiedScoutId }
        #expect(ineligibleEntry?.isEligible == false)
        #expect(ineligibleEntry?.bucksEarned == 0) // No bucks for ineligible
    }
    
    @Test("Generate Scout Bucks report excludes non-scout users")
    func generateReportExcludesNonScouts() async throws {
        // Given
        let committeeId = "committee-1"
        let scoutId = "scout-1"
        let parentId = "parent-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        let scoutUser = TestFixtures.createScout(id: scoutId)
        let parentUser = TestFixtures.createParent(id: parentId)
        
        mockUserRepository.usersById[committeeId] = committeeUser
        mockUserRepository.usersById[scoutId] = scoutUser
        mockUserRepository.usersById[parentId] = parentUser
        
        let scoutEntry = MockLeaderboardService.createLeaderboardEntry(id: scoutId, totalHours: 10.0, rank: 1)
        let parentEntry = MockLeaderboardService.createLeaderboardEntry(id: parentId, totalHours: 20.0, rank: 2)
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [scoutEntry, parentEntry],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: committeeId,
            bucksPerHour: 1.0,
            minimumHours: nil,
            includeIneligible: true
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.entries.count == 1) // Only scout
        #expect(response.entries[0].id == scoutId)
    }
    
    @Test("Generate Scout Bucks report sorts by hours descending")
    func generateReportSortsByHours() async throws {
        // Given
        let committeeId = "committee-1"
        let scout1Id = "scout-1"
        let scout2Id = "scout-2"
        let scout3Id = "scout-3"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        let scout1 = TestFixtures.createScout(id: scout1Id)
        let scout2 = TestFixtures.createScout(id: scout2Id)
        let scout3 = TestFixtures.createScout(id: scout3Id)
        
        mockUserRepository.usersById[committeeId] = committeeUser
        mockUserRepository.usersById[scout1Id] = scout1
        mockUserRepository.usersById[scout2Id] = scout2
        mockUserRepository.usersById[scout3Id] = scout3
        
        // Entries in different order than by hours
        let entry1 = MockLeaderboardService.createLeaderboardEntry(id: scout1Id, totalHours: 10.0, rank: 1)
        let entry2 = MockLeaderboardService.createLeaderboardEntry(id: scout2Id, totalHours: 30.0, rank: 2)
        let entry3 = MockLeaderboardService.createLeaderboardEntry(id: scout3Id, totalHours: 20.0, rank: 3)
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [entry1, entry2, entry3],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: committeeId,
            bucksPerHour: 1.0,
            minimumHours: nil,
            includeIneligible: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.entries.count == 3)
        #expect(response.entries[0].totalHours == 30.0) // Highest first
        #expect(response.entries[1].totalHours == 20.0)
        #expect(response.entries[2].totalHours == 10.0) // Lowest last
        
        // Ranks should be reassigned after sorting
        #expect(response.entries[0].rank == 1)
        #expect(response.entries[1].rank == 2)
        #expect(response.entries[2].rank == 3)
    }
    
    @Test("Generate Scout Bucks report calculates totals correctly")
    func generateReportCalculatesTotals() async throws {
        // Given
        let committeeId = "committee-1"
        let scout1Id = "scout-1"
        let scout2Id = "scout-2"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        let scout1 = TestFixtures.createScout(id: scout1Id)
        let scout2 = TestFixtures.createScout(id: scout2Id)
        
        mockUserRepository.usersById[committeeId] = committeeUser
        mockUserRepository.usersById[scout1Id] = scout1
        mockUserRepository.usersById[scout2Id] = scout2
        
        let entry1 = MockLeaderboardService.createLeaderboardEntry(id: scout1Id, totalHours: 15.0, rank: 1)
        let entry2 = MockLeaderboardService.createLeaderboardEntry(id: scout2Id, totalHours: 25.0, rank: 2)
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [entry1, entry2],
            seasonId: "season-1",
            generatedAt: Date()
        ))
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: committeeId,
            bucksPerHour: 2.0,
            minimumHours: nil,
            includeIneligible: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.totalHoursWorked == 40.0) // 15 + 25
        #expect(response.totalBucksAwarded == 80.0) // 40 * $2.00
        #expect(response.qualifiedScouts == 2)
    }
    
    // MARK: - Error Tests
    
    @Test("Generate Scout Bucks report fails when user not found")
    func generateReportFailsWhenUserNotFound() async throws {
        // Given
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: "non-existent",
            bucksPerHour: 1.0,
            minimumHours: nil,
            includeIneligible: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Generate Scout Bucks report propagates leaderboard error")
    func generateReportPropagatesError() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        mockLeaderboardService.getLeaderboardResult = .failure(DomainError.networkError)
        
        let request = ScoutBucksReportRequest(
            seasonId: "season-1",
            requestingUserId: committeeId,
            bucksPerHour: 1.0,
            minimumHours: nil,
            includeIneligible: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
