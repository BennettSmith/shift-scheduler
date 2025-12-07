import Foundation

/// Protocol for attendance record data persistence operations.
public protocol AttendanceRepository: Sendable {
    /// Get an attendance record by ID.
    /// - Parameter id: The attendance record's ID.
    /// - Returns: The attendance record entity.
    func getAttendanceRecord(id: String) async throws -> AttendanceRecord
    
    /// Get an attendance record by assignment ID.
    /// - Parameter assignmentId: The assignment's ID.
    /// - Returns: The attendance record entity, or nil if not found.
    func getAttendanceRecordByAssignment(assignmentId: String) async throws -> AttendanceRecord?
    
    /// Get all attendance records for a shift.
    /// - Parameter shiftId: The shift's ID.
    /// - Returns: An array of attendance records for the shift.
    func getAttendanceRecordsForShift(shiftId: String) async throws -> [AttendanceRecord]
    
    /// Get all attendance records for a user.
    /// - Parameter userId: The user's ID.
    /// - Returns: An array of attendance records for the user.
    func getAttendanceRecordsForUser(userId: String) async throws -> [AttendanceRecord]
    
    /// Observe an attendance record by assignment ID for real-time updates.
    /// - Parameter assignmentId: The assignment's ID.
    /// - Returns: A stream of attendance record entities.
    func observeAttendanceRecordByAssignment(assignmentId: String) -> AsyncThrowingStream<AttendanceRecord?, Error>
    
    /// Update an attendance record entity.
    /// - Parameter record: The attendance record entity to update.
    func updateAttendanceRecord(_ record: AttendanceRecord) async throws
    
    /// Create a new attendance record entity.
    /// - Parameter record: The attendance record entity to create.
    /// - Returns: The created attendance record's ID.
    func createAttendanceRecord(_ record: AttendanceRecord) async throws -> String
}
