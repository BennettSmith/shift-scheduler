import Foundation
import Testing
@testable import Troop900Domain

@Suite("Assignment Tests")
struct AssignmentTests {
    
    @Test("Assignment initialization")
    func assignmentInitialization() {
        let assignment = Assignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: "user-1",
            assignmentType: .scout,
            status: .confirmed,
            notes: "Looking forward to it",
            assignedAt: Date(),
            assignedBy: "user-2"
        )
        
        #expect(assignment.id == "assignment-1")
        #expect(assignment.shiftId == "shift-1")
        #expect(assignment.userId == "user-1")
        #expect(assignment.assignmentType == .scout)
        #expect(assignment.status == .confirmed)
    }
    
    @Test("Confirmed assignment is active")
    func confirmedIsActive() {
        let assignment = Assignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: "user-1",
            assignmentType: .scout,
            status: .confirmed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        #expect(assignment.isActive)
    }
    
    @Test("Pending assignment is active")
    func pendingIsActive() {
        let assignment = Assignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: "user-1",
            assignmentType: .scout,
            status: .pending,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        #expect(assignment.isActive)
    }
    
    @Test("Cancelled assignment is not active")
    func cancelledIsNotActive() {
        let assignment = Assignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: "user-1",
            assignmentType: .scout,
            status: .cancelled,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        #expect(!assignment.isActive)
    }
    
    @Test("Completed assignment is not active")
    func completedIsNotActive() {
        let assignment = Assignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: "user-1",
            assignmentType: .scout,
            status: .completed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        #expect(!assignment.isActive)
    }
}
