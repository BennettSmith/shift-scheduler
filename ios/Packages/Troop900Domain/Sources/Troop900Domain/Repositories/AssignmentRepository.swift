import Foundation

/// Protocol for assignment data persistence operations.
public protocol AssignmentRepository: Sendable {
    /// Get an assignment by ID.
    /// - Parameter id: The assignment's ID.
    /// - Returns: The assignment entity.
    func getAssignment(id: String) async throws -> Assignment
    
    /// Get all assignments for a shift.
    /// - Parameter shiftId: The shift's ID.
    /// - Returns: An array of assignments for the shift.
    func getAssignmentsForShift(shiftId: String) async throws -> [Assignment]
    
    /// Get all assignments for a user.
    /// - Parameter userId: The user's ID.
    /// - Returns: An array of assignments for the user.
    func getAssignmentsForUser(userId: String) async throws -> [Assignment]
    
    /// Get all assignments for a user within a date range.
    /// - Parameters:
    ///   - userId: The user's ID.
    ///   - start: The start date.
    ///   - end: The end date.
    /// - Returns: An array of assignments for the user in the date range.
    func getAssignmentsForUserInDateRange(userId: String, start: Date, end: Date) async throws -> [Assignment]
    
    /// Observe assignments for a shift for real-time updates.
    /// - Parameter shiftId: The shift's ID.
    /// - Returns: A stream of assignment arrays.
    func observeAssignmentsForShift(shiftId: String) -> AsyncThrowingStream<[Assignment], Error>
    
    /// Observe assignments for a user for real-time updates.
    /// - Parameter userId: The user's ID.
    /// - Returns: A stream of assignment arrays.
    func observeAssignmentsForUser(userId: String) -> AsyncThrowingStream<[Assignment], Error>
    
    /// Update an assignment entity.
    /// - Parameter assignment: The assignment entity to update.
    func updateAssignment(_ assignment: Assignment) async throws
    
    /// Create a new assignment entity.
    /// - Parameter assignment: The assignment entity to create.
    /// - Returns: The created assignment's ID.
    func createAssignment(_ assignment: Assignment) async throws -> String
    
    /// Delete an assignment by ID.
    /// - Parameter id: The assignment's ID.
    func deleteAssignment(id: String) async throws
}
