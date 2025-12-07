import Foundation

/// Represents an attendance record for a shift assignment.
public struct AttendanceRecord: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let assignmentId: String
    public let shiftId: String
    public let userId: String
    public let checkInTime: Date?
    public let checkOutTime: Date?
    public let checkInMethod: CheckInMethod
    public let checkInLocation: GeoLocation?
    public let hoursWorked: Double?
    public let status: AttendanceStatus
    public let notes: String?
    
    public init(
        id: String,
        assignmentId: String,
        shiftId: String,
        userId: String,
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
