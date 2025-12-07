import Foundation
import Troop900Domain

/// Information about an assignment for display purposes.
public struct AssignmentInfo: Sendable, Equatable, Identifiable {
    public let id: String
    public let userId: String
    public let userName: String
    public let assignmentType: AssignmentType
    public let status: AssignmentStatus
    public let notes: String?
    public let assignedAt: Date
    
    public init(
        id: String,
        userId: String,
        userName: String,
        assignmentType: AssignmentType,
        status: AssignmentStatus,
        notes: String?,
        assignedAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.assignmentType = assignmentType
        self.status = status
        self.notes = notes
        self.assignedAt = assignedAt
    }
}
