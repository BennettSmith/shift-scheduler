import Foundation
import Troop900Domain

/// Response after adding a walk-in volunteer to a shift.
public struct AddWalkInResponse: Sendable, Equatable {
    /// Whether the operation succeeded
    public let success: Bool
    
    /// The ID of the created assignment
    public let assignmentId: String?
    
    /// The ID of the created attendance record
    public let attendanceRecordId: String?
    
    /// Human-readable message describing the result
    public let message: String
    
    /// Whether the volunteer was automatically checked in
    public let autoCheckedIn: Bool
    
    public init(
        success: Bool,
        assignmentId: String?,
        attendanceRecordId: String?,
        message: String,
        autoCheckedIn: Bool
    ) {
        self.success = success
        self.assignmentId = assignmentId
        self.attendanceRecordId = attendanceRecordId
        self.message = message
        self.autoCheckedIn = autoCheckedIn
    }
}
