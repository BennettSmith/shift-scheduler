import Foundation

/// Response containing a user's attendance history.
public struct AttendanceHistoryResponse: Sendable, Equatable {
    public let records: [AttendanceRecordSummary]
    public let totalHours: Double
    public let completedShifts: Int
    
    public init(records: [AttendanceRecordSummary], totalHours: Double, completedShifts: Int) {
        self.records = records
        self.totalHours = totalHours
        self.completedShifts = completedShifts
    }
}

/// Summary of an attendance record for display.
public struct AttendanceRecordSummary: Sendable, Equatable, Identifiable {
    public let id: String
    public let shiftDate: Date
    public let shiftLabel: String?
    public let checkInTime: Date?
    public let checkOutTime: Date?
    public let hoursWorked: Double?
    public let status: AttendanceStatus
    
    public init(
        id: String,
        shiftDate: Date,
        shiftLabel: String?,
        checkInTime: Date?,
        checkOutTime: Date?,
        hoursWorked: Double?,
        status: AttendanceStatus
    ) {
        self.id = id
        self.shiftDate = shiftDate
        self.shiftLabel = shiftLabel
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.hoursWorked = hoursWorked
        self.status = status
    }
}
