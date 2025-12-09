import Foundation

/// Represents an attendance record for a shift assignment.
public struct AttendanceRecord: Identifiable, Equatable, Sendable, Codable {
    public let id: AttendanceRecordId
    public let assignmentId: AssignmentId
    public let shiftId: ShiftId
    public let userId: UserId
    public let checkInTime: Date?
    public let checkOutTime: Date?
    public let checkInMethod: CheckInMethod
    public let checkInLocation: GeoLocation?
    public let hoursWorked: Double?
    public let status: AttendanceStatus
    public let notes: String?
    
    public init(
        id: AttendanceRecordId,
        assignmentId: AssignmentId,
        shiftId: ShiftId,
        userId: UserId,
        checkInTime: Date?,
        checkOutTime: Date?,
        checkInMethod: CheckInMethod,
        checkInLocation: GeoLocation?,
        hoursWorked: Double?,
        status: AttendanceStatus,
        notes: String?
    ) {
        self.id = id
        self.assignmentId = assignmentId
        self.shiftId = shiftId
        self.userId = userId
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.checkInMethod = checkInMethod
        self.checkInLocation = checkInLocation
        self.hoursWorked = hoursWorked
        self.status = status
        self.notes = notes
    }
    
    public var isCheckedIn: Bool {
        checkInTime != nil && checkOutTime == nil
    }
    
    public var isComplete: Bool {
        checkInTime != nil && checkOutTime != nil
    }
}
