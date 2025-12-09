import Foundation

/// Request to sign up for a shift.
public struct SignUpForShiftRequest: Sendable, Equatable {
    public let shiftId: String
    public let userId: String
    public let assignmentType: AssignmentTypeValue
    public let notes: String?
    
    public init(shiftId: String, userId: String, assignmentType: AssignmentTypeValue, notes: String?) {
        self.shiftId = shiftId
        self.userId = userId
        self.assignmentType = assignmentType
        self.notes = notes
    }
}
