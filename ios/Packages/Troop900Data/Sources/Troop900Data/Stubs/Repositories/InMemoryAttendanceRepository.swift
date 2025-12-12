import Foundation
import Troop900Domain

/// In-memory implementation of AttendanceRepository for testing and local development.
public final class InMemoryAttendanceRepository: AttendanceRepository, @unchecked Sendable {
    private var records: [AttendanceRecordId: AttendanceRecord] = [:]
    private var recordsByAssignment: [AssignmentId: AttendanceRecordId] = [:]
    private var recordsByShift: [ShiftId: Set<AttendanceRecordId>] = [:]
    private var recordsByUser: [UserId: Set<AttendanceRecordId>] = [:]
    private let lock = AsyncLock()
    
    public init(initialRecords: [AttendanceRecord] = []) {
        for record in initialRecords {
            records[record.id] = record
            recordsByAssignment[record.assignmentId] = record.id
            recordsByShift[record.shiftId, default: []].insert(record.id)
            recordsByUser[record.userId, default: []].insert(record.id)
        }
    }
    
    public func getAttendanceRecord(id: AttendanceRecordId) async throws -> AttendanceRecord {
        lock.lock()
        defer { lock.unlock() }
        guard let record = records[id] else {
            throw DomainError.attendanceRecordNotFound
        }
        return record
    }
    
    public func getAttendanceRecordByAssignment(assignmentId: AssignmentId) async throws -> AttendanceRecord? {
        lock.lock()
        defer { lock.unlock() }
        guard let recordId = recordsByAssignment[assignmentId] else {
            return nil
        }
        return records[recordId]
    }
    
    public func getAttendanceRecordsForShift(shiftId: ShiftId) async throws -> [AttendanceRecord] {
        lock.lock()
        defer { lock.unlock() }
        guard let recordIds = recordsByShift[shiftId] else {
            return []
        }
        return recordIds.compactMap { records[$0] }
    }
    
    public func getAttendanceRecordsForUser(userId: UserId) async throws -> [AttendanceRecord] {
        lock.lock()
        defer { lock.unlock() }
        guard let recordIds = recordsByUser[userId] else {
            return []
        }
        return recordIds.compactMap { records[$0] }
    }
    
    public func observeAttendanceRecordByAssignment(assignmentId: AssignmentId) -> AsyncThrowingStream<AttendanceRecord?, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let record = try await getAttendanceRecordByAssignment(assignmentId: assignmentId)
                    continuation.yield(record)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func updateAttendanceRecord(_ record: AttendanceRecord) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard records[record.id] != nil else {
            throw DomainError.attendanceRecordNotFound
        }
        
        // Remove old mappings
        if let oldRecord = records[record.id] {
            recordsByShift[oldRecord.shiftId]?.remove(record.id)
            recordsByUser[oldRecord.userId]?.remove(record.id)
        }
        
        // Add new mappings
        records[record.id] = record
        recordsByAssignment[record.assignmentId] = record.id
        recordsByShift[record.shiftId, default: []].insert(record.id)
        recordsByUser[record.userId, default: []].insert(record.id)
    }
    
    public func createAttendanceRecord(_ record: AttendanceRecord) async throws -> AttendanceRecordId {
        lock.lock()
        defer { lock.unlock() }
        
        guard records[record.id] == nil else {
            throw DomainError.invalidInput("AttendanceRecord with id \(record.id.value) already exists")
        }
        
        records[record.id] = record
        recordsByAssignment[record.assignmentId] = record.id
        recordsByShift[record.shiftId, default: []].insert(record.id)
        recordsByUser[record.userId, default: []].insert(record.id)
        
        return record.id
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        records.removeAll()
        recordsByAssignment.removeAll()
        recordsByShift.removeAll()
        recordsByUser.removeAll()
    }
    
    public func getAllRecords() -> [AttendanceRecord] {
        lock.lock()
        defer { lock.unlock() }
        return Array(records.values)
    }
}
