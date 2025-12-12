import Foundation
import Testing
@testable import Troop900Data
import Troop900Domain

@Suite("SimulatedAttendanceService Tests")
struct SimulatedAttendanceServiceTests {
    
    func makeTestUser() -> User {
        User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: .active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func makeTestShift() -> Shift {
        Shift(
            id: ShiftId(unchecked: "shift-1"),
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
    }
    
    func makeTestAssignment() -> Assignment {
        Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            assignmentType: .scout,
            status: .confirmed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
    }
    
    @Test("Check in creates attendance record")
    func checkIn() async throws {
        let user = makeTestUser()
        let shift = makeTestShift()
        let assignment = makeTestAssignment()
        
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let shiftRepo = InMemoryShiftRepository(initialShifts: [shift])
        let assignmentRepo = InMemoryAssignmentRepository(initialAssignments: [assignment])
        let attendanceRepo = InMemoryAttendanceRepository()
        
        let service = SimulatedAttendanceService(
            assignmentRepository: assignmentRepo,
            attendanceRepository: attendanceRepo,
            shiftRepository: shiftRepo
        )
        
        let request = CheckInServiceRequest(
            assignmentId: assignment.id,
            shiftId: shift.id,
            qrCodeData: "test-qr-code",
            location: GeoLocation(latitude: 37.7749, longitude: -122.4194)
        )
        
        let response = try await service.checkIn(request: request)
        
        #expect(response.success)
        let record = try await attendanceRepo.getAttendanceRecord(id: response.attendanceRecordId)
        #expect(record.checkInTime != nil)
        #expect(record.checkInMethod == .qrCode)
        #expect(record.status == .checkedIn)
    }
    
    @Test("Check in throws when assignment not active")
    func checkInAssignmentNotActive() async throws {
        let assignment = Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            assignmentType: .scout,
            status: .cancelled,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        let assignmentRepo = InMemoryAssignmentRepository(initialAssignments: [assignment])
        let shiftRepo = InMemoryShiftRepository(initialShifts: [makeTestShift()])
        let attendanceRepo = InMemoryAttendanceRepository()
        
        let service = SimulatedAttendanceService(
            assignmentRepository: assignmentRepo,
            attendanceRepository: attendanceRepo,
            shiftRepository: shiftRepo
        )
        
        let request = CheckInServiceRequest(
            assignmentId: assignment.id,
            shiftId: ShiftId(unchecked: "shift-1"),
            qrCodeData: nil,
            location: nil
        )
        
        do {
            _ = try await service.checkIn(request: request)
            Issue.record("Expected DomainError.assignmentNotActive")
        } catch DomainError.assignmentNotActive {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Check out updates attendance record")
    func checkOut() async throws {
        let assignment = makeTestAssignment()
        let shift = makeTestShift()
        
        let assignmentRepo = InMemoryAssignmentRepository(initialAssignments: [assignment])
        let shiftRepo = InMemoryShiftRepository(initialShifts: [shift])
        let attendanceRepo = InMemoryAttendanceRepository()
        
        // Create a checked-in record
        let checkInTime = Date()
        let record = AttendanceRecord(
            id: AttendanceRecordId(unchecked: "record-1"),
            assignmentId: assignment.id,
            shiftId: shift.id,
            userId: assignment.userId,
            checkInTime: checkInTime,
            checkOutTime: nil,
            checkInMethod: .manual,
            checkInLocation: nil,
            hoursWorked: nil,
            status: .checkedIn,
            notes: nil
        )
        try await attendanceRepo.createAttendanceRecord(record)
        
        let service = SimulatedAttendanceService(
            assignmentRepository: assignmentRepo,
            attendanceRepository: attendanceRepo,
            shiftRepository: shiftRepo
        )
        
        let response = try await service.checkOut(assignmentId: assignment.id, notes: "Great shift!")
        
        #expect(response.success)
        #expect(response.hoursWorked > 0)
        
        let updatedRecord = try await attendanceRepo.getAttendanceRecord(id: record.id)
        #expect(updatedRecord.checkOutTime != nil)
        #expect(updatedRecord.status == .checkedOut)
        #expect(updatedRecord.hoursWorked != nil)
    }
    
    @Test("Check out throws when not checked in")
    func checkOutNotCheckedIn() async throws {
        let assignment = makeTestAssignment()
        let shift = makeTestShift()
        
        let assignmentRepo = InMemoryAssignmentRepository(initialAssignments: [assignment])
        let shiftRepo = InMemoryShiftRepository(initialShifts: [shift])
        let attendanceRepo = InMemoryAttendanceRepository()
        
        let service = SimulatedAttendanceService(
            assignmentRepository: assignmentRepo,
            attendanceRepository: attendanceRepo,
            shiftRepository: shiftRepo
        )
        
        do {
            _ = try await service.checkOut(assignmentId: assignment.id, notes: nil)
            Issue.record("Expected DomainError.attendanceRecordNotFound")
        } catch DomainError.attendanceRecordNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Admin manual check in")
    func adminManualCheckIn() async throws {
        let assignment = makeTestAssignment()
        let shift = makeTestShift()
        
        let assignmentRepo = InMemoryAssignmentRepository(initialAssignments: [assignment])
        let shiftRepo = InMemoryShiftRepository(initialShifts: [shift])
        let attendanceRepo = InMemoryAttendanceRepository()
        
        let service = SimulatedAttendanceService(
            assignmentRepository: assignmentRepo,
            attendanceRepository: attendanceRepo,
            shiftRepository: shiftRepo
        )
        
        let overrideTime = Date().addingTimeInterval(-3600) // 1 hour ago
        let request = AdminCheckInRequest(
            assignmentId: assignment.id,
            shiftId: shift.id,
            adminUserId: UserId(unchecked: "admin-1"),
            overrideTime: overrideTime,
            notes: "Late arrival"
        )
        
        let response = try await service.adminManualCheckIn(request: request)
        
        #expect(response.success)
        let record = try await attendanceRepo.getAttendanceRecord(id: response.attendanceRecordId)
        #expect(record.checkInMethod == .adminOverride)
        #expect(record.checkInTime == overrideTime)
    }
}
