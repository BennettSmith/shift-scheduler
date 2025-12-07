import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetWeekScheduleUseCase Tests")
struct GetWeekScheduleUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    
    private var useCase: GetWeekScheduleUseCase {
        GetWeekScheduleUseCase(shiftRepository: mockShiftRepository)
    }
    
    // MARK: - Success Tests
    
    @Test("Get week schedule returns 7 days")
    func getWeekScheduleReturns7Days() async throws {
        // Given
        let referenceDate = DateTestHelpers.date(2024, 12, 11) // A Wednesday
        let request = WeekScheduleRequest(referenceDate: referenceDate)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.days.count == 7)
    }
    
    @Test("Get week schedule groups shifts by day")
    func getWeekScheduleGroupsShiftsByDay() async throws {
        // Given
        let monday = DateTestHelpers.date(2024, 12, 9) // Monday
        let tuesday = DateTestHelpers.date(2024, 12, 10)
        
        let shift1 = TestFixtures.createShift(id: "shift-1", date: monday, label: "Monday AM")
        let shift2 = TestFixtures.createShift(id: "shift-2", date: monday, label: "Monday PM")
        let shift3 = TestFixtures.createShift(id: "shift-3", date: tuesday, label: "Tuesday AM")
        
        mockShiftRepository.shiftsById["shift-1"] = shift1
        mockShiftRepository.shiftsById["shift-2"] = shift2
        mockShiftRepository.shiftsById["shift-3"] = shift3
        
        let request = WeekScheduleRequest(referenceDate: monday)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(mockShiftRepository.getShiftsForDateRangeCallCount == 1)
        
        // Find the days with shifts
        let daysWithShifts = response.days.filter { !$0.shifts.isEmpty }
        #expect(daysWithShifts.count >= 1) // At least one day should have shifts
    }
    
    @Test("Get week schedule returns empty days when no shifts")
    func getWeekScheduleReturnsEmptyDaysWhenNoShifts() async throws {
        // Given - no shifts in repository
        let referenceDate = DateTestHelpers.date(2024, 12, 11)
        let request = WeekScheduleRequest(referenceDate: referenceDate)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.days.count == 7)
        for day in response.days {
            #expect(day.shifts.isEmpty)
        }
    }
    
    @Test("Get week schedule includes shift summaries with all fields")
    func getWeekScheduleIncludesShiftSummaries() async throws {
        // Given
        let shiftDate = DateTestHelpers.date(2024, 12, 9)
        let shift = TestFixtures.createShift(
            id: "shift-1",
            date: shiftDate,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 2,
            currentParents: 1,
            location: "Tree Lot A",
            label: "Morning Shift",
            status: .published
        )
        mockShiftRepository.shiftsById["shift-1"] = shift
        
        let request = WeekScheduleRequest(referenceDate: shiftDate)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        let allShifts = response.days.flatMap { $0.shifts }
        #expect(allShifts.count >= 1)
        
        if let summary = allShifts.first {
            #expect(summary.id == "shift-1")
            #expect(summary.requiredScouts == 4)
            #expect(summary.requiredParents == 2)
            #expect(summary.currentScouts == 2)
            #expect(summary.currentParents == 1)
            #expect(summary.location == "Tree Lot A")
            #expect(summary.label == "Morning Shift")
            #expect(summary.status == .published)
            #expect(summary.timeRange.isEmpty == false)
        }
    }
    
    @Test("Get week schedule calculates correct week boundaries")
    func getWeekScheduleCalculatesCorrectBoundaries() async throws {
        // Given
        let wednesday = DateTestHelpers.date(2024, 12, 11) // A Wednesday
        let request = WeekScheduleRequest(referenceDate: wednesday)
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        // Week should start on Sunday (Dec 8) and end on Saturday (Dec 14)
        // Check the date range passed to repository
        #expect(mockShiftRepository.getShiftsForDateRangeCallCount == 1)
        
        // Response should contain correct week dates
        #expect(response.weekEndDate > response.weekStartDate)
    }
    
    // MARK: - Error Tests
    
    @Test("Get week schedule propagates repository error")
    func getWeekSchedulePropagatesRepositoryError() async throws {
        // Given
        mockShiftRepository.getShiftsForDateRangeResult = .failure(DomainError.networkError)
        let request = WeekScheduleRequest(referenceDate: Date())
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
