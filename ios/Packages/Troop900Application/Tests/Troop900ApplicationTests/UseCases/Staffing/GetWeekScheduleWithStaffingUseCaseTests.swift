import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetWeekScheduleWithStaffingUseCase Tests")
struct GetWeekScheduleWithStaffingUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: GetWeekScheduleWithStaffingUseCase {
        GetWeekScheduleWithStaffingUseCase(
            shiftRepository: mockShiftRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Helper
    
    /// Gets a date that falls on a specific day within the week of the reference date.
    /// Uses the same calculation as the use case to ensure date matching.
    private func dateInWeek(referenceDate: Date, dayOffset: Int) -> Date {
        let calendar = Calendar.current
        let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate))!
        return calendar.date(byAdding: .day, value: dayOffset, to: weekStartDate)!
    }
    
    // MARK: - Permission Tests
    
    @Test("Get week schedule succeeds for committee member")
    func getWeekScheduleSucceedsForCommittee() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let request = WeekScheduleRequest(referenceDate: Date())
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        #expect(response.days.count == 7)
        #expect(mockShiftRepository.getShiftsForDateRangeCallCount == 1)
    }
    
    @Test("Get week schedule fails for non-committee user")
    func getWeekScheduleFailsForNonCommittee() async throws {
        // Given
        let parentId = "parent-1"
        let parentUser = TestFixtures.createParent(id: parentId)
        mockUserRepository.usersById[parentId] = parentUser
        
        let request = WeekScheduleRequest(referenceDate: Date())
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request, requestingUserId: parentId)
        }
        #expect(mockShiftRepository.getShiftsForDateRangeCallCount == 0)
    }
    
    // MARK: - Week Calculation Tests
    
    @Test("Get week schedule returns 7 days")
    func getWeekScheduleReturnsSevenDays() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let request = WeekScheduleRequest(referenceDate: Date())
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        #expect(response.days.count == 7)
        
        // Verify days are consecutive
        let calendar = Calendar.current
        for i in 1..<response.days.count {
            let previousDay = response.days[i - 1].date
            let currentDay = response.days[i].date
            let daysDiff = calendar.dateComponents([.day], from: previousDay, to: currentDay).day
            #expect(daysDiff == 1)
        }
    }
    
    @Test("Get week schedule calculates correct week range")
    func getWeekScheduleCalculatesCorrectRange() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let request = WeekScheduleRequest(referenceDate: Date())
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        let calendar = Calendar.current
        let daysBetween = calendar.dateComponents([.day], from: response.weekStartDate, to: response.weekEndDate).day
        #expect(daysBetween == 6) // Sunday to Saturday = 6 days difference
    }
    
    // MARK: - Staffing Statistics Tests
    
    @Test("Get week schedule counts critical shifts correctly")
    func getWeekScheduleCountsCriticalShifts() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let referenceDate = Date()
        let shiftDate = dateInWeek(referenceDate: referenceDate, dayOffset: 2) // Tuesday
        
        // Critical shift (< 50% staffed)
        let criticalShift = TestFixtures.createShift(
            id: "critical",
            date: shiftDate,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 1,
            currentParents: 0,
            status: .published
        )
        mockShiftRepository.getShiftsForDateRangeResult = .success([criticalShift])
        
        let request = WeekScheduleRequest(referenceDate: referenceDate)
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        #expect(response.criticalShifts == 1)
        #expect(response.totalShifts == 1)
    }
    
    @Test("Get week schedule counts low staffing shifts correctly")
    func getWeekScheduleCountsLowShifts() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let referenceDate = Date()
        let shiftDate = dateInWeek(referenceDate: referenceDate, dayOffset: 3) // Wednesday
        
        // Low staffing shift (50-80% staffed)
        let lowShift = TestFixtures.createShift(
            id: "low",
            date: shiftDate,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 3,
            currentParents: 1,
            status: .published
        )
        mockShiftRepository.getShiftsForDateRangeResult = .success([lowShift])
        
        let request = WeekScheduleRequest(referenceDate: referenceDate)
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        #expect(response.lowStaffingShifts == 1)
        #expect(response.criticalShifts == 0)
    }
    
    @Test("Get week schedule counts fully staffed shifts correctly")
    func getWeekScheduleCountsFullyStaffedShifts() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let referenceDate = Date()
        let shiftDate = dateInWeek(referenceDate: referenceDate, dayOffset: 4) // Thursday
        
        // Fully staffed shift
        let fullShift = TestFixtures.createShift(
            id: "full",
            date: shiftDate,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 4,
            currentParents: 2,
            status: .published
        )
        mockShiftRepository.getShiftsForDateRangeResult = .success([fullShift])
        
        let request = WeekScheduleRequest(referenceDate: referenceDate)
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        #expect(response.fullyStaffedShifts == 1)
        #expect(response.criticalShifts == 0)
        #expect(response.lowStaffingShifts == 0)
    }
    
    @Test("Get week schedule returns correct statistics for mixed shifts")
    func getWeekScheduleReturnsMixedStatistics() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let referenceDate = Date()
        let tuesdayDate = dateInWeek(referenceDate: referenceDate, dayOffset: 2)
        let wednesdayDate = dateInWeek(referenceDate: referenceDate, dayOffset: 3)
        let thursdayDate = dateInWeek(referenceDate: referenceDate, dayOffset: 4)
        
        let criticalShift = TestFixtures.createShift(
            id: "critical",
            date: tuesdayDate,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            status: .published
        )
        let lowShift = TestFixtures.createShift(
            id: "low",
            date: wednesdayDate,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 3,
            currentParents: 1,
            status: .published
        )
        let fullShift = TestFixtures.createShift(
            id: "full",
            date: thursdayDate,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 4,
            currentParents: 2,
            status: .published
        )
        
        mockShiftRepository.getShiftsForDateRangeResult = .success([criticalShift, lowShift, fullShift])
        
        let request = WeekScheduleRequest(referenceDate: referenceDate)
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        #expect(response.totalShifts == 3)
        #expect(response.criticalShifts == 1)
        #expect(response.lowStaffingShifts == 1)
        #expect(response.fullyStaffedShifts == 1)
    }
    
    // MARK: - Shift Summary Tests
    
    @Test("Get week schedule calculates open slots correctly")
    func getWeekScheduleCalculatesOpenSlots() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let referenceDate = Date()
        let shiftDate = dateInWeek(referenceDate: referenceDate, dayOffset: 2)
        
        let shift = TestFixtures.createShift(
            id: "shift-1",
            date: shiftDate,
            requiredScouts: 6,
            requiredParents: 4,
            currentScouts: 2,
            currentParents: 1,
            status: .published
        )
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        
        let request = WeekScheduleRequest(referenceDate: referenceDate)
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        let shiftSummary = response.days.flatMap { $0.shifts }.first { $0.id == "shift-1" }
        #expect(shiftSummary != nil)
        #expect(shiftSummary?.openSlots == 7) // (6-2) + (4-1) = 4 + 3 = 7
    }
    
    @Test("Get week schedule includes staffing level for each role")
    func getWeekScheduleIncludesRoleStaffingLevels() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let referenceDate = Date()
        let shiftDate = dateInWeek(referenceDate: referenceDate, dayOffset: 3)
        
        // Scouts fully staffed, parents critically understaffed
        let shift = TestFixtures.createShift(
            id: "mixed-shift",
            date: shiftDate,
            requiredScouts: 4,
            requiredParents: 4,
            currentScouts: 4,
            currentParents: 1,
            status: .published
        )
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        
        let request = WeekScheduleRequest(referenceDate: referenceDate)
        
        // When
        let response = try await useCase.execute(request: request, requestingUserId: committeeId)
        
        // Then
        let shiftSummary = response.days.flatMap { $0.shifts }.first { $0.id == "mixed-shift" }
        #expect(shiftSummary != nil)
        #expect(shiftSummary?.scoutStaffingLevel == .full)
        #expect(shiftSummary?.parentStaffingLevel == .critical)
        // Overall should be the worst (critical)
        #expect(shiftSummary?.overallStaffingLevel == .critical)
    }
    
    // MARK: - Error Tests
    
    @Test("Get week schedule fails when user not found")
    func getWeekScheduleFailsWhenUserNotFound() async throws {
        // Given
        let request = WeekScheduleRequest(referenceDate: Date())
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request, requestingUserId: "non-existent")
        }
    }
    
    @Test("Get week schedule propagates repository error")
    func getWeekSchedulePropagatesError() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        mockShiftRepository.getShiftsForDateRangeResult = .failure(DomainError.networkError)
        
        let request = WeekScheduleRequest(referenceDate: Date())
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request, requestingUserId: committeeId)
        }
    }
}
