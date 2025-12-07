import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("UpdateShiftTemplateUseCase Tests")
struct UpdateShiftTemplateUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockTemplateRepository = MockTemplateRepository()
    
    private var useCase: UpdateShiftTemplateUseCase {
        UpdateShiftTemplateUseCase(templateRepository: mockTemplateRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Update template succeeds with all fields changed")
    func updateTemplateSucceedsWithAllFieldsChanged() async throws {
        // Given
        let templateId = "template-1"
        let existingTemplate = TestFixtures.createTemplate(
            id: templateId,
            name: "Old Name",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Old Location"
        )
        mockTemplateRepository.templatesById[templateId] = existingTemplate
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            name: "New Name",
            startTime: DateTestHelpers.time(10, 0),
            endTime: DateTestHelpers.time(14, 0),
            requiredScouts: 6,
            requiredParents: 3,
            location: "New Location",
            label: "Updated Label",
            notes: "Updated Notes",
            isActive: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.id == templateId)
        #expect(response.name == "New Name")
        #expect(response.requiredScouts == 6)
        #expect(response.requiredParents == 3)
        #expect(response.location == "New Location")
        #expect(response.label == "Updated Label")
        #expect(response.notes == "Updated Notes")
        #expect(response.isActive == false)
        #expect(mockTemplateRepository.getTemplateCallCount == 1)
        #expect(mockTemplateRepository.updateTemplateCallCount == 1)
    }
    
    @Test("Update template succeeds with partial changes")
    func updateTemplateSucceedsWithPartialChanges() async throws {
        // Given
        let templateId = "template-1"
        let existingTemplate = TestFixtures.createTemplate(
            id: templateId,
            name: "Original Name",
            requiredScouts: 4,
            requiredParents: 2,
            location: "Original Location"
        )
        mockTemplateRepository.templatesById[templateId] = existingTemplate
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            name: "Updated Name"
            // All other fields remain nil (unchanged)
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.name == "Updated Name")
        #expect(response.requiredScouts == 4) // Preserved
        #expect(response.requiredParents == 2) // Preserved
        #expect(response.location == "Original Location") // Preserved
    }
    
    @Test("Update template preserves original createdAt timestamp")
    func updateTemplatePreservesCreatedAt() async throws {
        // Given
        let templateId = "template-1"
        let createdAt = DateTestHelpers.date(2024, 1, 1)
        let existingTemplate = TestFixtures.createTemplate(
            id: templateId,
            createdAt: createdAt
        )
        mockTemplateRepository.templatesById[templateId] = existingTemplate
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            name: "Updated Name"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.createdAt == createdAt)
        #expect(response.updatedAt != createdAt) // updatedAt should be newer
    }
    
    @Test("Update template deactivates template")
    func updateTemplateDeactivatesTemplate() async throws {
        // Given
        let templateId = "template-1"
        let existingTemplate = TestFixtures.createTemplate(
            id: templateId,
            isActive: true
        )
        mockTemplateRepository.templatesById[templateId] = existingTemplate
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            isActive: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.isActive == false)
    }
    
    // MARK: - Validation Error Tests
    
    @Test("Update template fails for non-existent template")
    func updateTemplateFailsForNonExistentTemplate() async throws {
        // Given
        let request = UpdateShiftTemplateRequest(
            templateId: "non-existent",
            name: "New Name"
        )
        // Template not in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 0)
    }
    
    @Test("Update template fails with negative required scouts")
    func updateTemplateFailsWithNegativeScouts() async throws {
        // Given
        let templateId = "template-1"
        mockTemplateRepository.templatesById[templateId] = TestFixtures.createTemplate(id: templateId)
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            requiredScouts: -1
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 0)
    }
    
    @Test("Update template fails with negative required parents")
    func updateTemplateFailsWithNegativeParents() async throws {
        // Given
        let templateId = "template-1"
        mockTemplateRepository.templatesById[templateId] = TestFixtures.createTemplate(id: templateId)
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            requiredParents: -1
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 0)
    }
    
    @Test("Update template fails when both times provided and end before start")
    func updateTemplateFailsWhenBothTimesProvidedEndBeforeStart() async throws {
        // Given
        let templateId = "template-1"
        mockTemplateRepository.templatesById[templateId] = TestFixtures.createTemplate(id: templateId)
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            startTime: DateTestHelpers.time(14, 0),
            endTime: DateTestHelpers.time(10, 0)
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 0)
    }
    
    @Test("Update template fails when new end time before existing start time")
    func updateTemplateFailsWhenNewEndBeforeExistingStart() async throws {
        // Given
        let templateId = "template-1"
        let existingTemplate = TestFixtures.createTemplate(
            id: templateId,
            startTime: DateTestHelpers.time(10, 0),
            endTime: DateTestHelpers.time(14, 0)
        )
        mockTemplateRepository.templatesById[templateId] = existingTemplate
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            endTime: DateTestHelpers.time(9, 0) // Before existing start time of 10:00
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 0)
    }
    
    @Test("Update template fails when new start time after existing end time")
    func updateTemplateFailsWhenNewStartAfterExistingEnd() async throws {
        // Given
        let templateId = "template-1"
        let existingTemplate = TestFixtures.createTemplate(
            id: templateId,
            startTime: DateTestHelpers.time(10, 0),
            endTime: DateTestHelpers.time(14, 0)
        )
        mockTemplateRepository.templatesById[templateId] = existingTemplate
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            startTime: DateTestHelpers.time(15, 0) // After existing end time of 14:00
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 0)
    }
    
    @Test("Update template fails with empty name")
    func updateTemplateFailsWithEmptyName() async throws {
        // Given
        let templateId = "template-1"
        mockTemplateRepository.templatesById[templateId] = TestFixtures.createTemplate(id: templateId)
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            name: ""
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 0)
    }
    
    @Test("Update template fails with whitespace-only name")
    func updateTemplateFailsWithWhitespaceOnlyName() async throws {
        // Given
        let templateId = "template-1"
        mockTemplateRepository.templatesById[templateId] = TestFixtures.createTemplate(id: templateId)
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            name: "   "
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Update template fails with empty location")
    func updateTemplateFailsWithEmptyLocation() async throws {
        // Given
        let templateId = "template-1"
        mockTemplateRepository.templatesById[templateId] = TestFixtures.createTemplate(id: templateId)
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            location: ""
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 0)
    }
    
    // MARK: - Repository Error Tests
    
    @Test("Update template propagates repository error")
    func updateTemplatePropagatesRepositoryError() async throws {
        // Given
        let templateId = "template-1"
        mockTemplateRepository.templatesById[templateId] = TestFixtures.createTemplate(id: templateId)
        mockTemplateRepository.updateTemplateError = DomainError.networkError
        
        let request = UpdateShiftTemplateRequest(
            templateId: templateId,
            name: "New Name"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.updateTemplateCallCount == 1)
    }
}
