import Foundation
import Troop900Domain

/// Response containing detailed attendance information for a shift.
/// Used by committee to review and manage shift attendance.
public struct ShiftAttendanceDetailsResponse: Sendable, Equatable {
    /// The shift ID
    public let shiftId: String
    
    /// The shift date
    public let shiftDate: Date
    
    /// The shift label (e.g., "Morning Shift")
    public let shiftLabel: String?
    
    /// Total number of volunteers assigned
    public let totalAssigned: Int
    
    /// Number of volunteers checked in
    public let checkedInCount: Int
    
    /// Number of volunteers checked out
    public let checkedOutCount: Int
    
    /// Number of no-shows
    public let noShowCount: Int
    
    /// Detailed attendance records
    public let attendanceRecords: [AttendanceRecordDetail]
    
    /// Total hours worked across all volunteers
    public let totalHoursWorked: Double
    
    public init(
        shiftId: String,
        shiftDate: Date,
        shiftLabel: String?,
        totalAssigned: Int,
        checkedInCount: Int,
        checkedOutCount: Int,
        noShowCount: Int,
        attendanceRecords: [AttendanceRecordDetail],
        totalHoursWorked: Double
    ) {
        self.shiftId = shiftId
        self.shiftDate = shiftDate
        self.shiftLabel = shiftLabel
        self.totalAssigned = totalAssigned
        self.checkedInCount = checkedInCount
        self.checkedOutCount = checkedOutCount
        self.noShowCount = noShowCount
        self.attendanceRecords = attendanceRecords
        self.totalHoursWorked = totalHoursWorked
    }
}
