import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("PublishScheduleUseCase Tests")
struct PublishScheduleUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockSeasonRepository = MockSeasonRepository()
    private let mockMessagingService = MockMessagingService()
    
    private var useCase: PublishScheduleUseCase {
        PublishScheduleUseCase(
            shiftRepository: mockShiftRepository,
            seasonRepository: mockSeasonRepository,
            messagingService: mockMessagingService
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Publish schedule changes all draft shifts to published")
    func publishScheduleChangesAllDraftShiftsToPublished() async throws {
        // Given
        let seasonId = "season-1"
        let season = TestFixtures.createSeason(id: seasonId, status: .active)
        mockSeasonRepository.seasonsById[seasonId] = season
        
        // Add draft shifts
        let draftShift1 = TestFixtures.createDraftShift(id: "shift-1")
        let draftShift2 = TestFixtures.createDraftShift(id: "shift-2")
        let draftShift3 = TestFixtures.createDraftShift(id: "shift-3")
        mockShiftRepository.shiftsById["shift-1"] = Shift(
            id: draftShift1.id, date: draftShift1.date, startTime: draftShift1.startTime,
            endTime: draftShift1.endTime, requiredScouts: draftShift1.requiredScouts,
            requiredParents: draftShift1.requiredParents, currentScouts: 0, currentParents: 0,
            location: draftShift1.location, label: nil, notes: nil, status: .draft,
            seasonId: seasonId, templateId: nil, createdAt: Date()
        )
        mockShiftRepository.shiftsById["shift-2"] = Shift(
            id: draftShift2.id, date: draftShift2.date, startTime: draftShift2.startTime,
            endTime: draftShift2.endTime, requiredScouts: draftShift2.requiredScouts,
            requiredParents: draftShift2.requiredParents, currentScouts: 0, currentParents: 0,
            location: draftShift2.location, label: nil, notes: nil, status: .draft,
            seasonId: seasonId, templateId: nil, createdAt: Date()
        )
        mockShiftRepository.shiftsById["shift-3"] = Shift(
            id: draftShift3.id, date: draftShift3.date, startTime: draftShift3.startTime,
            endTime: draftShift3.endTime, requiredScouts: draftShift3.requiredScouts,
            requiredParents: draftShift3.requiredParents, currentScouts: 0, currentParents: 0,
            location: draftShift3.location, label: nil, notes: nil, status: .draft,
            seasonId: seasonId, templateId: nil, createdAt: Date()
        )
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.seasonId == seasonId)
        #expect(response.shiftsPublished == 3)
        #expect(mockShiftRepository.updateShiftCallCount == 3)
        
        // Verify all shifts were updated to published
        for updatedShift in mockShiftRepository.updateShiftCalledWith {
            #expect(updatedShift.status == .published)
        }
    }
    
    @Test("Publish schedule only publishes draft shifts, ignores published ones")
    func publishScheduleOnlyPublishesDraftShifts() async throws {
        // Given
        let seasonId = "season-1"
        let season = TestFixtures.createSeason(id: seasonId, status: .active)
        mockSeasonRepository.seasonsById[seasonId] = season
        
        // Mix of draft and published shifts
        mockShiftRepository.shiftsById["draft-1"] = TestFixtures.createShift(
            id: "draft-1", status: .draft, seasonId: seasonId
        )
        mockShiftRepository.shiftsById["published-1"] = TestFixtures.createShift(
            id: "published-1", status: .published, seasonId: seasonId
        )
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.shiftsPublished == 1) // Only the draft shift
        #expect(mockShiftRepository.updateShiftCallCount == 1)
    }
    
    @Test("Publish schedule activates season if not already active")
    func publishScheduleActivatesSeason() async throws {
        // Given
        let seasonId = "season-1"
        let draftSeason = TestFixtures.createSeason(id: seasonId, status: .draft)
        mockSeasonRepository.seasonsById[seasonId] = draftSeason
        
        mockShiftRepository.shiftsById["shift-1"] = TestFixtures.createShift(
            id: "shift-1", status: .draft, seasonId: seasonId
        )
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: false
        )
        
        // When
        _ = try await useCase.execute(request: request)
        
        // Then
        #expect(mockSeasonRepository.updateSeasonCallCount == 1)
        let updatedSeason = mockSeasonRepository.updateSeasonCalledWith[0]
        #expect(updatedSeason.status == .active)
    }
    
    @Test("Publish schedule does not update already active season")
    func publishScheduleDoesNotUpdateActiveSeasonStatus() async throws {
        // Given
        let seasonId = "season-1"
        let activeSeason = TestFixtures.createSeason(id: seasonId, status: .active)
        mockSeasonRepository.seasonsById[seasonId] = activeSeason
        
        mockShiftRepository.shiftsById["shift-1"] = TestFixtures.createShift(
            id: "shift-1", status: .draft, seasonId: seasonId
        )
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: false
        )
        
        // When
        _ = try await useCase.execute(request: request)
        
        // Then - season should not be updated since it's already active
        #expect(mockSeasonRepository.updateSeasonCallCount == 0)
    }
    
    @Test("Publish schedule sends notification when requested")
    func publishScheduleSendsNotification() async throws {
        // Given
        let seasonId = "season-1"
        let season = TestFixtures.createSeason(
            id: seasonId,
            name: "2024 Tree Lot",
            status: .active
        )
        mockSeasonRepository.seasonsById[seasonId] = season
        
        mockShiftRepository.shiftsById["shift-1"] = TestFixtures.createShift(
            id: "shift-1", status: .draft, seasonId: seasonId
        )
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: true
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.notificationSent == true)
        #expect(mockMessagingService.sendMessageCallCount == 1)
        
        let sentMessage = mockMessagingService.sendMessageCalledWith[0]
        #expect(sentMessage.targetAudience == .all)
        #expect(sentMessage.priority == .high)
    }
    
    @Test("Publish schedule uses custom notification title and message")
    func publishScheduleUsesCustomNotificationContent() async throws {
        // Given
        let seasonId = "season-1"
        let season = TestFixtures.createSeason(id: seasonId, status: .active)
        mockSeasonRepository.seasonsById[seasonId] = season
        
        mockShiftRepository.shiftsById["shift-1"] = TestFixtures.createShift(
            id: "shift-1", status: .draft, seasonId: seasonId
        )
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: true,
            notificationTitle: "Custom Title",
            notificationMessage: "Custom message body"
        )
        
        // When
        _ = try await useCase.execute(request: request)
        
        // Then
        let sentMessage = mockMessagingService.sendMessageCalledWith[0]
        #expect(sentMessage.title == "Custom Title")
        #expect(sentMessage.body == "Custom message body")
    }
    
    @Test("Publish schedule does not send notification when not requested")
    func publishScheduleDoesNotSendNotificationWhenNotRequested() async throws {
        // Given
        let seasonId = "season-1"
        let season = TestFixtures.createSeason(id: seasonId, status: .active)
        mockSeasonRepository.seasonsById[seasonId] = season
        
        mockShiftRepository.shiftsById["shift-1"] = TestFixtures.createShift(
            id: "shift-1", status: .draft, seasonId: seasonId
        )
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.notificationSent == false)
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    // MARK: - Error Tests
    
    @Test("Publish schedule fails when no draft shifts exist")
    func publishScheduleFailsWhenNoDraftShifts() async throws {
        // Given
        let seasonId = "season-1"
        let season = TestFixtures.createSeason(id: seasonId, status: .active)
        mockSeasonRepository.seasonsById[seasonId] = season
        
        // Only published shifts, no drafts
        mockShiftRepository.shiftsById["shift-1"] = TestFixtures.createShift(
            id: "shift-1", status: .published, seasonId: seasonId
        )
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Publish schedule fails when season not found")
    func publishScheduleFailsWhenSeasonNotFound() async throws {
        // Given - season not in repository
        let request = PublishScheduleRequest(
            seasonId: "non-existent",
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Publish schedule propagates shift repository error")
    func publishSchedulePropagatesShiftRepositoryError() async throws {
        // Given
        let seasonId = "season-1"
        let season = TestFixtures.createSeason(id: seasonId, status: .active)
        mockSeasonRepository.seasonsById[seasonId] = season
        
        mockShiftRepository.shiftsById["shift-1"] = TestFixtures.createShift(
            id: "shift-1", status: .draft, seasonId: seasonId
        )
        mockShiftRepository.updateShiftError = DomainError.networkError
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Publish schedule propagates messaging service error")
    func publishSchedulePropagatesMessagingError() async throws {
        // Given
        let seasonId = "season-1"
        let season = TestFixtures.createSeason(id: seasonId, status: .active)
        mockSeasonRepository.seasonsById[seasonId] = season
        
        mockShiftRepository.shiftsById["shift-1"] = TestFixtures.createShift(
            id: "shift-1", status: .draft, seasonId: seasonId
        )
        mockMessagingService.sendMessageResult = .failure(DomainError.networkError)
        
        let request = PublishScheduleRequest(
            seasonId: seasonId,
            sendNotification: true
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        
        // Shifts should have been updated before messaging failed
        #expect(mockShiftRepository.updateShiftCallCount == 1)
    }
}
