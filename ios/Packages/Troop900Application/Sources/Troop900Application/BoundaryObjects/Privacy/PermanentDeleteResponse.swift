import Foundation
import Troop900Domain

/// Response after permanently deleting user data.
public struct PermanentDeleteResponse: Sendable, Equatable {
    /// Whether the deletion succeeded
    public let success: Bool
    
    /// Number of records deleted
    public let deletedRecords: DeletedRecordCounts
    
    /// When the deletion was performed
    public let deletedAt: Date
    
    /// Audit log entry ID for record-keeping
    public let auditLogId: String
    
    /// Warning message
    public let message: String
    
    public init(
        success: Bool,
        deletedRecords: DeletedRecordCounts,
        deletedAt: Date,
        auditLogId: String,
        message: String
    ) {
        self.success = success
        self.deletedRecords = deletedRecords
        self.deletedAt = deletedAt
        self.auditLogId = auditLogId
        self.message = message
    }
}

/// Counts of deleted records by type.
public struct DeletedRecordCounts: Sendable, Equatable, Codable {
    public let userProfile: Int
    public let assignments: Int
    public let attendanceRecords: Int
    public let messages: Int
    public let otherRecords: Int
    
    public var total: Int {
        userProfile + assignments + attendanceRecords + messages + otherRecords
    }
    
    public init(
        userProfile: Int,
        assignments: Int,
        attendanceRecords: Int,
        messages: Int,
        otherRecords: Int
    ) {
        self.userProfile = userProfile
        self.assignments = assignments
        self.attendanceRecords = attendanceRecords
        self.messages = messages
        self.otherRecords = otherRecords
    }
}
