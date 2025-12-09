import Foundation

// Note: UserRoleType, ParticipantType, CheckInMethodType, AttendanceStatusType, and Coordinate
// are defined in BoundaryObjects/Common/BoundaryEnums.swift

/// Detailed information about an attendance record for committee review.
public struct AttendanceRecordDetail: Sendable, Equatable, Identifiable {
    public let id: String
    public let assignmentId: String
    public let userId: String
    public let userName: String
    public let userRole: UserRoleType
    public let assignmentType: ParticipantType
    public let checkInTime: Date?
    public let checkOutTime: Date?
    public let checkInMethod: CheckInMethodType
    public let checkInLocation: Coordinate?
    public let hoursWorked: Double?
    public let status: AttendanceStatusType
    public let notes: String?
    public let isWalkIn: Bool
    
    public init(
        id: String,
        assignmentId: String,
        userId: String,
        userName: String,
        userRole: UserRoleType,
        assignmentType: ParticipantType,
        checkInTime: Date?,
        checkOutTime: Date?,
        checkInMethod: CheckInMethodType,
        checkInLocation: Coordinate?,
        hoursWorked: Double?,
        status: AttendanceStatusType,
        notes: String?,
        isWalkIn: Bool
    ) {
        self.id = id
        self.assignmentId = assignmentId
        self.userId = userId
        self.userName = userName
        self.userRole = userRole
        self.assignmentType = assignmentType
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.checkInMethod = checkInMethod
        self.checkInLocation = checkInLocation
        self.hoursWorked = hoursWorked
        self.status = status
        self.notes = notes
        self.isWalkIn = isWalkIn
    }
}
