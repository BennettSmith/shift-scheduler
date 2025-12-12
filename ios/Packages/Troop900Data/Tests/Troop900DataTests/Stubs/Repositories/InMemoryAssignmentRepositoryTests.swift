import Foundation
import Testing
@testable import Troop900Data
import Troop900Domain

@Suite("InMemoryAssignmentRepository Tests")
struct InMemoryAssignmentRepositoryTests {
    
    func makeTestAssignment(id: String = "assignment-1", shiftId: String = "shift-1", userId: String = "user-1") -> Assignment {
        Assignment(
            id: AssignmentId(unchecked: id),
            shiftId: ShiftId(unchecked: shiftId),
            userId: UserId(unchecked: userId),
            assignmentType: .scout,
            status: .confirmed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
    }
    
    @Test("Create assignment")
    func createAssignment() async throws {
        let repository = InMemoryAssignmentRepository()
        let assignment = makeTestAssignment()
        
        let assignmentId = try await repository.createAssignment(assignment)
        
        #expect(assignmentId == assignment.id)
        let retrieved = try await repository.getAssignment(id: assignment.id)
        #expect(retrieved == assignment)
    }
    
    @Test("Get assignments for shift")
    func getAssignmentsForShift() async throws {
        let assignment1 = makeTestAssignment(id: "assignment-1", shiftId: "shift-1")
        let assignment2 = makeTestAssignment(id: "assignment-2", shiftId: "shift-1", userId: "user-2")
        let assignment3 = makeTestAssignment(id: "assignment-3", shiftId: "shift-2")
        
        let repository = InMemoryAssignmentRepository(initialAssignments: [assignment1, assignment2, assignment3])
        
        let assignments = try await repository.getAssignmentsForShift(shiftId: ShiftId(unchecked: "shift-1"))
        
        #expect(assignments.count == 2)
        #expect(assignments.contains(assignment1))
        #expect(assignments.contains(assignment2))
        #expect(!assignments.contains(assignment3))
    }
    
    @Test("Get assignments for user")
    func getAssignmentsForUser() async throws {
        let assignment1 = makeTestAssignment(id: "assignment-1", userId: "user-1")
        let assignment2 = makeTestAssignment(id: "assignment-2", shiftId: "shift-2", userId: "user-1")
        let assignment3 = makeTestAssignment(id: "assignment-3", userId: "user-2")
        
        let repository = InMemoryAssignmentRepository(initialAssignments: [assignment1, assignment2, assignment3])
        
        let assignments = try await repository.getAssignmentsForUser(userId: UserId(unchecked: "user-1"))
        
        #expect(assignments.count == 2)
        #expect(assignments.contains(assignment1))
        #expect(assignments.contains(assignment2))
        #expect(!assignments.contains(assignment3))
    }
    
    @Test("Update assignment")
    func updateAssignment() async throws {
        let assignment = makeTestAssignment()
        let repository = InMemoryAssignmentRepository(initialAssignments: [assignment])
        
        let updatedAssignment = Assignment(
            id: assignment.id,
            shiftId: assignment.shiftId,
            userId: assignment.userId,
            assignmentType: assignment.assignmentType,
            status: .cancelled,
            notes: "Cancelled",
            assignedAt: assignment.assignedAt,
            assignedBy: assignment.assignedBy
        )
        
        try await repository.updateAssignment(updatedAssignment)
        
        let retrieved = try await repository.getAssignment(id: assignment.id)
        #expect(retrieved.status == .cancelled)
        #expect(retrieved.notes == "Cancelled")
    }
    
    @Test("Delete assignment")
    func deleteAssignment() async throws {
        let assignment = makeTestAssignment()
        let repository = InMemoryAssignmentRepository(initialAssignments: [assignment])
        
        try await repository.deleteAssignment(id: assignment.id)
        
        do {
            _ = try await repository.getAssignment(id: assignment.id)
            Issue.record("Expected DomainError.assignmentNotFound")
        } catch DomainError.assignmentNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
