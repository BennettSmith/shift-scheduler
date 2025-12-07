import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetLeaderboardUseCase Tests")
struct GetLeaderboardUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockLeaderboardService = MockLeaderboardService()
    
    private var useCase: GetLeaderboardUseCase {
        GetLeaderboardUseCase(leaderboardService: mockLeaderboardService)
    }
    
    // MARK: - Success Tests
    
    @Test("Get leaderboard succeeds without season filter")
    func getLeaderboardSucceedsWithoutSeasonFilter() async throws {
        // Given
        let entry1 = MockLeaderboardService.createLeaderboardEntry(
            id: "user-1",
            name: "Top User",
            totalHours: 50.0,
            totalShifts: 15,
            rank: 1
        )
        let entry2 = MockLeaderboardService.createLeaderboardEntry(
            id: "user-2",
            name: "Second User",
            totalHours: 35.0,
            totalShifts: 10,
            rank: 2
        )
        
        mockLeaderboardService.leaderboardEntries = [entry1, entry2]
        
        // When
        let result = try await useCase.execute(seasonId: nil)
        
        // Then
        #expect(result.entries.count == 2)
        #expect(result.seasonId == nil)
        #expect(result.entries[0].rank == 1)
        #expect(result.entries[0].totalHours == 50.0)
        #expect(mockLeaderboardService.getLeaderboardCallCount == 1)
        #expect(mockLeaderboardService.getLeaderboardCalledWith[0] == nil)
    }
    
    @Test("Get leaderboard succeeds with season filter")
    func getLeaderboardSucceedsWithSeasonFilter() async throws {
        // Given
        let seasonId = "season-2024"
        let entry = MockLeaderboardService.createLeaderboardEntry(
            id: "user-1",
            name: "Season Leader",
            totalHours: 100.0,
            totalShifts: 30,
            rank: 1
        )
        
        mockLeaderboardService.getLeaderboardResult = .success(LeaderboardResult(
            entries: [entry],
            seasonId: seasonId,
            generatedAt: Date()
        ))
        
        // When
        let result = try await useCase.execute(seasonId: seasonId)
        
        // Then
        #expect(result.seasonId == seasonId)
        #expect(result.entries.count == 1)
        #expect(mockLeaderboardService.getLeaderboardCalledWith[0] == seasonId)
    }
    
    @Test("Get leaderboard returns empty for season with no data")
    func getLeaderboardReturnsEmptyForNoData() async throws {
        // Given - no entries configured
        mockLeaderboardService.leaderboardEntries = []
        
        // When
        let result = try await useCase.execute(seasonId: nil)
        
        // Then
        #expect(result.entries.isEmpty)
    }
    
    @Test("Get leaderboard preserves entry ranking order")
    func getLeaderboardPreservesRankingOrder() async throws {
        // Given
        let entries = [
            MockLeaderboardService.createLeaderboardEntry(id: "user-1", rank: 1),
            MockLeaderboardService.createLeaderboardEntry(id: "user-2", rank: 2),
            MockLeaderboardService.createLeaderboardEntry(id: "user-3", rank: 3),
            MockLeaderboardService.createLeaderboardEntry(id: "user-4", rank: 4),
            MockLeaderboardService.createLeaderboardEntry(id: "user-5", rank: 5)
        ]
        
        mockLeaderboardService.leaderboardEntries = entries
        
        // When
        let result = try await useCase.execute(seasonId: nil)
        
        // Then
        #expect(result.entries.count == 5)
        for (index, entry) in result.entries.enumerated() {
            #expect(entry.rank == index + 1)
        }
    }
    
    // MARK: - Error Tests
    
    @Test("Get leaderboard propagates service error")
    func getLeaderboardPropagatesServiceError() async throws {
        // Given
        mockLeaderboardService.getLeaderboardResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(seasonId: nil)
        }
    }
}
