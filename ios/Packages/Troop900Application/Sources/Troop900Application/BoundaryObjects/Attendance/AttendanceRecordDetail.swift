import Foundation
import Troop900Domain

/// Detailed information about an attendance record for committee review.
public struct AttendanceRecordDetail: Sendable, Equatable, Identifiable {
    public let id: String
    public let assignmentId: String
    public let userId: String
    public let userName: String
    public let userRole: UserRole
    public let assignmentType: AssignmentType
    public let checkInTime: Date?
    public let checkOutTime: Date?
    public let checkInMethod: CheckInMethod
    public let checkInLocation: GeoLocation?
    public let hoursWorked: Double?
    public let status: AttendanceStatus
    public let notes: String?
    public let isWalkIn: Bool
    
    public init(
        id: String,
        assignmentId: String,
        userId: String,
        userName: String,
        userRole: UserRole,
        assignmentType: AssignmentType,
        checkInTime: Date?,
        checkOutTime: Date?,
        checkInMethod: CheckInMethod,
        checkInLocation: GeoLocation?,
        hoursWorked: Double?,
        status: AttendanceStatus,
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
