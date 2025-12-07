import Foundation
import Troop900Domain

/// Detailed information about a specific shift.
public struct ShiftDetailResponse: Sendable, Equatable {
    public let shift: Shift
    public let assignments: [AssignmentInfo]
    public let canSignUp: Bool
    public let canCancel: Bool
    public let userAssignment: AssignmentInfo?
    
    public init(
        shift: Shift,
        assignments: [AssignmentInfo],
        canSignUp: Bool,
        canCancel: Bool,
        userAssignment: AssignmentInfo?
    ) {
        self.shift = shift
        self.assignments = assignments
        self.canSignUp = canSignUp
        self.canCancel = canCancel
        self.userAssignment = userAssignment
    }
}
