import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetSeasonsUseCase Tests")
struct GetSeasonsUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockSeasonRepository = MockSeasonRepository()
    
    private var useCase: GetSeasonsUseCase {
        GetSeasonsUseCase(seasonRepository: mockSeasonRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Get seasons returns empty list when no seasons exist")
    func getSeasonsReturnsEmptyWhenNoSeasons() async throws {
        // Given - no seasons in repository
        
        // When
        let response = try await useCase.execute(statusFilter: nil)
        
        // Then
        #expect(response.seasons.isEmpty)
        #expect(response.activeSeason == nil)
        #expect(mockSeasonRepository.getAllSeasonsCallCount == 1)
        #expect(mockSeasonRepository.getActiveSeasonCallCount == 1)
    }
    
    @Test("Get seasons returns all seasons when no filter")
    func getSeasonsReturnsAllWhenNoFilter() async throws {
        // Given
        let activeSeason = TestFixtures.createSeason(
            id: "season-1",
            name: "2024 Tree Lot",
            status: .active
        )
        let completedSeason = TestFixtures.createSeason(
            id: "season-2",
            name: "2023 Tree Lot",
            status: .completed
        )
        let draftSeason = TestFixtures.createSeason(
            id: "season-3",
            name: "2025 Tree Lot",
            status: .draft
        )
        
        mockSeasonRepository.seasonsById["season-1"] = activeSeason
        mockSeasonRepository.seasonsById["season-2"] = completedSeason
        mockSeasonRepository.seasonsById["season-3"] = draftSeason
        mockSeasonRepository.activeSeason = activeSeason
        
        // When
        let response = try await useCase.execute(statusFilter: nil)
        
        // Then
        #expect(response.seasons.count == 3)
        #expect(response.activeSeason?.id == "season-1")
    }
    
    @Test("Get seasons filters by status")
    func getSeasonsFiltersByStatus() async throws {
        // Given
        let activeSeason = TestFixtures.createSeason(
            id: "season-1",
            name: "2024 Tree Lot",
            status: .active
        )
        let completedSeason = TestFixtures.createSeason(
            id: "season-2",
            name: "2023 Tree Lot",
            status: .completed
        )
        
        mockSeasonRepository.seasonsById["season-1"] = activeSeason
        mockSeasonRepository.seasonsById["season-2"] = completedSeason
        mockSeasonRepository.activeSeason = activeSeason
        
        // When
        let response = try await useCase.execute(statusFilter: .completed)
        
        // Then
        #expect(response.seasons.count == 1)
        #expect(response.seasons[0].id == "season-2")
        #expect(response.seasons[0].status == .completed)
    }
    
    @Test("Get seasons returns seasons sorted by start date descending")
    func getSeasonsSortedByStartDateDescending() async throws {
        // Given
        let oldSeason = TestFixtures.createSeason(
            id: "old-season",
            name: "2022 Season",
            startDate: DateTestHelpers.relativeDate(days: -365)
        )
        let recentSeason = TestFixtures.createSeason(
            id: "recent-season",
            name: "2024 Season",
            startDate: DateTestHelpers.relativeDate(days: -30)
        )
        let futureSeason = TestFixtures.createSeason(
            id: "future-season",
            name: "2025 Season",
            startDate: DateTestHelpers.relativeDate(days: 30)
        )
        
        mockSeasonRepository.seasonsById["old-season"] = oldSeason
        mockSeasonRepository.seasonsById["recent-season"] = recentSeason
        mockSeasonRepository.seasonsById["future-season"] = futureSeason
        
        // When
        let response = try await useCase.execute(statusFilter: nil)
        
        // Then
        #expect(response.seasons.count == 3)
        // Most recent first (by start date descending)
        #expect(response.seasons[0].id == "future-season")
        #expect(response.seasons[1].id == "recent-season")
        #expect(response.seasons[2].id == "old-season")
    }
    
    @Test("Get seasons maps all fields correctly")
    func getSeasonsMapsAllFields() async throws {
        // Given
        let startDate = DateTestHelpers.relativeDate(days: -30)
        let endDate = DateTestHelpers.relativeDate(days: 30)
        
        let season = TestFixtures.createSeason(
            id: "season-1",
            name: "2024 Tree Lot",
            year: 2024,
            startDate: startDate,
            endDate: endDate,
            status: .active,
            description: "Annual fundraiser"
        )
        
        mockSeasonRepository.seasonsById["season-1"] = season
        mockSeasonRepository.activeSeason = season
        
        // When
        let response = try await useCase.execute(statusFilter: nil)
        
        // Then
        #expect(response.seasons.count == 1)
        let result = response.seasons[0]
        #expect(result.id == "season-1")
        #expect(result.name == "2024 Tree Lot")
        #expect(result.year == 2024)
        #expect(result.startDate == startDate)
        #expect(result.endDate == endDate)
        #expect(result.status == .active)
        #expect(result.description == "Annual fundraiser")
        #expect(result.isActive == true)
    }
    
    @Test("Get seasons sets isActive correctly based on status")
    func getSeasonsIsActiveReflectsStatus() async throws {
        // Given
        let activeSeason = TestFixtures.createSeason(id: "active", status: .active)
        let draftSeason = TestFixtures.createSeason(id: "draft", status: .draft)
        let completedSeason = TestFixtures.createSeason(id: "completed", status: .completed)
        
        mockSeasonRepository.seasonsById["active"] = activeSeason
        mockSeasonRepository.seasonsById["draft"] = draftSeason
        mockSeasonRepository.seasonsById["completed"] = completedSeason
        
        // When
        let response = try await useCase.execute(statusFilter: nil)
        
        // Then
        let activeResult = response.seasons.first { $0.id == "active" }
        let draftResult = response.seasons.first { $0.id == "draft" }
        let completedResult = response.seasons.first { $0.id == "completed" }
        
        #expect(activeResult?.isActive == true)
        #expect(draftResult?.isActive == false)
        #expect(completedResult?.isActive == false)
    }
    
    @Test("Get seasons returns nil active season when none is active")
    func getSeasonsReturnsNilActiveSeasonWhenNoneActive() async throws {
        // Given
        let completedSeason = TestFixtures.createSeason(id: "completed", status: .completed)
        mockSeasonRepository.seasonsById["completed"] = completedSeason
        // No active season set
        
        // When
        let response = try await useCase.execute(statusFilter: nil)
        
        // Then
        #expect(response.seasons.count == 1)
        #expect(response.activeSeason == nil)
    }
    
    // MARK: - Error Tests
    
    @Test("Get seasons propagates repository error")
    func getSeasonsPropagatesError() async throws {
        // Given
        mockSeasonRepository.getAllSeasonsResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(statusFilter: nil)
        }
    }
    
    @Test("Get seasons propagates active season error")
    func getSeasonsProapgatesActiveSeasonError() async throws {
        // Given
        mockSeasonRepository.getActiveSeasonResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(statusFilter: nil)
        }
    }
}
