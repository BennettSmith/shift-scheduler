import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("UpdateDraftShiftUseCase Tests")
struct UpdateDraftShiftUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    
    private var useCase: UpdateDraftShiftUseCase {
        UpdateDraftShiftUseCase(shiftRepository: mockShiftRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Update draft shift succeeds with all fields changed")
    func updateDraftShiftSucceedsWithAllFieldsChanged() async throws {
        // Given
        let shiftId = "shift-1"
        let existingShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.date(2024, 12, 1),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Old Location",
            label: "Old Label",
            notes: "Old Notes",
            status: .draft
        )
        mockShiftRepository.shiftsById[shiftId] = existingShift
        
        let newDate = DateTestHelpers.date(2024, 12, 5)
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            date: newDate,
            startTime: newDate.addingHours(10),
            endTime: newDate.addingHours(14),
            requiredScouts: 6,
            requiredParents: 3,
            location: "New Location",
            label: "New Label",
            notes: "New Notes"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.id == shiftId)
        #expect(response.requiredScouts == 6)
        #expect(response.requiredParents == 3)
        #expect(response.location == "New Location")
        #expect(response.label == "New Label")
        #expect(response.status == .draft) // Status unchanged
        #expect(mockShiftRepository.getShiftCallCount == 1)
        #expect(mockShiftRepository.updateShiftCallCount == 1)
    }
    
    @Test("Update draft shift succeeds with partial changes")
    func updateDraftShiftSucceedsWithPartialChanges() async throws {
        // Given
        let shiftId = "shift-1"
        let existingShift = TestFixtures.createShift(
            id: shiftId,
            requiredScouts: 4,
            requiredParents: 2,
            location: "Original Location",
            status: .draft
        )
        mockShiftRepository.shiftsById[shiftId] = existingShift
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            location: "Updated Location"
            // All other fields remain nil (unchanged)
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.location == "Updated Location")
        #expect(response.requiredScouts == 4) // Preserved
        #expect(response.requiredParents == 2) // Preserved
    }
    
    @Test("Update draft shift preserves current volunteer counts")
    func updateDraftShiftPreservesVolunteerCounts() async throws {
        // Given
        let shiftId = "shift-1"
        let existingShift = TestFixtures.createShift(
            id: shiftId,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 2,
            currentParents: 1,
            status: .draft
        )
        mockShiftRepository.shiftsById[shiftId] = existingShift
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            requiredScouts: 6
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.requiredScouts == 6)
        #expect(response.currentScouts == 2) // Preserved
        #expect(response.currentParents == 1) // Preserved
    }
    
    @Test("Update draft shift trims whitespace from location")
    func updateDraftShiftTrimsWhitespace() async throws {
        // Given
        let shiftId = "shift-1"
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, status: .draft
        )
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            location: "  Trimmed Location  "
        )
        
        // When
        _ = try await useCase.execute(request: request)
        
        // Then
        let updatedShift = mockShiftRepository.updateShiftCalledWith[0]
        #expect(updatedShift.location == "Trimmed Location")
    }
    
    @Test("Update draft shift returns shift summary with time range")
    func updateDraftShiftReturnsShiftSummary() async throws {
        // Given
        let shiftId = "shift-1"
        let shiftDate = DateTestHelpers.date(2024, 12, 15)
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId,
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13),
            status: .draft
        )
        
        let request = UpdateShiftRequest(shiftId: shiftId)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.id == shiftId)
        #expect(response.timeRange.isEmpty == false) // Should have formatted time range
    }
    
    // MARK: - Status Restriction Tests
    
    @Test("Update fails for published shift")
    func updateFailsForPublishedShift() async throws {
        // Given
        let shiftId = "shift-1"
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, status: .published
        )
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            location: "New Location"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Update fails for cancelled shift")
    func updateFailsForCancelledShift() async throws {
        // Given
        let shiftId = "shift-1"
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, status: .cancelled
        )
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            location: "New Location"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Update fails for non-existent shift")
    func updateFailsForNonExistentShift() async throws {
        // Given - shift not in repository
        let request = UpdateShiftRequest(
            shiftId: "non-existent",
            location: "New Location"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    // MARK: - Validation Error Tests
    
    @Test("Update draft shift fails with negative required scouts")
    func updateDraftShiftFailsWithNegativeScouts() async throws {
        // Given
        let shiftId = "shift-1"
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, status: .draft
        )
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            requiredScouts: -1
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Update draft shift fails with negative required parents")
    func updateDraftShiftFailsWithNegativeParents() async throws {
        // Given
        let shiftId = "shift-1"
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, status: .draft
        )
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            requiredParents: -1
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Update draft shift fails when both times provided and end before start")
    func updateDraftShiftFailsWhenBothTimesProvidedEndBeforeStart() async throws {
        // Given
        let shiftId = "shift-1"
        let shiftDate = DateTestHelpers.tomorrow
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, date: shiftDate, status: .draft
        )
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            startTime: shiftDate.addingHours(14),
            endTime: shiftDate.addingHours(10)
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Update draft shift fails when new end time before existing start time")
    func updateDraftShiftFailsWhenNewEndBeforeExistingStart() async throws {
        // Given
        let shiftId = "shift-1"
        let shiftDate = DateTestHelpers.tomorrow
        let existingShift = TestFixtures.createShift(
            id: shiftId,
            date: shiftDate,
            startTime: shiftDate.addingHours(10),
            endTime: shiftDate.addingHours(14),
            status: .draft
        )
        mockShiftRepository.shiftsById[shiftId] = existingShift
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            endTime: shiftDate.addingHours(9) // Before existing start time of 10:00
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Update draft shift fails when new start time after existing end time")
    func updateDraftShiftFailsWhenNewStartAfterExistingEnd() async throws {
        // Given
        let shiftId = "shift-1"
        let shiftDate = DateTestHelpers.tomorrow
        let existingShift = TestFixtures.createShift(
            id: shiftId,
            date: shiftDate,
            startTime: shiftDate.addingHours(10),
            endTime: shiftDate.addingHours(14),
            status: .draft
        )
        mockShiftRepository.shiftsById[shiftId] = existingShift
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            startTime: shiftDate.addingHours(15) // After existing end time of 14:00
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Update draft shift fails with empty location")
    func updateDraftShiftFailsWithEmptyLocation() async throws {
        // Given
        let shiftId = "shift-1"
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, status: .draft
        )
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            location: ""
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 0)
    }
    
    @Test("Update draft shift fails with whitespace-only location")
    func updateDraftShiftFailsWithWhitespaceOnlyLocation() async throws {
        // Given
        let shiftId = "shift-1"
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, status: .draft
        )
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            location: "   "
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Repository Error Tests
    
    @Test("Update draft shift propagates repository error")
    func updateDraftShiftPropagatesRepositoryError() async throws {
        // Given
        let shiftId = "shift-1"
        mockShiftRepository.shiftsById[shiftId] = TestFixtures.createShift(
            id: shiftId, status: .draft
        )
        mockShiftRepository.updateShiftError = DomainError.networkError
        
        let request = UpdateShiftRequest(
            shiftId: shiftId,
            location: "New Location"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.updateShiftCallCount == 1)
    }
}
