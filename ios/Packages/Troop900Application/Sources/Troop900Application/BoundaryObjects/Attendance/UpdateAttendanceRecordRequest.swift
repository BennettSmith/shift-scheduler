import Foundation
import Troop900Domain

/// Request to update an attendance record (admin override).
/// Used by committee to fix incorrect attendance records.
public struct UpdateAttendanceRecordRequest: Sendable, Equatable {
    /// The ID of the attendance record to update
    public let attendanceRecordId: String
    
    /// The ID of the user making the request (must be admin)
    public let requestingUserId: String
    
    /// New check-in time (if updating)
    public let checkInTime: Date?
    
    /// New check-out time (if updating)
    public let checkOutTime: Date?
    
    /// New status (if updating)
    public let status: AttendanceStatus?
    
    /// New hours worked (if updating)
    public let hoursWorked: Double?
    
    /// Notes explaining the correction
    public let correctionNotes: String?
    
    /// Reason for the administrative override
    public let overrideReason: String
    
    public init(
        attendanceRecordId: String,
        requestingUserId: String,
        checkInTime: Date?,
        checkOutTime: Date?,
        status: AttendanceStatus?,
        hoursWorked: Double?,
        correctionNotes: String?,
        overrideReason: String
    ) {
        self.attendanceRecordId = attendanceRecordId
        self.requestingUserId = requestingUserId
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.status = status
        self.hoursWorked = hoursWorked
        self.correctionNotes = correctionNotes
        self.overrideReason = overrideReason
    }
}
