import Foundation
import Testing
@testable import Troop900Domain

@Suite("Assignment Tests")
struct AssignmentTests {
    
    @Test("Assignment initialization")
    func assignmentInitialization() {
        let assignment = Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            assignmentType: AssignmentType.scout,
            status: AssignmentStatus.confirmed,
            notes: "Looking forward to it",
            assignedAt: Date(),
            assignedBy: UserId(unchecked: "user-2")
        )
        
        #expect(assignment.id.value == "assignment-1")
        #expect(assignment.shiftId.value == "shift-1")
        #expect(assignment.userId.value == "user-1")
        #expect(assignment.assignmentType == AssignmentType.scout)
        #expect(assignment.status == AssignmentStatus.confirmed)
    }
    
    @Test("Confirmed assignment is active")
    func confirmedIsActive() {
        let assignment = Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            assignmentType: AssignmentType.scout,
            status: AssignmentStatus.confirmed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        #expect(assignment.isActive)
    }
    
    @Test("Pending assignment is active")
    func pendingIsActive() {
        let assignment = Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            assignmentType: AssignmentType.scout,
            status: AssignmentStatus.pending,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        #expect(assignment.isActive)
    }
    
    @Test("Cancelled assignment is not active")
    func cancelledIsNotActive() {
        let assignment = Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            assignmentType: AssignmentType.scout,
            status: AssignmentStatus.cancelled,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        #expect(!assignment.isActive)
    }
    
    @Test("Completed assignment is not active")
    func completedIsNotActive() {
        let assignment = Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "user-1"),
            assignmentType: AssignmentType.scout,
            status: AssignmentStatus.completed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        #expect(!assignment.isActive)
    }
}
