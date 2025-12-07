import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("CreateShiftUseCase Tests")
struct CreateShiftUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockMessagingService = MockMessagingService()
    
    private var useCase: CreateShiftUseCase {
        CreateShiftUseCase(
            shiftRepository: mockShiftRepository,
            messagingService: mockMessagingService
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Create shift as draft when publishImmediately is false")
    func createShiftAsDraft() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot A",
            label: "Morning Shift",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.status == .draft)
        #expect(response.notificationSent == false)
        #expect(mockShiftRepository.createShiftCallCount == 1)
        #expect(mockMessagingService.sendMessageCallCount == 0) // No notification for draft
        
        // Verify the shift was created with correct status
        let createdShift = mockShiftRepository.createShiftCalledWith[0]
        #expect(createdShift.status == .draft)
    }
    
    @Test("Create and publish shift immediately with notification")
    func createAndPublishWithNotification() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot A",
            publishImmediately: true,
            sendNotification: true
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.status == .published)
        #expect(response.notificationSent == true)
        #expect(mockShiftRepository.createShiftCallCount == 1)
        #expect(mockMessagingService.sendMessageCallCount == 1)
        
        // Verify notification content
        let sentMessage = mockMessagingService.sendMessageCalledWith[0]
        #expect(sentMessage.title == "New Shift Available")
        #expect(sentMessage.targetAudience == .all)
        #expect(sentMessage.priority == .normal)
    }
    
    @Test("Create and publish shift without notification")
    func createAndPublishWithoutNotification() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot A",
            publishImmediately: true,
            sendNotification: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.status == .published)
        #expect(response.notificationSent == false)
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    @Test("Create shift with all optional fields")
    func createShiftWithAllOptionalFields() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(14),
            endTime: shiftDate.addingHours(18),
            requiredScouts: 6,
            requiredParents: 3,
            location: "Tree Lot B",
            label: "Afternoon Shift",
            notes: "Busy time - need extra help",
            seasonId: "season-2024",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.shiftId.isEmpty == false)
        
        let createdShift = mockShiftRepository.createShiftCalledWith[0]
        #expect(createdShift.label == "Afternoon Shift")
        #expect(createdShift.notes == "Busy time - need extra help")
        #expect(createdShift.seasonId == "season-2024")
    }
    
    @Test("Create shift trims whitespace from location")
    func createShiftTrimsWhitespace() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: 2,
            location: "  Tree Lot A  ",
            label: "  Morning  ",
            notes: "  Notes  ",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When
        _ = try await useCase.execute(request: request)
        
        // Then
        let createdShift = mockShiftRepository.createShiftCalledWith[0]
        #expect(createdShift.location == "Tree Lot A")
        #expect(createdShift.label == "Morning")
        #expect(createdShift.notes == "Notes")
    }
    
    @Test("Create shift allows zero required scouts")
    func createShiftAllowsZeroScouts() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(11),
            requiredScouts: 0,
            requiredParents: 2,
            location: "Tree Lot",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.shiftId.isEmpty == false)
        let createdShift = mockShiftRepository.createShiftCalledWith[0]
        #expect(createdShift.requiredScouts == 0)
    }
    
    // MARK: - Notification Failure Tests
    
    @Test("Notification failure does not fail shift creation")
    func notificationFailureDoesNotFailShiftCreation() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot A",
            publishImmediately: true,
            sendNotification: true
        )
        mockMessagingService.sendMessageResult = .failure(DomainError.networkError)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then - Shift should still be created successfully
        #expect(response.status == .published)
        #expect(response.notificationSent == false) // But notification failed
        #expect(mockShiftRepository.createShiftCallCount == 1)
        #expect(mockMessagingService.sendMessageCallCount == 1)
    }
    
    // MARK: - Validation Error Tests
    
    @Test("Create shift fails with negative required scouts")
    func createShiftFailsWithNegativeScouts() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: -1,
            requiredParents: 2,
            location: "Tree Lot",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.createShiftCallCount == 0)
    }
    
    @Test("Create shift fails with negative required parents")
    func createShiftFailsWithNegativeParents() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: -1,
            location: "Tree Lot",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.createShiftCallCount == 0)
    }
    
    @Test("Create shift fails when end time is before start time")
    func createShiftFailsWhenEndTimeBeforeStartTime() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(13),
            endTime: shiftDate.addingHours(9),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.createShiftCallCount == 0)
    }
    
    @Test("Create shift fails when end time equals start time")
    func createShiftFailsWhenEndTimeEqualsStartTime() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let startTime = shiftDate.addingHours(9)
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: startTime,
            endTime: startTime,
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Create shift fails with empty location")
    func createShiftFailsWithEmptyLocation() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: 2,
            location: "",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.createShiftCallCount == 0)
    }
    
    @Test("Create shift fails with whitespace-only location")
    func createShiftFailsWithWhitespaceOnlyLocation() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: 2,
            location: "   ",
            publishImmediately: false,
            sendNotification: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Repository Error Tests
    
    @Test("Create shift propagates repository error")
    func createShiftPropagatesRepositoryError() async throws {
        // Given
        let shiftDate = DateTestHelpers.tomorrow
        let request = CreateShiftRequest(
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot",
            publishImmediately: false,
            sendNotification: false
        )
        mockShiftRepository.createShiftResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.createShiftCallCount == 1)
    }
}
