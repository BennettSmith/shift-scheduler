import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("AddWalkInAssignmentUseCase Tests")
struct AddWalkInAssignmentUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockUserRepository = MockUserRepository()
    private let mockAttendanceService = MockAttendanceService()
    
    private var useCase: AddWalkInAssignmentUseCase {
        AddWalkInAssignmentUseCase(
            shiftRepository: mockShiftRepository,
            assignmentRepository: mockAssignmentRepository,
            attendanceRepository: mockAttendanceRepository,
            userRepository: mockUserRepository,
            attendanceService: mockAttendanceService
        )
    }
    
    // MARK: - Helper to create in-progress shift
    
    private func createInProgressShift(id: String) -> Shift {
        let now = Date()
        return Shift(
            id: ShiftId(unchecked: id),
            date: now.startOfDay,
            startTime: now.addingTimeInterval(-3600), // Started 1 hour ago
            endTime: now.addingTimeInterval(7200), // Ends in 2 hours
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 2,
            currentParents: 1,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: "season-1",
            templateId: nil,
            createdAt: Date()
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Committee member can add walk-in to in-progress shift")
    func committeeMemberCanAddWalkIn() async throws {
        // Given
        let shiftId = "shift-1"
        let walkInUserId = "walkin-user"
        let committeeUserId = "committee-user"
        
        let shift = createInProgressShift(id: shiftId)
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let walkInUser = TestFixtures.createScout(id: walkInUserId, firstName: "Walk", lastName: "In")
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockUserRepository.usersById[walkInUserId] = walkInUser
        
        let request = AddWalkInRequest(
            shiftId: shiftId,
            userId: walkInUserId,
            requestingUserId: committeeUserId,
            notes: "Showed up to help",
            assignmentType: .scout
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.assignmentId != nil)
        #expect(response.attendanceRecordId != nil)
        #expect(response.autoCheckedIn == true)
        #expect(mockAssignmentRepository.createAssignmentCallCount == 1)
        #expect(mockAttendanceRepository.createAttendanceRecordCallCount == 1)
    }
    
    @Test("Checked-in parent can add walk-in to their shift")
    func checkedInParentCanAddWalkIn() async throws {
        // Given
        let shiftId = "shift-1"
        let walkInUserId = "walkin-user"
        let parentUserId = "parent-user"
        let parentAssignmentId = "parent-assignment"
        
        let shift = createInProgressShift(id: shiftId)
        let parentUser = TestFixtures.createParent(id: parentUserId)
        let walkInUser = TestFixtures.createScout(id: walkInUserId)
        let parentAssignment = TestFixtures.createAssignment(
            id: parentAssignmentId,
            shiftId: shiftId,
            userId: parentUserId,
            status: .confirmed
        )
        let parentAttendance = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: parentAssignmentId,
            shiftId: shiftId,
            userId: parentUserId
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[parentUserId] = parentUser
        mockUserRepository.usersById[walkInUserId] = walkInUser
        mockAssignmentRepository.assignmentsById[parentAssignmentId] = parentAssignment
        mockAttendanceRepository.addRecord(parentAttendance)
        
        let request = AddWalkInRequest(
            shiftId: shiftId,
            userId: walkInUserId,
            requestingUserId: parentUserId,
            notes: nil,
            assignmentType: .scout
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.autoCheckedIn == true)
    }
    
    @Test("Walk-in creates assignment and attendance record")
    func walkInCreatesAssignmentAndAttendance() async throws {
        // Given
        let shiftId = "shift-1"
        let walkInUserId = "walkin-user"
        let committeeUserId = "committee-user"
        
        let shift = createInProgressShift(id: shiftId)
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let walkInUser = TestFixtures.createParent(id: walkInUserId, firstName: "New", lastName: "Volunteer")
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockUserRepository.usersById[walkInUserId] = walkInUser
        
        let request = AddWalkInRequest(
            shiftId: shiftId,
            userId: walkInUserId,
            requestingUserId: committeeUserId,
            notes: "Walk-in parent",
            assignmentType: .parent
        )
        
        // When
        _ = try await useCase.execute(request: request)
        
        // Then
        #expect(mockAssignmentRepository.createAssignmentCallCount == 1)
        let createdAssignment = mockAssignmentRepository.createAssignmentCalledWith[0]
        #expect(createdAssignment.shiftId.value == shiftId)
        #expect(createdAssignment.userId.value == walkInUserId)
        #expect(createdAssignment.assignmentType == .parent)
        #expect(createdAssignment.assignedBy?.value == committeeUserId)
        
        #expect(mockAttendanceRepository.createAttendanceRecordCallCount == 1)
        let createdAttendance = mockAttendanceRepository.createAttendanceRecordCalledWith[0]
        #expect(createdAttendance.shiftId.value == shiftId)
        #expect(createdAttendance.userId.value == walkInUserId)
        #expect(createdAttendance.status == .checkedIn)
        #expect(createdAttendance.checkInMethod == .manual)
    }
    
    // MARK: - Permission Tests
    
    @Test("Non-checked-in parent cannot add walk-in")
    func nonCheckedInParentCannotAddWalkIn() async throws {
        // Given
        let shiftId = "shift-1"
        let walkInUserId = "walkin-user"
        let parentUserId = "parent-user"
        
        let shift = createInProgressShift(id: shiftId)
        let parentUser = TestFixtures.createParent(id: parentUserId)
        let walkInUser = TestFixtures.createScout(id: walkInUserId)
        // Parent has assignment but is NOT checked in
        let parentAssignment = TestFixtures.createAssignment(
            id: "parent-assignment",
            shiftId: shiftId,
            userId: parentUserId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[parentUserId] = parentUser
        mockUserRepository.usersById[walkInUserId] = walkInUser
        mockAssignmentRepository.assignmentsById["parent-assignment"] = parentAssignment
        // No attendance record = not checked in
        
        let request = AddWalkInRequest(
            shiftId: shiftId,
            userId: walkInUserId,
            requestingUserId: parentUserId,
            notes: nil,
            assignmentType: .scout
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAssignmentRepository.createAssignmentCallCount == 0)
    }
    
    @Test("Unassigned parent cannot add walk-in")
    func unassignedParentCannotAddWalkIn() async throws {
        // Given
        let shiftId = "shift-1"
        let walkInUserId = "walkin-user"
        let parentUserId = "parent-user"
        
        let shift = createInProgressShift(id: shiftId)
        let parentUser = TestFixtures.createParent(id: parentUserId)
        let walkInUser = TestFixtures.createScout(id: walkInUserId)
        // Parent has no assignment to this shift
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[parentUserId] = parentUser
        mockUserRepository.usersById[walkInUserId] = walkInUser
        
        let request = AddWalkInRequest(
            shiftId: shiftId,
            userId: walkInUserId,
            requestingUserId: parentUserId,
            notes: nil,
            assignmentType: .scout
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Validation Tests
    
    @Test("Cannot add walk-in to shift that hasn't started")
    func cannotAddWalkInToFutureShift() async throws {
        // Given
        let shiftId = "shift-1"
        let walkInUserId = "walkin-user"
        let committeeUserId = "committee-user"
        
        // Future shift (hasn't started)
        let futureShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            startTime: DateTestHelpers.tomorrow.addingHours(9),
            status: .published
        )
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let walkInUser = TestFixtures.createScout(id: walkInUserId)
        
        mockShiftRepository.shiftsById[shiftId] = futureShift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockUserRepository.usersById[walkInUserId] = walkInUser
        
        let request = AddWalkInRequest(
            shiftId: shiftId,
            userId: walkInUserId,
            requestingUserId: committeeUserId,
            notes: nil,
            assignmentType: .scout
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then - returns failure response, doesn't throw
        #expect(response.success == false)
        #expect(response.message.contains("haven't started"))
        #expect(mockAssignmentRepository.createAssignmentCallCount == 0)
    }
    
    @Test("Cannot add walk-in who is already assigned")
    func cannotAddWalkInWhoIsAlreadyAssigned() async throws {
        // Given
        let shiftId = "shift-1"
        let walkInUserId = "walkin-user"
        let committeeUserId = "committee-user"
        
        let shift = createInProgressShift(id: shiftId)
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let walkInUser = TestFixtures.createScout(id: walkInUserId, firstName: "Already", lastName: "Assigned")
        let existingAssignment = TestFixtures.createAssignment(
            id: "existing-assignment",
            shiftId: shiftId,
            userId: walkInUserId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockUserRepository.usersById[walkInUserId] = walkInUser
        mockAssignmentRepository.assignmentsById["existing-assignment"] = existingAssignment
        
        let request = AddWalkInRequest(
            shiftId: shiftId,
            userId: walkInUserId,
            requestingUserId: committeeUserId,
            notes: nil,
            assignmentType: .scout
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == false)
        #expect(response.message.contains("already has an assignment"))
        #expect(mockAssignmentRepository.createAssignmentCallCount == 0)
    }
    
    // MARK: - Error Tests
    
    @Test("Add walk-in fails when shift not found")
    func addWalkInFailsWhenShiftNotFound() async throws {
        // Given
        let committeeUserId = "committee-user"
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        mockUserRepository.usersById[committeeUserId] = committeeUser
        
        let request = AddWalkInRequest(
            shiftId: "non-existent",
            userId: "walkin-user",
            requestingUserId: committeeUserId,
            notes: nil,
            assignmentType: .scout
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Add walk-in fails when walk-in user not found")
    func addWalkInFailsWhenWalkInUserNotFound() async throws {
        // Given
        let shiftId = "shift-1"
        let committeeUserId = "committee-user"
        
        let shift = createInProgressShift(id: shiftId)
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        // Walk-in user not in repository
        
        let request = AddWalkInRequest(
            shiftId: shiftId,
            userId: "non-existent-user",
            requestingUserId: committeeUserId,
            notes: nil,
            assignmentType: .scout
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
