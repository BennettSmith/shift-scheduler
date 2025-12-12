import Foundation
import Testing
@testable import Troop900Domain

@Suite("AttendanceRecord Tests")
struct AttendanceRecordTests {
    
    @Test("Attendance record initialization")
    func attendanceRecordInitialization() {
        let location = GeoLocation(latitude: 37.7749, longitude: -122.4194)
        let record = AttendanceRecord(
            id: AttendanceRecordId(unchecked: "attendance-1"),
            assignmentId: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            checkInTime: Date(),
            checkOutTime: nil,
            checkInMethod: CheckInMethod.qrCode,
            checkInLocation: location,
            hoursWorked: nil,
            status: AttendanceStatus.checkedIn,
            notes: nil
        )
        
        #expect(record.id.value == "attendance-1")
        #expect(record.assignmentId.value == "assignment-1")
        #expect(record.shiftId.value == "shift-1")
        #expect(record.userId.value == "user-1")
        #expect(record.checkInMethod == CheckInMethod.qrCode)
    }
    
    @Test("Record is checked in when check in time exists and check out time is nil")
    func isCheckedIn() {
        let record = AttendanceRecord(
            id: AttendanceRecordId(unchecked: "attendance-1"),
            assignmentId: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            checkInTime: Date(),
            checkOutTime: nil,
            checkInMethod: CheckInMethod.qrCode,
            checkInLocation: nil,
            hoursWorked: nil,
            status: AttendanceStatus.checkedIn,
            notes: nil
        )
        
        #expect(record.isCheckedIn)
    }
    
    @Test("Record is not checked in when both times exist")
    func isNotCheckedInWhenComplete() {
        let record = AttendanceRecord(
            id: AttendanceRecordId(unchecked: "attendance-1"),
            assignmentId: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            checkInTime: Date(),
            checkOutTime: Date(),
            checkInMethod: CheckInMethod.qrCode,
            checkInLocation: nil,
            hoursWorked: 2.5,
            status: AttendanceStatus.checkedOut,
            notes: nil
        )
        
        #expect(!record.isCheckedIn)
    }
    
    @Test("Record is not checked in when no check in time")
    func isNotCheckedInWithoutCheckIn() {
        let record = AttendanceRecord(
            id: AttendanceRecordId(unchecked: "attendance-1"),
            assignmentId: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            checkInTime: nil,
            checkOutTime: nil,
            checkInMethod: CheckInMethod.manual,
            checkInLocation: nil,
            hoursWorked: nil,
            status: AttendanceStatus.pending,
            notes: nil
        )
        
        #expect(!record.isCheckedIn)
    }
    
    @Test("Record is complete when both check in and check out times exist")
    func isComplete() {
        let record = AttendanceRecord(
            id: AttendanceRecordId(unchecked: "attendance-1"),
            assignmentId: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            checkInTime: Date(),
            checkOutTime: Date(),
            checkInMethod: CheckInMethod.qrCode,
            checkInLocation: nil,
            hoursWorked: 2.5,
            status: AttendanceStatus.checkedOut,
            notes: nil
        )
        
        #expect(record.isComplete)
    }
    
    @Test("Record is not complete with only check in time")
    func isNotCompleteWithOnlyCheckIn() {
        let record = AttendanceRecord(
            id: AttendanceRecordId(unchecked: "attendance-1"),
            assignmentId: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            checkInTime: Date(),
            checkOutTime: nil,
            checkInMethod: CheckInMethod.qrCode,
            checkInLocation: nil,
            hoursWorked: nil,
            status: AttendanceStatus.checkedIn,
            notes: nil
        )
        
        #expect(!record.isComplete)
    }
}
