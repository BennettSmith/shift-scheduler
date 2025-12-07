import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GenerateSeasonScheduleUseCase Tests")
struct GenerateSeasonScheduleUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockTemplateRepository = MockTemplateRepository()
    private let mockSeasonRepository = MockSeasonRepository()
    
    private var useCase: GenerateSeasonScheduleUseCase {
        GenerateSeasonScheduleUseCase(
            shiftRepository: mockShiftRepository,
            templateRepository: mockTemplateRepository,
            seasonRepository: mockSeasonRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Generate schedule creates shifts for date range with single template")
    func generateScheduleCreatesShiftsForDateRange() async throws {
        // Given
        let template = TestFixtures.createTemplate(
            id: "template-1",
            name: "Morning Shift",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2,
            location: "Tree Lot A"
        )
        mockTemplateRepository.templatesById["template-1"] = template
        
        // 3-day range
        let startDate = DateTestHelpers.date(2024, 12, 1)
        let endDate = DateTestHelpers.date(2024, 12, 3)
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: startDate,
            endDate: endDate,
            defaultLocation: "Tree Lot A",
            templateIds: ["template-1"]
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.seasonId == "season-1")
        #expect(response.totalShiftsCreated == 3) // One shift per day
        #expect(response.datesWithShifts == 3)
        #expect(response.specialEventCount == 0)
        #expect(mockShiftRepository.createShiftCallCount == 3)
        
        // All shifts should be draft
        for shift in mockShiftRepository.createShiftCalledWith {
            #expect(shift.status == .draft)
            #expect(shift.seasonId == "season-1")
            #expect(shift.templateId == "template-1")
        }
    }
    
    @Test("Generate schedule creates multiple shifts per day with multiple templates")
    func generateScheduleCreatesMultipleShiftsPerDay() async throws {
        // Given
        let morningTemplate = TestFixtures.createTemplate(
            id: "morning",
            name: "Morning",
            startTime: DateTestHelpers.time(9, 0),
            endTime: DateTestHelpers.time(13, 0),
            requiredScouts: 4,
            requiredParents: 2
        )
        let afternoonTemplate = TestFixtures.createTemplate(
            id: "afternoon",
            name: "Afternoon",
            startTime: DateTestHelpers.time(14, 0),
            endTime: DateTestHelpers.time(18, 0),
            requiredScouts: 4,
            requiredParents: 2
        )
        mockTemplateRepository.templatesById["morning"] = morningTemplate
        mockTemplateRepository.templatesById["afternoon"] = afternoonTemplate
        
        // 2-day range with 2 templates = 4 shifts
        let startDate = DateTestHelpers.date(2024, 12, 1)
        let endDate = DateTestHelpers.date(2024, 12, 2)
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: startDate,
            endDate: endDate,
            defaultLocation: "Tree Lot",
            templateIds: ["morning", "afternoon"]
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.totalShiftsCreated == 4) // 2 days × 2 templates
        #expect(response.datesWithShifts == 2)
        #expect(mockShiftRepository.createShiftCallCount == 4)
    }
    
    @Test("Generate schedule excludes specified dates")
    func generateScheduleExcludesDates() async throws {
        // Given
        let template = TestFixtures.createTemplate(id: "template-1")
        mockTemplateRepository.templatesById["template-1"] = template
        
        let startDate = DateTestHelpers.date(2024, 12, 1)
        let endDate = DateTestHelpers.date(2024, 12, 5)
        let excludedDate = DateTestHelpers.date(2024, 12, 3)
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: startDate,
            endDate: endDate,
            defaultLocation: "Tree Lot",
            templateIds: ["template-1"],
            excludedDates: [excludedDate]
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.totalShiftsCreated == 4) // 5 days - 1 excluded = 4
        #expect(response.datesWithShifts == 4)
    }
    
    @Test("Generate schedule handles special events")
    func generateScheduleHandlesSpecialEvents() async throws {
        // Given
        let regularTemplate = TestFixtures.createTemplate(
            id: "regular",
            name: "Regular Shift",
            requiredScouts: 4,
            requiredParents: 2
        )
        let specialTemplate = TestFixtures.createTemplate(
            id: "special",
            name: "Special Event",
            requiredScouts: 8,
            requiredParents: 4
        )
        mockTemplateRepository.templatesById["regular"] = regularTemplate
        mockTemplateRepository.templatesById["special"] = specialTemplate
        
        let startDate = DateTestHelpers.date(2024, 12, 1)
        let endDate = DateTestHelpers.date(2024, 12, 3)
        let specialEventDate = DateTestHelpers.date(2024, 12, 2)
        
        let specialEvent = SpecialEventConfig(
            date: specialEventDate,
            templateId: "special",
            label: "Tree Delivery Day",
            notes: "Extra volunteers needed"
        )
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: startDate,
            endDate: endDate,
            defaultLocation: "Tree Lot",
            templateIds: ["regular", "special"], // Both templates available
            specialEventDates: [specialEvent]
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        // Day 1: 2 shifts (regular + special templates, no special event)
        // Day 2: 1 shift (special event overrides regular, uses special template with custom label)
        // Day 3: 2 shifts (regular + special templates, no special event)
        // Total: 5 shifts, with 1 being a special event
        #expect(response.totalShiftsCreated == 5)
        #expect(response.specialEventCount == 1)
        #expect(response.datesWithShifts == 3)
        
        // Verify the special event day has the correct label
        let shiftsWithSpecialLabel = mockShiftRepository.createShiftCalledWith.filter {
            $0.label == "Tree Delivery Day"
        }
        #expect(shiftsWithSpecialLabel.count == 1)
        #expect(shiftsWithSpecialLabel[0].templateId == "special")
    }
    
    @Test("Generate schedule skips inactive templates")
    func generateScheduleSkipsInactiveTemplates() async throws {
        // Given
        let activeTemplate = TestFixtures.createTemplate(
            id: "active",
            isActive: true
        )
        let inactiveTemplate = TestFixtures.createTemplate(
            id: "inactive",
            isActive: false
        )
        mockTemplateRepository.templatesById["active"] = activeTemplate
        mockTemplateRepository.templatesById["inactive"] = inactiveTemplate
        
        let startDate = DateTestHelpers.date(2024, 12, 1)
        let endDate = DateTestHelpers.date(2024, 12, 2)
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: startDate,
            endDate: endDate,
            defaultLocation: "Tree Lot",
            templateIds: ["active", "inactive"]
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.totalShiftsCreated == 2) // Only active template, 2 days
        
        // All shifts should reference the active template
        for shift in mockShiftRepository.createShiftCalledWith {
            #expect(shift.templateId == "active")
        }
    }
    
    @Test("Generate schedule calculates correct volunteer slots")
    func generateScheduleCalculatesVolunteerSlots() async throws {
        // Given
        let template = TestFixtures.createTemplate(
            id: "template-1",
            requiredScouts: 4,
            requiredParents: 2 // 6 volunteers per shift
        )
        mockTemplateRepository.templatesById["template-1"] = template
        
        let startDate = DateTestHelpers.date(2024, 12, 1)
        let endDate = DateTestHelpers.date(2024, 12, 3) // 3 days
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: startDate,
            endDate: endDate,
            defaultLocation: "Tree Lot",
            templateIds: ["template-1"]
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.totalShiftsCreated == 3)
        #expect(response.totalVolunteerSlots == 18) // 3 shifts × (4 + 2) = 18
    }
    
    @Test("Generate schedule creates shifts as draft status")
    func generateScheduleCreatesShiftsAsDraft() async throws {
        // Given
        let template = TestFixtures.createTemplate(id: "template-1")
        mockTemplateRepository.templatesById["template-1"] = template
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: DateTestHelpers.date(2024, 12, 1),
            endDate: DateTestHelpers.date(2024, 12, 2), // Must be after start date
            defaultLocation: "Tree Lot",
            templateIds: ["template-1"]
        )
        
        // When
        _ = try await useCase.execute(request: request)
        
        // Then - all created shifts should be draft
        #expect(mockShiftRepository.createShiftCallCount >= 1)
        for createdShift in mockShiftRepository.createShiftCalledWith {
            #expect(createdShift.status == .draft)
        }
    }
    
    // MARK: - Validation Error Tests
    
    @Test("Generate schedule fails when end date before start date")
    func generateScheduleFailsWhenEndBeforeStart() async throws {
        // Given
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: DateTestHelpers.date(2024, 12, 10),
            endDate: DateTestHelpers.date(2024, 12, 1),
            defaultLocation: "Tree Lot",
            templateIds: ["template-1"]
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.createShiftCallCount == 0)
    }
    
    @Test("Generate schedule fails with no valid templates")
    func generateScheduleFailsWithNoValidTemplates() async throws {
        // Given - no templates in repository
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: DateTestHelpers.date(2024, 12, 1),
            endDate: DateTestHelpers.date(2024, 12, 3),
            defaultLocation: "Tree Lot",
            templateIds: ["non-existent-1", "non-existent-2"]
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.createShiftCallCount == 0)
    }
    
    @Test("Generate schedule fails when all templates are inactive")
    func generateScheduleFailsWhenAllTemplatesInactive() async throws {
        // Given
        let inactiveTemplate = TestFixtures.createTemplate(
            id: "inactive",
            isActive: false
        )
        mockTemplateRepository.templatesById["inactive"] = inactiveTemplate
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: DateTestHelpers.date(2024, 12, 1),
            endDate: DateTestHelpers.date(2024, 12, 3),
            defaultLocation: "Tree Lot",
            templateIds: ["inactive"]
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftRepository.createShiftCallCount == 0)
    }
    
    // MARK: - Repository Error Tests
    
    @Test("Generate schedule propagates repository error")
    func generateSchedulePropagatesRepositoryError() async throws {
        // Given
        let template = TestFixtures.createTemplate(id: "template-1")
        mockTemplateRepository.templatesById["template-1"] = template
        mockShiftRepository.createShiftResult = .failure(DomainError.networkError)
        
        let request = GenerateSeasonScheduleRequest(
            seasonId: "season-1",
            seasonName: "2024 Season",
            startDate: DateTestHelpers.date(2024, 12, 1),
            endDate: DateTestHelpers.date(2024, 12, 1),
            defaultLocation: "Tree Lot",
            templateIds: ["template-1"]
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
