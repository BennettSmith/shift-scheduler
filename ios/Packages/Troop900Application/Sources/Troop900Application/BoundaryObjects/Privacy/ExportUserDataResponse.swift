import Foundation
import Troop900Domain

/// Response containing exported user data.
public struct ExportUserDataResponse: Sendable, Equatable {
    /// The user's complete data export
    public let userDataExport: UserDataExport
    
    /// URL to download the export (if large)
    public let downloadUrl: String?
    
    /// Size of the export in bytes
    public let sizeInBytes: Int
    
    /// When the export was generated
    public let generatedAt: Date
    
    public init(
        userDataExport: UserDataExport,
        downloadUrl: String?,
        sizeInBytes: Int,
        generatedAt: Date
    ) {
        self.userDataExport = userDataExport
        self.downloadUrl = downloadUrl
        self.sizeInBytes = sizeInBytes
        self.generatedAt = generatedAt
    }
}

/// Comprehensive user data export structure.
public struct UserDataExport: Sendable, Equatable, Codable {
    /// User profile information
    public let profile: ExportedProfile
    
    /// Household memberships
    public let households: [ExportedHousehold]
    
    /// Shift assignments
    public let assignments: [ExportedAssignment]
    
    /// Attendance records
    public let attendanceRecords: [ExportedAttendanceRecord]
    
    /// Messages sent/received
    public let messages: [ExportedMessage]
    
    /// Achievements earned
    public let achievements: [String]
    
    /// Account metadata
    public let metadata: ExportMetadata
    
    public init(
        profile: ExportedProfile,
        households: [ExportedHousehold],
        assignments: [ExportedAssignment],
        attendanceRecords: [ExportedAttendanceRecord],
        messages: [ExportedMessage],
        achievements: [String],
        metadata: ExportMetadata
    ) {
        self.profile = profile
        self.households = households
        self.assignments = assignments
        self.attendanceRecords = attendanceRecords
        self.messages = messages
        self.achievements = achievements
        self.metadata = metadata
    }
}

/// Exported profile data.
public struct ExportedProfile: Sendable, Equatable, Codable {
    public let userId: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let role: String
    public let accountStatus: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(userId: String, email: String, firstName: String, lastName: String, role: String, accountStatus: String, createdAt: Date, updatedAt: Date) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.accountStatus = accountStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Exported household data.
public struct ExportedHousehold: Sendable, Equatable, Codable {
    public let householdId: String
    public let householdName: String
    public let role: String // member, manager
    public let joinedAt: Date
    
    public init(householdId: String, householdName: String, role: String, joinedAt: Date) {
        self.householdId = householdId
        self.householdName = householdName
        self.role = role
        self.joinedAt = joinedAt
    }
}

/// Exported assignment data.
public struct ExportedAssignment: Sendable, Equatable, Codable {
    public let assignmentId: String
    public let shiftDate: Date
    public let shiftLabel: String?
    public let assignmentType: String
    public let status: String
    public let assignedAt: Date
    
    public init(assignmentId: String, shiftDate: Date, shiftLabel: String?, assignmentType: String, status: String, assignedAt: Date) {
        self.assignmentId = assignmentId
        self.shiftDate = shiftDate
        self.shiftLabel = shiftLabel
        self.assignmentType = assignmentType
        self.status = status
        self.assignedAt = assignedAt
    }
}

/// Exported attendance record.
public struct ExportedAttendanceRecord: Sendable, Equatable, Codable {
    public let recordId: String
    public let shiftDate: Date
    public let checkInTime: Date?
    public let checkOutTime: Date?
    public let hoursWorked: Double?
    public let status: String
    
    public init(recordId: String, shiftDate: Date, checkInTime: Date?, checkOutTime: Date?, hoursWorked: Double?, status: String) {
        self.recordId = recordId
        self.shiftDate = shiftDate
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.hoursWorked = hoursWorked
        self.status = status
    }
}

/// Exported message data.
public struct ExportedMessage: Sendable, Equatable, Codable {
    public let messageId: String
    public let subject: String
    public let sentAt: Date
    public let sentBy: String
    
    public init(messageId: String, subject: String, sentAt: Date, sentBy: String) {
        self.messageId = messageId
        self.subject = subject
        self.sentAt = sentAt
        self.sentBy = sentBy
    }
}

/// Export metadata.
public struct ExportMetadata: Sendable, Equatable, Codable {
    public let exportedAt: Date
    public let exportVersion: String
    public let totalRecords: Int
    
    public init(exportedAt: Date, exportVersion: String, totalRecords: Int) {
        self.exportedAt = exportedAt
        self.exportVersion = exportVersion
        self.totalRecords = totalRecords
    }
}
