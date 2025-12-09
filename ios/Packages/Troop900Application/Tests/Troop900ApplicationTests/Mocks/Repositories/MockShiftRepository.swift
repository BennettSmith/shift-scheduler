import Foundation
import Troop900Domain

/// Mock implementation of ShiftRepository for testing
public final class MockShiftRepository: ShiftRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Shifts stored by ID
    public var shiftsById: [String: Shift] = [:]
    
    // MARK: - Configurable Results
    
    /// Override result for getShift - if set, this is returned instead of looking up in shiftsById
    public var getShiftResult: Result<Shift, Error>?
    
    /// Override result for getShiftsForDateRange
    public var getShiftsForDateRangeResult: Result<[Shift], Error>?
    
    /// Override result for getShiftsForSeason
    public var getShiftsForSeasonResult: Result<[Shift], Error>?
    
    /// Override result for createShift
    public var createShiftResult: Result<ShiftId, Error>?
    
    /// Override result for updateShift
    public var updateShiftError: Error?
    
    /// Override result for deleteShift
    public var deleteShiftError: Error?
    
    // MARK: - Call Tracking
    
    public var getShiftCallCount = 0
    public var getShiftCalledWith: [ShiftId] = []
    
    public var getShiftsForDateRangeCallCount = 0
    public var getShiftsForDateRangeCalledWith: [(start: Date, end: Date)] = []
    
    public var getShiftsForSeasonCallCount = 0
    public var getShiftsForSeasonCalledWith: [String] = []
    
    public var createShiftCallCount = 0
    public var createShiftCalledWith: [Shift] = []
    
    public var updateShiftCallCount = 0
    public var updateShiftCalledWith: [Shift] = []
    
    public var deleteShiftCallCount = 0
    public var deleteShiftCalledWith: [ShiftId] = []
    
    // MARK: - ShiftRepository Implementation
    
    public func getShift(id: ShiftId) async throws -> Shift {
        getShiftCallCount += 1
        getShiftCalledWith.append(id)
        
        if let result = getShiftResult {
            return try result.get()
        }
        
        guard let shift = shiftsById[id.value] else {
            throw DomainError.shiftNotFound
        }
        return shift
    }
    
    public func getShiftsForDateRange(start: Date, end: Date) async throws -> [Shift] {
        getShiftsForDateRangeCallCount += 1
        getShiftsForDateRangeCalledWith.append((start, end))
        
        if let result = getShiftsForDateRangeResult {
            return try result.get()
        }
        
        return shiftsById.values.filter { shift in
            shift.date >= start && shift.date <= end
        }.sorted { $0.date < $1.date }
    }
    
    public func getShiftsForSeason(seasonId: String) async throws -> [Shift] {
        getShiftsForSeasonCallCount += 1
        getShiftsForSeasonCalledWith.append(seasonId)
        
        if let result = getShiftsForSeasonResult {
            return try result.get()
        }
        
        return shiftsById.values.filter { $0.seasonId == seasonId }
            .sorted { $0.date < $1.date }
    }
    
    public func observeShift(id: ShiftId) -> AsyncThrowingStream<Shift, Error> {
        AsyncThrowingStream { continuation in
            if let shift = shiftsById[id.value] {
                continuation.yield(shift)
            }
            continuation.finish()
        }
    }
    
    public func observeShiftsForDateRange(start: Date, end: Date) -> AsyncThrowingStream<[Shift], Error> {
        AsyncThrowingStream { continuation in
            let shifts = shiftsById.values.filter { shift in
                shift.date >= start && shift.date <= end
            }.sorted { $0.date < $1.date }
            continuation.yield(Array(shifts))
            continuation.finish()
        }
    }
    
    public func updateShift(_ shift: Shift) async throws {
        updateShiftCallCount += 1
        updateShiftCalledWith.append(shift)
        
        if let error = updateShiftError {
            throw error
        }
        
        shiftsById[shift.id.value] = shift
    }
    
    public func createShift(_ shift: Shift) async throws -> ShiftId {
        createShiftCallCount += 1
        createShiftCalledWith.append(shift)
        
        if let result = createShiftResult {
            return try result.get()
        }
        
        shiftsById[shift.id.value] = shift
        return shift.id
    }
    
    public func deleteShift(id: ShiftId) async throws {
        deleteShiftCallCount += 1
        deleteShiftCalledWith.append(id)
        
        if let error = deleteShiftError {
            throw error
        }
        
        shiftsById.removeValue(forKey: id.value)
    }
    
    // MARK: - Test Helpers
    
    /// Adds a shift to the storage
    public func addShift(_ shift: Shift) {
        shiftsById[shift.id.value] = shift
    }
    
    /// Resets all state and call tracking
    public func reset() {
        shiftsById.removeAll()
        getShiftResult = nil
        getShiftsForDateRangeResult = nil
        getShiftsForSeasonResult = nil
        createShiftResult = nil
        updateShiftError = nil
        deleteShiftError = nil
        getShiftCallCount = 0
        getShiftCalledWith.removeAll()
        getShiftsForDateRangeCallCount = 0
        getShiftsForDateRangeCalledWith.removeAll()
        getShiftsForSeasonCallCount = 0
        getShiftsForSeasonCalledWith.removeAll()
        createShiftCallCount = 0
        createShiftCalledWith.removeAll()
        updateShiftCallCount = 0
        updateShiftCalledWith.removeAll()
        deleteShiftCallCount = 0
        deleteShiftCalledWith.removeAll()
    }
}
