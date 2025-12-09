import Foundation
import Troop900Domain

/// Mock implementation of AssignmentRepository for testing
public final class MockAssignmentRepository: AssignmentRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Assignments stored by ID
    public var assignmentsById: [String: Assignment] = [:]
    
    // MARK: - Configurable Results
    
    public var getAssignmentResult: Result<Assignment, Error>?
    public var getAssignmentsForShiftResult: Result<[Assignment], Error>?
    public var getAssignmentsForUserResult: Result<[Assignment], Error>?
    public var getAssignmentsForUserInDateRangeResult: Result<[Assignment], Error>?
    public var createAssignmentResult: Result<AssignmentId, Error>?
    public var updateAssignmentError: Error?
    public var deleteAssignmentError: Error?
    
    // MARK: - Call Tracking
    
    public var getAssignmentCallCount = 0
    public var getAssignmentCalledWith: [AssignmentId] = []
    
    public var getAssignmentsForShiftCallCount = 0
    public var getAssignmentsForShiftCalledWith: [ShiftId] = []
    
    public var getAssignmentsForUserCallCount = 0
    public var getAssignmentsForUserCalledWith: [UserId] = []
    
    public var getAssignmentsForUserInDateRangeCallCount = 0
    public var getAssignmentsForUserInDateRangeCalledWith: [(userId: UserId, start: Date, end: Date)] = []
    
    public var createAssignmentCallCount = 0
    public var createAssignmentCalledWith: [Assignment] = []
    
    public var updateAssignmentCallCount = 0
    public var updateAssignmentCalledWith: [Assignment] = []
    
    public var deleteAssignmentCallCount = 0
    public var deleteAssignmentCalledWith: [AssignmentId] = []
    
    // MARK: - AssignmentRepository Implementation
    
    public func getAssignment(id: AssignmentId) async throws -> Assignment {
        getAssignmentCallCount += 1
        getAssignmentCalledWith.append(id)
        
        if let result = getAssignmentResult {
            return try result.get()
        }
        
        guard let assignment = assignmentsById[id.value] else {
            throw DomainError.assignmentNotFound
        }
        return assignment
    }
    
    public func getAssignmentsForShift(shiftId: ShiftId) async throws -> [Assignment] {
        getAssignmentsForShiftCallCount += 1
        getAssignmentsForShiftCalledWith.append(shiftId)
        
        if let result = getAssignmentsForShiftResult {
            return try result.get()
        }
        
        return assignmentsById.values.filter { $0.shiftId == shiftId }
    }
    
    public func getAssignmentsForUser(userId: UserId) async throws -> [Assignment] {
        getAssignmentsForUserCallCount += 1
        getAssignmentsForUserCalledWith.append(userId)
        
        if let result = getAssignmentsForUserResult {
            return try result.get()
        }
        
        return assignmentsById.values.filter { $0.userId == userId }
    }
    
    public func getAssignmentsForUserInDateRange(userId: UserId, start: Date, end: Date) async throws -> [Assignment] {
        getAssignmentsForUserInDateRangeCallCount += 1
        getAssignmentsForUserInDateRangeCalledWith.append((userId, start, end))
        
        if let result = getAssignmentsForUserInDateRangeResult {
            return try result.get()
        }
        
        // Note: This mock doesn't filter by date since assignments don't have dates
        // Real implementation would join with shifts
        return assignmentsById.values.filter { $0.userId == userId }
    }
    
    public func observeAssignmentsForShift(shiftId: ShiftId) -> AsyncThrowingStream<[Assignment], Error> {
        AsyncThrowingStream { continuation in
            let assignments = assignmentsById.values.filter { $0.shiftId == shiftId }
            continuation.yield(Array(assignments))
            continuation.finish()
        }
    }
    
    public func observeAssignmentsForUser(userId: UserId) -> AsyncThrowingStream<[Assignment], Error> {
        AsyncThrowingStream { continuation in
            let assignments = assignmentsById.values.filter { $0.userId == userId }
            continuation.yield(Array(assignments))
            continuation.finish()
        }
    }
    
    public func updateAssignment(_ assignment: Assignment) async throws {
        updateAssignmentCallCount += 1
        updateAssignmentCalledWith.append(assignment)
        
        if let error = updateAssignmentError {
            throw error
        }
        
        assignmentsById[assignment.id.value] = assignment
    }
    
    public func createAssignment(_ assignment: Assignment) async throws -> AssignmentId {
        createAssignmentCallCount += 1
        createAssignmentCalledWith.append(assignment)
        
        if let result = createAssignmentResult {
            return try result.get()
        }
        
        assignmentsById[assignment.id.value] = assignment
        return assignment.id
    }
    
    public func deleteAssignment(id: AssignmentId) async throws {
        deleteAssignmentCallCount += 1
        deleteAssignmentCalledWith.append(id)
        
        if let error = deleteAssignmentError {
            throw error
        }
        
        assignmentsById.removeValue(forKey: id.value)
    }
    
    // MARK: - Test Helpers
    
    /// Adds an assignment to the storage
    public func addAssignment(_ assignment: Assignment) {
        assignmentsById[assignment.id.value] = assignment
    }
    
    /// Resets all state and call tracking
    public func reset() {
        assignmentsById.removeAll()
        getAssignmentResult = nil
        getAssignmentsForShiftResult = nil
        getAssignmentsForUserResult = nil
        getAssignmentsForUserInDateRangeResult = nil
        createAssignmentResult = nil
        updateAssignmentError = nil
        deleteAssignmentError = nil
        getAssignmentCallCount = 0
        getAssignmentCalledWith.removeAll()
        getAssignmentsForShiftCallCount = 0
        getAssignmentsForShiftCalledWith.removeAll()
        getAssignmentsForUserCallCount = 0
        getAssignmentsForUserCalledWith.removeAll()
        getAssignmentsForUserInDateRangeCallCount = 0
        getAssignmentsForUserInDateRangeCalledWith.removeAll()
        createAssignmentCallCount = 0
        createAssignmentCalledWith.removeAll()
        updateAssignmentCallCount = 0
        updateAssignmentCalledWith.removeAll()
        deleteAssignmentCallCount = 0
        deleteAssignmentCalledWith.removeAll()
    }
}
