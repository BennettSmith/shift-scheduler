import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetStaffingAlertsUseCase Tests")
struct GetStaffingAlertsUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: GetStaffingAlertsUseCase {
        GetStaffingAlertsUseCase(
            shiftRepository: mockShiftRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Permission Tests
    
    @Test("Get staffing alerts succeeds for committee member")
    func getStaffingAlertsSucceedsForCommittee() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        // When
        let response = try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        
        // Then
        #expect(response.totalAlerts == 0)
        #expect(mockShiftRepository.getShiftsForDateRangeCallCount == 1)
    }
    
    @Test("Get staffing alerts fails for non-committee user")
    func getStaffingAlertsFailsForNonCommittee() async throws {
        // Given
        let parentId = "parent-1"
        let parentUser = TestFixtures.createParent(id: parentId)
        mockUserRepository.usersById[parentId] = parentUser
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(daysAhead: 7, requestingUserId: parentId)
        }
        #expect(mockShiftRepository.getShiftsForDateRangeCallCount == 0)
    }
    
    @Test("Get staffing alerts fails for scout user")
    func getStaffingAlertsFailsForScout() async throws {
        // Given
        let scoutId = "scout-1"
        let scoutUser = TestFixtures.createScout(id: scoutId)
        mockUserRepository.usersById[scoutId] = scoutUser
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(daysAhead: 7, requestingUserId: scoutId)
        }
    }
    
    // MARK: - Staffing Level Tests
    
    @Test("Get staffing alerts identifies critical understaffing")
    func getStaffingAlertsIdentifiesCritical() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        // Critical: < 50% staffed (0 of 4 scouts, 0 of 2 parents)
        let criticalShift = TestFixtures.createShift(
            id: "critical-shift",
            date: DateTestHelpers.tomorrow,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            status: .published
        )
        mockShiftRepository.shiftsById["critical-shift"] = criticalShift
        
        // When
        let response = try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        
        // Then
        #expect(response.criticalAlerts.count == 1)
        #expect(response.lowStaffingAlerts.count == 0)
        #expect(response.criticalAlerts[0].shiftId == "critical-shift")
        #expect(response.criticalAlerts[0].staffingLevel == .critical)
    }
    
    @Test("Get staffing alerts identifies low staffing")
    func getStaffingAlertsIdentifiesLow() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        // Low: 50-80% staffed (3 of 4 scouts = 75%, 1 of 2 parents = 50%)
        let lowShift = TestFixtures.createShift(
            id: "low-shift",
            date: DateTestHelpers.tomorrow,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 3,
            currentParents: 1,
            status: .published
        )
        mockShiftRepository.shiftsById["low-shift"] = lowShift
        
        // When
        let response = try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        
        // Then
        #expect(response.criticalAlerts.count == 0)
        #expect(response.lowStaffingAlerts.count == 1)
        #expect(response.lowStaffingAlerts[0].shiftId == "low-shift")
        #expect(response.lowStaffingAlerts[0].staffingLevel == .low)
    }
    
    @Test("Get staffing alerts excludes fully staffed shifts")
    func getStaffingAlertsExcludesFullyStaffed() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        // Fully staffed
        let fullShift = TestFixtures.createShift(
            id: "full-shift",
            date: DateTestHelpers.tomorrow,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 4,
            currentParents: 2,
            status: .published
        )
        mockShiftRepository.shiftsById["full-shift"] = fullShift
        
        // When
        let response = try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        
        // Then
        #expect(response.criticalAlerts.isEmpty)
        #expect(response.lowStaffingAlerts.isEmpty)
        #expect(response.totalAlerts == 0)
    }
    
    @Test("Get staffing alerts excludes adequately staffed shifts")
    func getStaffingAlertsExcludesAdequatelyStaffed() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        // OK: 80-100% staffed (4 of 4 scouts, 2 of 3 parents = 67% is actually low, let's do 4 of 5 = 80%)
        let okShift = TestFixtures.createShift(
            id: "ok-shift",
            date: DateTestHelpers.tomorrow,
            requiredScouts: 5,
            requiredParents: 5,
            currentScouts: 4,
            currentParents: 4,
            status: .published
        )
        mockShiftRepository.shiftsById["ok-shift"] = okShift
        
        // When
        let response = try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        
        // Then
        #expect(response.totalAlerts == 0)
    }
    
    // MARK: - Filtering Tests
    
    @Test("Get staffing alerts excludes draft shifts")
    func getStaffingAlertsExcludesDraftShifts() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        // Draft shift (understaffed but should be excluded)
        let draftShift = TestFixtures.createShift(
            id: "draft-shift",
            date: DateTestHelpers.tomorrow,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            status: .draft
        )
        mockShiftRepository.shiftsById["draft-shift"] = draftShift
        
        // When
        let response = try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        
        // Then
        #expect(response.totalAlerts == 0)
    }
    
    @Test("Get staffing alerts calculates correct shortfall")
    func getStaffingAlertsCalculatesShortfall() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let shift = TestFixtures.createShift(
            id: "understaffed-shift",
            date: DateTestHelpers.tomorrow,
            requiredScouts: 6,
            requiredParents: 4,
            currentScouts: 2,
            currentParents: 1,
            status: .published
        )
        mockShiftRepository.shiftsById["understaffed-shift"] = shift
        
        // When
        let response = try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        
        // Then
        #expect(response.totalAlerts == 1)
        let alert = response.criticalAlerts.first ?? response.lowStaffingAlerts.first!
        #expect(alert.scoutShortfall == 4) // 6 - 2
        #expect(alert.parentShortfall == 3) // 4 - 1
        #expect(alert.totalOpenSlots == 7) // 4 + 3
    }
    
    @Test("Get staffing alerts sorts by days until shift")
    func getStaffingAlertsSortsByDaysUntil() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        
        let calendar = Calendar.current
        let today = Date()
        
        // Further out shift
        let laterShift = TestFixtures.createShift(
            id: "later-shift",
            date: calendar.date(byAdding: .day, value: 5, to: today)!,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            status: .published
        )
        // Sooner shift
        let soonerShift = TestFixtures.createShift(
            id: "sooner-shift",
            date: calendar.date(byAdding: .day, value: 2, to: today)!,
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            status: .published
        )
        
        mockShiftRepository.shiftsById["later-shift"] = laterShift
        mockShiftRepository.shiftsById["sooner-shift"] = soonerShift
        
        // When
        let response = try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        
        // Then
        #expect(response.criticalAlerts.count == 2)
        #expect(response.criticalAlerts[0].shiftId == "sooner-shift")
        #expect(response.criticalAlerts[1].shiftId == "later-shift")
    }
    
    // MARK: - Error Tests
    
    @Test("Get staffing alerts fails when user not found")
    func getStaffingAlertsFailsWhenUserNotFound() async throws {
        // Given - no user in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(daysAhead: 7, requestingUserId: "non-existent")
        }
    }
    
    @Test("Get staffing alerts propagates repository error")
    func getStaffingAlertsPropagatesError() async throws {
        // Given
        let committeeId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeId)
        mockUserRepository.usersById[committeeId] = committeeUser
        mockShiftRepository.getShiftsForDateRangeResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(daysAhead: 7, requestingUserId: committeeId)
        }
    }
}
