import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetShiftTemplatesUseCase Tests")
struct GetShiftTemplatesUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockTemplateRepository = MockTemplateRepository()
    
    private var useCase: GetShiftTemplatesUseCase {
        GetShiftTemplatesUseCase(templateRepository: mockTemplateRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Get templates returns empty list when no templates exist")
    func getTemplatesReturnsEmptyWhenNoTemplates() async throws {
        // Given - no templates in repository
        
        // When
        let templates = try await useCase.execute(includeInactive: false)
        
        // Then
        #expect(templates.isEmpty)
        #expect(mockTemplateRepository.getActiveTemplatesCallCount == 1)
    }
    
    @Test("Get active templates only returns active templates")
    func getActiveTemplatesOnlyReturnsActive() async throws {
        // Given
        let activeTemplate = TestFixtures.createTemplate(
            id: "template-1",
            name: "Morning Shift",
            isActive: true
        )
        let inactiveTemplate = TestFixtures.createTemplate(
            id: "template-2",
            name: "Evening Shift",
            isActive: false
        )
        
        mockTemplateRepository.templatesById["template-1"] = activeTemplate
        mockTemplateRepository.templatesById["template-2"] = inactiveTemplate
        
        // When
        let templates = try await useCase.execute(includeInactive: false)
        
        // Then
        #expect(templates.count == 1)
        #expect(templates[0].id == "template-1")
        #expect(templates[0].isActive == true)
        #expect(mockTemplateRepository.getActiveTemplatesCallCount == 1)
        #expect(mockTemplateRepository.getAllTemplatesCallCount == 0)
    }
    
    @Test("Get all templates includes inactive templates")
    func getAllTemplatesIncludesInactive() async throws {
        // Given
        let activeTemplate = TestFixtures.createTemplate(
            id: "template-1",
            name: "Morning Shift",
            isActive: true
        )
        let inactiveTemplate = TestFixtures.createTemplate(
            id: "template-2",
            name: "Evening Shift",
            isActive: false
        )
        
        mockTemplateRepository.templatesById["template-1"] = activeTemplate
        mockTemplateRepository.templatesById["template-2"] = inactiveTemplate
        
        // When
        let templates = try await useCase.execute(includeInactive: true)
        
        // Then
        #expect(templates.count == 2)
        #expect(mockTemplateRepository.getAllTemplatesCallCount == 1)
        #expect(mockTemplateRepository.getActiveTemplatesCallCount == 0)
    }
    
    @Test("Get templates returns sorted by name")
    func getTemplatesReturnsSortedByName() async throws {
        // Given
        let templateZ = TestFixtures.createTemplate(id: "z-template", name: "Zebra Shift")
        let templateA = TestFixtures.createTemplate(id: "a-template", name: "Alpha Shift")
        let templateM = TestFixtures.createTemplate(id: "m-template", name: "Morning Shift")
        
        mockTemplateRepository.templatesById["z-template"] = templateZ
        mockTemplateRepository.templatesById["a-template"] = templateA
        mockTemplateRepository.templatesById["m-template"] = templateM
        
        // When
        let templates = try await useCase.execute(includeInactive: true)
        
        // Then
        #expect(templates.count == 3)
        #expect(templates[0].name == "Alpha Shift")
        #expect(templates[1].name == "Morning Shift")
        #expect(templates[2].name == "Zebra Shift")
    }
    
    @Test("Get templates maps all fields correctly")
    func getTemplatesMapsAllFields() async throws {
        // Given
        let startTime = DateTestHelpers.time(9, 0)
        let endTime = DateTestHelpers.time(13, 0)
        let createdAt = Date()
        let updatedAt = Date()
        
        let template = TestFixtures.createTemplate(
            id: "template-1",
            name: "Morning Shift",
            startTime: startTime,
            endTime: endTime,
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot A",
            label: "Morning",
            notes: "Busy shift",
            isActive: true,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
        
        mockTemplateRepository.templatesById["template-1"] = template
        
        // When
        let templates = try await useCase.execute(includeInactive: false)
        
        // Then
        #expect(templates.count == 1)
        let result = templates[0]
        #expect(result.id == "template-1")
        #expect(result.name == "Morning Shift")
        #expect(result.startTime == startTime)
        #expect(result.endTime == endTime)
        #expect(result.requiredScouts == 4)
        #expect(result.requiredParents == 2)
        #expect(result.location == "Tree Lot A")
        #expect(result.label == "Morning")
        #expect(result.notes == "Busy shift")
        #expect(result.isActive == true)
        #expect(result.createdAt == createdAt)
        #expect(result.updatedAt == updatedAt)
    }
    
    // MARK: - Error Tests
    
    @Test("Get templates propagates repository error")
    func getTemplatesPropagatesError() async throws {
        // Given
        mockTemplateRepository.getActiveTemplatesResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(includeInactive: false)
        }
    }
    
    @Test("Get all templates propagates repository error")
    func getAllTemplatesPropagatesError() async throws {
        // Given
        mockTemplateRepository.getAllTemplatesResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(includeInactive: true)
        }
    }
}
