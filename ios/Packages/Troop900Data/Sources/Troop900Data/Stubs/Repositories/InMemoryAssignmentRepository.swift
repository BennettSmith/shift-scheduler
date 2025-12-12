import Foundation
import Troop900Domain

/// In-memory implementation of AssignmentRepository for testing and local development.
public final class InMemoryAssignmentRepository: AssignmentRepository, @unchecked Sendable {
    private var assignments: [AssignmentId: Assignment] = [:]
    private var assignmentsByShift: [ShiftId: Set<AssignmentId>] = [:]
    private var assignmentsByUser: [UserId: Set<AssignmentId>] = [:]
    private let lock = AsyncLock()
    
    public init(initialAssignments: [Assignment] = []) {
        for assignment in initialAssignments {
            assignments[assignment.id] = assignment
            assignmentsByShift[assignment.shiftId, default: []].insert(assignment.id)
            assignmentsByUser[assignment.userId, default: []].insert(assignment.id)
        }
    }
    
    public func getAssignment(id: AssignmentId) async throws -> Assignment {
        lock.lock()
        defer { lock.unlock() }
        guard let assignment = assignments[id] else {
            throw DomainError.assignmentNotFound
        }
        return assignment
    }
    
    public func getAssignmentsForShift(shiftId: ShiftId) async throws -> [Assignment] {
        lock.lock()
        defer { lock.unlock() }
        guard let assignmentIds = assignmentsByShift[shiftId] else {
            return []
        }
        return assignmentIds.compactMap { assignments[$0] }
    }
    
    public func getAssignmentsForUser(userId: UserId) async throws -> [Assignment] {
        lock.lock()
        defer { lock.unlock() }
        guard let assignmentIds = assignmentsByUser[userId] else {
            return []
        }
        return assignmentIds.compactMap { assignments[$0] }
    }
    
    public func getAssignmentsForUserInDateRange(userId: UserId, start: Date, end: Date) async throws -> [Assignment] {
        // Note: This requires shift data to filter by date, so we'd need shift repository
        // For simplicity, return all user assignments - in real implementation, would query shifts
        let userAssignments = try await getAssignmentsForUser(userId: userId)
        return userAssignments // Simplified - would filter by shift dates in real implementation
    }
    
    public func observeAssignmentsForShift(shiftId: ShiftId) -> AsyncThrowingStream<[Assignment], Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let assignments = try await getAssignmentsForShift(shiftId: shiftId)
                    continuation.yield(assignments)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func observeAssignmentsForUser(userId: UserId) -> AsyncThrowingStream<[Assignment], Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let assignments = try await getAssignmentsForUser(userId: userId)
                    continuation.yield(assignments)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func updateAssignment(_ assignment: Assignment) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard assignments[assignment.id] != nil else {
            throw DomainError.assignmentNotFound
        }
        
        // Remove old mappings
        if let oldAssignment = assignments[assignment.id] {
            assignmentsByShift[oldAssignment.shiftId]?.remove(assignment.id)
            assignmentsByUser[oldAssignment.userId]?.remove(assignment.id)
        }
        
        // Add new mappings
        assignments[assignment.id] = assignment
        assignmentsByShift[assignment.shiftId, default: []].insert(assignment.id)
        assignmentsByUser[assignment.userId, default: []].insert(assignment.id)
    }
    
    public func createAssignment(_ assignment: Assignment) async throws -> AssignmentId {
        lock.lock()
        defer { lock.unlock() }
        
        guard assignments[assignment.id] == nil else {
            throw DomainError.invalidInput("Assignment with id \(assignment.id.value) already exists")
        }
        
        assignments[assignment.id] = assignment
        assignmentsByShift[assignment.shiftId, default: []].insert(assignment.id)
        assignmentsByUser[assignment.userId, default: []].insert(assignment.id)
        
        return assignment.id
    }
    
    public func deleteAssignment(id: AssignmentId) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard let assignment = assignments[id] else {
            throw DomainError.assignmentNotFound
        }
        
        assignments.removeValue(forKey: id)
        assignmentsByShift[assignment.shiftId]?.remove(id)
        assignmentsByUser[assignment.userId]?.remove(id)
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        assignments.removeAll()
        assignmentsByShift.removeAll()
        assignmentsByUser.removeAll()
    }
    
    public func getAllAssignments() -> [Assignment] {
        lock.lock()
        defer { lock.unlock() }
        return Array(assignments.values)
    }
}
