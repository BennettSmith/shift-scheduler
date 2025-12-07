import Foundation

/// Request to cancel an assignment.
public struct CancelAssignmentRequest: Sendable, Equatable {
    public let assignmentId: String
    public let reason: String?
    
    public init(assignmentId: String, reason: String?) {
        self.assignmentId = assignmentId
        self.reason = reason
    }
}
