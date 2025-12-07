import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("CreateShiftTemplateUseCase Tests")
struct CreateShiftTemplateUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockTemplateRepository = MockTemplateRepository()
    
    private var useCase: CreateShiftTemplateUseCase {
        CreateShiftTemplateUseCase(templateRepository: mockTemplateRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Create template succeeds with valid input")
    func createTemplateSucceedsWithValidInput() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot A",
            label: "Morning",
            notes: "Opening shift"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.name == "Morning Shift")
        #expect(response.requiredScouts == 4)
        #expect(response.requiredParents == 2)
        #expect(response.location == "Tree Lot A")
        #expect(response.label == "Morning")
        #expect(response.notes == "Opening shift")
        #expect(response.isActive == true)
        #expect(mockTemplateRepository.createTemplateCallCount == 1)
        #expect(mockTemplateRepository.getTemplateCallCount == 1) // Fetched after create
    }
    
    @Test("Create template succeeds with minimal input")
    func createTemplateSucceedsWithMinimalInput() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Basic Shift",
            startTime: DateTestHelpers.time(10, 0),
            endTime: DateTestHelpers.time(14, 0),
            requiredScouts: 2,
            requiredParents: 1,
            location: "Main Lot"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.name == "Basic Shift")
        #expect(response.label == nil)
        #expect(response.notes == nil)
    }
    
    @Test("Create template trims whitespace from inputs")
    func createTemplateTrimsWhitespace() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "  Padded Name  ",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 3,
            requiredParents: 1,
            location: "  Location  ",
            label: "  Label  ",
            notes: "  Notes  "
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.name == "Padded Name")
        #expect(response.location == "Location")
        #expect(response.label == "Label")
        #expect(response.notes == "Notes")
    }
    
    @Test("Create template allows zero required scouts")
    func createTemplateAllowsZeroScouts() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Parent Only Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(11, 0),
            requiredScouts: 0,
            requiredParents: 2,
            location: "Tree Lot"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.requiredScouts == 0)
        #expect(response.requiredParents == 2)
    }
    
    // MARK: - Validation Error Tests
    
    @Test("Create template fails with empty name")
    func createTemplateFailsWithEmptyName() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.createTemplateCallCount == 0)
    }
    
    @Test("Create template fails with whitespace-only name")
    func createTemplateFailsWithWhitespaceOnlyName() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "   ",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Create template fails with negative required scouts")
    func createTemplateFailsWithNegativeScouts() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: -1,
            requiredParents: 2,
            location: "Tree Lot"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.createTemplateCallCount == 0)
    }
    
    @Test("Create template fails with negative required parents")
    func createTemplateFailsWithNegativeParents() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: -1,
            location: "Tree Lot"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.createTemplateCallCount == 0)
    }
    
    @Test("Create template fails when end time equals start time")
    func createTemplateFailsWhenEndTimeEqualsStartTime() async throws {
        // Given
        let sameTime = DateTestHelpers.time(9, 0)
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: sameTime,
            endTime: sameTime,
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Create template fails when end time is before start time")
    func createTemplateFailsWhenEndTimeBeforeStartTime() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: DateTestHelpers.time(13, 0),
            endTime: DateTestHelpers.time(9, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.createTemplateCallCount == 0)
    }
    
    @Test("Create template fails with empty location")
    func createTemplateFailsWithEmptyLocation() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: ""
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.createTemplateCallCount == 0)
    }
    
    @Test("Create template fails with whitespace-only location")
    func createTemplateFailsWithWhitespaceOnlyLocation() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "   "
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Repository Error Tests
    
    @Test("Create template propagates repository create error")
    func createTemplatePropagatesCreateError() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot"
        )
        mockTemplateRepository.createTemplateResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.createTemplateCallCount == 1)
    }
    
    @Test("Create template propagates repository fetch error after create")
    func createTemplatePropagatesFetchError() async throws {
        // Given
        let request = CreateShiftTemplateRequest(
            name: "Morning Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot"
        )
        // Allow create to succeed but fail on fetch
        mockTemplateRepository.getTemplateResult = .failure(DomainError.templateNotFound)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockTemplateRepository.createTemplateCallCount == 1)
        #expect(mockTemplateRepository.getTemplateCallCount == 1)
    }
}
