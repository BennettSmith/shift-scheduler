import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetShiftAttendanceDetailsUseCase Tests")
struct GetShiftAttendanceDetailsUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: GetShiftAttendanceDetailsUseCase {
        GetShiftAttendanceDetailsUseCase(
            shiftRepository: mockShiftRepository,
            assignmentRepository: mockAssignmentRepository,
            attendanceRepository: mockAttendanceRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Get attendance details succeeds for committee member")
    func getAttendanceDetailsSucceedsForCommittee() async throws {
        // Given
        let shiftId = "shift-1"
        let committeeUserId = "committee-1"
        
        let shift = TestFixtures.createShift(id: shiftId, label: "Morning Shift")
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, requestingUserId: committeeUserId)
        
        // Then
        #expect(response.shiftId == shiftId)
        #expect(response.shiftLabel == "Morning Shift")
        #expect(response.totalAssigned == 0)
    }
    
    @Test("Get attendance details returns all assignments with user names")
    func getAttendanceDetailsReturnsAssignmentsWithUserNames() async throws {
        // Given
        let shiftId = "shift-1"
        let committeeUserId = "committee-1"
        let parentUserId = "parent-1"
        let scoutUserId = "scout-1"
        
        let shift = TestFixtures.createShift(id: shiftId)
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let parentUser = TestFixtures.createParent(id: parentUserId, firstName: "John", lastName: "Doe")
        let scoutUser = TestFixtures.createScout(id: scoutUserId, firstName: "Jane", lastName: "Doe")
        
        let parentAssignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: parentUserId,
            assignmentType: .parent
        )
        let scoutAssignment = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: shiftId,
            userId: scoutUserId,
            assignmentType: .scout
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockUserRepository.usersById[parentUserId] = parentUser
        mockUserRepository.usersById[scoutUserId] = scoutUser
        mockAssignmentRepository.assignmentsById["assignment-1"] = parentAssignment
        mockAssignmentRepository.assignmentsById["assignment-2"] = scoutAssignment
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, requestingUserId: committeeUserId)
        
        // Then
        #expect(response.totalAssigned == 2)
        #expect(response.attendanceRecords.count == 2)
        
        let parentRecord = response.attendanceRecords.first { $0.userId == parentUserId }
        #expect(parentRecord?.userName == "John Doe")
        #expect(parentRecord?.assignmentType == .parent)
        
        let scoutRecord = response.attendanceRecords.first { $0.userId == scoutUserId }
        #expect(scoutRecord?.userName == "Jane Doe")
        #expect(scoutRecord?.assignmentType == .scout)
    }
    
    @Test("Get attendance details calculates counts correctly")
    func getAttendanceDetailsCalculatesCountsCorrectly() async throws {
        // Given
        let shiftId = "shift-1"
        let committeeUserId = "committee-1"
        
        let shift = TestFixtures.createShift(id: shiftId)
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        
        // Create users
        let user1 = TestFixtures.createParent(id: "user-1")
        let user2 = TestFixtures.createParent(id: "user-2")
        let user3 = TestFixtures.createParent(id: "user-3")
        
        // Create assignments
        let assignment1 = TestFixtures.createAssignment(id: "assignment-1", shiftId: shiftId, userId: "user-1")
        let assignment2 = TestFixtures.createAssignment(id: "assignment-2", shiftId: shiftId, userId: "user-2")
        let assignment3 = TestFixtures.createAssignment(id: "assignment-3", shiftId: shiftId, userId: "user-3")
        
        // Create attendance records
        let checkedInRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: "assignment-1",
            shiftId: shiftId,
            userId: "user-1"
        )
        let completedRecord = TestFixtures.createCompletedRecord(
            id: "attendance-2",
            assignmentId: "assignment-2",
            shiftId: shiftId,
            userId: "user-2",
            hoursWorked: 3.5
        )
        let noShowRecord = TestFixtures.createAttendanceRecord(
            id: "attendance-3",
            assignmentId: "assignment-3",
            shiftId: shiftId,
            userId: "user-3",
            status: .noShow
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockUserRepository.usersById["user-1"] = user1
        mockUserRepository.usersById["user-2"] = user2
        mockUserRepository.usersById["user-3"] = user3
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment1
        mockAssignmentRepository.assignmentsById["assignment-2"] = assignment2
        mockAssignmentRepository.assignmentsById["assignment-3"] = assignment3
        mockAttendanceRepository.addRecord(checkedInRecord)
        mockAttendanceRepository.addRecord(completedRecord)
        mockAttendanceRepository.addRecord(noShowRecord)
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, requestingUserId: committeeUserId)
        
        // Then
        #expect(response.totalAssigned == 3)
        #expect(response.checkedInCount == 2) // Checked in + checked out
        #expect(response.checkedOutCount == 1)
        #expect(response.noShowCount == 1)
        #expect(response.totalHoursWorked == 3.5)
    }
    
    @Test("Get attendance details identifies walk-in volunteers")
    func getAttendanceDetailsIdentifiesWalkIns() async throws {
        // Given
        let shiftId = "shift-1"
        let committeeUserId = "committee-1"
        let regularUserId = "regular-user"
        let walkInUserId = "walkin-user"
        
        let shift = TestFixtures.createShift(id: shiftId)
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let regularUser = TestFixtures.createParent(id: regularUserId)
        let walkInUser = TestFixtures.createParent(id: walkInUserId)
        
        // Regular assignment (self-assigned)
        let regularAssignment = TestFixtures.createAssignment(
            id: "regular-assignment",
            shiftId: shiftId,
            userId: regularUserId,
            assignedBy: nil // Self-assigned
        )
        
        // Walk-in assignment (assigned by someone else)
        let walkInAssignment = Assignment(
            id: AssignmentId(unchecked: "walkin-assignment"),
            shiftId: ShiftId(unchecked: shiftId),
            userId: UserId(unchecked: walkInUserId),
            assignmentType: .parent,
            status: .confirmed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: UserId(unchecked: committeeUserId) // Assigned by committee
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockUserRepository.usersById[regularUserId] = regularUser
        mockUserRepository.usersById[walkInUserId] = walkInUser
        mockAssignmentRepository.assignmentsById["regular-assignment"] = regularAssignment
        mockAssignmentRepository.assignmentsById["walkin-assignment"] = walkInAssignment
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, requestingUserId: committeeUserId)
        
        // Then
        let regularRecord = response.attendanceRecords.first { $0.userId == regularUserId }
        let walkInRecord = response.attendanceRecords.first { $0.userId == walkInUserId }
        
        #expect(regularRecord?.isWalkIn == false)
        #expect(walkInRecord?.isWalkIn == true)
    }
    
    // MARK: - Permission Tests
    
    @Test("Get attendance details fails for non-committee user")
    func getAttendanceDetailsFailsForNonCommittee() async throws {
        // Given
        let shiftId = "shift-1"
        let parentUserId = "parent-1"
        
        let shift = TestFixtures.createShift(id: shiftId)
        let parentUser = TestFixtures.createParent(id: parentUserId)
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[parentUserId] = parentUser
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(shiftId: shiftId, requestingUserId: parentUserId)
        }
    }
    
    @Test("Get attendance details fails for scout user")
    func getAttendanceDetailsFailsForScout() async throws {
        // Given
        let shiftId = "shift-1"
        let scoutUserId = "scout-1"
        
        let shift = TestFixtures.createShift(id: shiftId)
        let scoutUser = TestFixtures.createScout(id: scoutUserId)
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[scoutUserId] = scoutUser
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(shiftId: shiftId, requestingUserId: scoutUserId)
        }
    }
    
    // MARK: - Error Tests
    
    @Test("Get attendance details fails when shift not found")
    func getAttendanceDetailsFailsWhenShiftNotFound() async throws {
        // Given
        let committeeUserId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        mockUserRepository.usersById[committeeUserId] = committeeUser
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(shiftId: "non-existent", requestingUserId: committeeUserId)
        }
    }
    
    @Test("Get attendance details fails when requesting user not found")
    func getAttendanceDetailsFailsWhenUserNotFound() async throws {
        // Given
        let shiftId = "shift-1"
        let shift = TestFixtures.createShift(id: shiftId)
        mockShiftRepository.shiftsById[shiftId] = shift
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(shiftId: shiftId, requestingUserId: "non-existent")
        }
    }
}
