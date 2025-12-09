import Foundation
import Troop900Domain

/// Mock implementation of AttendanceRepository for testing
public final class MockAttendanceRepository: AttendanceRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Attendance records stored by ID
    public var recordsById: [String: AttendanceRecord] = [:]
    
    /// Attendance records stored by assignment ID (for lookup)
    public var recordsByAssignmentId: [String: AttendanceRecord] = [:]
    
    // MARK: - Configurable Results
    
    public var getAttendanceRecordResult: Result<AttendanceRecord, Error>?
    public var getAttendanceRecordByAssignmentResult: Result<AttendanceRecord?, Error>?
    public var getAttendanceRecordsForShiftResult: Result<[AttendanceRecord], Error>?
    public var getAttendanceRecordsForUserResult: Result<[AttendanceRecord], Error>?
    public var createAttendanceRecordResult: Result<AttendanceRecordId, Error>?
    public var updateAttendanceRecordError: Error?
    
    // MARK: - Call Tracking
    
    public var getAttendanceRecordCallCount = 0
    public var getAttendanceRecordCalledWith: [AttendanceRecordId] = []
    
    public var getAttendanceRecordByAssignmentCallCount = 0
    public var getAttendanceRecordByAssignmentCalledWith: [AssignmentId] = []
    
    public var getAttendanceRecordsForShiftCallCount = 0
    public var getAttendanceRecordsForShiftCalledWith: [ShiftId] = []
    
    public var getAttendanceRecordsForUserCallCount = 0
    public var getAttendanceRecordsForUserCalledWith: [UserId] = []
    
    public var createAttendanceRecordCallCount = 0
    public var createAttendanceRecordCalledWith: [AttendanceRecord] = []
    
    public var updateAttendanceRecordCallCount = 0
    public var updateAttendanceRecordCalledWith: [AttendanceRecord] = []
    
    // MARK: - AttendanceRepository Implementation
    
    public func getAttendanceRecord(id: AttendanceRecordId) async throws -> AttendanceRecord {
        getAttendanceRecordCallCount += 1
        getAttendanceRecordCalledWith.append(id)
        
        if let result = getAttendanceRecordResult {
            return try result.get()
        }
        
        guard let record = recordsById[id.value] else {
            throw DomainError.attendanceRecordNotFound
        }
        return record
    }
    
    public func getAttendanceRecordByAssignment(assignmentId: AssignmentId) async throws -> AttendanceRecord? {
        getAttendanceRecordByAssignmentCallCount += 1
        getAttendanceRecordByAssignmentCalledWith.append(assignmentId)
        
        if let result = getAttendanceRecordByAssignmentResult {
            return try result.get()
        }
        
        return recordsByAssignmentId[assignmentId.value]
    }
    
    public func getAttendanceRecordsForShift(shiftId: ShiftId) async throws -> [AttendanceRecord] {
        getAttendanceRecordsForShiftCallCount += 1
        getAttendanceRecordsForShiftCalledWith.append(shiftId)
        
        if let result = getAttendanceRecordsForShiftResult {
            return try result.get()
        }
        
        return recordsById.values.filter { $0.shiftId == shiftId }
    }
    
    public func getAttendanceRecordsForUser(userId: UserId) async throws -> [AttendanceRecord] {
        getAttendanceRecordsForUserCallCount += 1
        getAttendanceRecordsForUserCalledWith.append(userId)
        
        if let result = getAttendanceRecordsForUserResult {
            return try result.get()
        }
        
        return recordsById.values.filter { $0.userId == userId }
    }
    
    public func observeAttendanceRecordByAssignment(assignmentId: AssignmentId) -> AsyncThrowingStream<AttendanceRecord?, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(recordsByAssignmentId[assignmentId.value])
            continuation.finish()
        }
    }
    
    public func updateAttendanceRecord(_ record: AttendanceRecord) async throws {
        updateAttendanceRecordCallCount += 1
        updateAttendanceRecordCalledWith.append(record)
        
        if let error = updateAttendanceRecordError {
            throw error
        }
        
        recordsById[record.id.value] = record
        recordsByAssignmentId[record.assignmentId.value] = record
    }
    
    public func createAttendanceRecord(_ record: AttendanceRecord) async throws -> AttendanceRecordId {
        createAttendanceRecordCallCount += 1
        createAttendanceRecordCalledWith.append(record)
        
        if let result = createAttendanceRecordResult {
            return try result.get()
        }
        
        recordsById[record.id.value] = record
        recordsByAssignmentId[record.assignmentId.value] = record
        return record.id
    }
    
    // MARK: - Test Helpers
    
    /// Adds a record to all appropriate indexes
    public func addRecord(_ record: AttendanceRecord) {
        recordsById[record.id.value] = record
        recordsByAssignmentId[record.assignmentId.value] = record
    }
    
    /// Resets all state and call tracking
    public func reset() {
        recordsById.removeAll()
        recordsByAssignmentId.removeAll()
        getAttendanceRecordResult = nil
        getAttendanceRecordByAssignmentResult = nil
        getAttendanceRecordsForShiftResult = nil
        getAttendanceRecordsForUserResult = nil
        createAttendanceRecordResult = nil
        updateAttendanceRecordError = nil
        getAttendanceRecordCallCount = 0
        getAttendanceRecordCalledWith.removeAll()
        getAttendanceRecordByAssignmentCallCount = 0
        getAttendanceRecordByAssignmentCalledWith.removeAll()
        getAttendanceRecordsForShiftCallCount = 0
        getAttendanceRecordsForShiftCalledWith.removeAll()
        getAttendanceRecordsForUserCallCount = 0
        getAttendanceRecordsForUserCalledWith.removeAll()
        createAttendanceRecordCallCount = 0
        createAttendanceRecordCalledWith.removeAll()
        updateAttendanceRecordCallCount = 0
        updateAttendanceRecordCalledWith.removeAll()
    }
}
