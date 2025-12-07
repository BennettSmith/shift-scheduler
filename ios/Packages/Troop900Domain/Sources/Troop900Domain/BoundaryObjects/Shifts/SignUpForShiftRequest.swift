import Foundation

/// Request to sign up for a shift.
public struct SignUpForShiftRequest: Sendable, Equatable {
    public let shiftId: String
    public let userId: String
    public let assignmentType: AssignmentType
    public let notes: String?
    
    public init(shiftId: String, userId: String, assignmentType: AssignmentType, notes: String?) {
        self.shiftId = shiftId
        self.userId = userId
        self.assignmentType = assignmentType
        self.notes = notes
    }
}
