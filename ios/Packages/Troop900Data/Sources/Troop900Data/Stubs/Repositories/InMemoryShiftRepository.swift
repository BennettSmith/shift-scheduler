import Foundation
import Troop900Domain

/// In-memory implementation of ShiftRepository for testing and local development.
public final class InMemoryShiftRepository: ShiftRepository, @unchecked Sendable {
    private var shifts: [ShiftId: Shift] = [:]
    private var shiftsBySeason: [String: Set<ShiftId>] = [:]
    private let lock = AsyncLock()
    
    public init(initialShifts: [Shift] = []) {
        for shift in initialShifts {
            shifts[shift.id] = shift
            if let seasonId = shift.seasonId {
                shiftsBySeason[seasonId, default: []].insert(shift.id)
            }
        }
    }
    
    public func getShift(id: ShiftId) async throws -> Shift {
        lock.lock()
        defer { lock.unlock() }
        guard let shift = shifts[id] else {
            throw DomainError.shiftNotFound
        }
        return shift
    }
    
    public func getShiftsForDateRange(start: Date, end: Date) async throws -> [Shift] {
        lock.lock()
        defer { lock.unlock() }
        return shifts.values.filter { shift in
            let shiftDate = Calendar.current.startOfDay(for: shift.date)
            let startDate = Calendar.current.startOfDay(for: start)
            let endDate = Calendar.current.startOfDay(for: end)
            return shiftDate >= startDate && shiftDate <= endDate
        }
    }
    
    public func getShiftsForSeason(seasonId: String) async throws -> [Shift] {
        lock.lock()
        defer { lock.unlock() }
        guard let shiftIds = shiftsBySeason[seasonId] else {
            return []
        }
        return shiftIds.compactMap { shifts[$0] }
    }
    
    public func observeShift(id: ShiftId) -> AsyncThrowingStream<Shift, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let shift = try await getShift(id: id)
                    continuation.yield(shift)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func observeShiftsForDateRange(start: Date, end: Date) -> AsyncThrowingStream<[Shift], Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let shifts = try await getShiftsForDateRange(start: start, end: end)
                    continuation.yield(shifts)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func updateShift(_ shift: Shift) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard shifts[shift.id] != nil else {
            throw DomainError.shiftNotFound
        }
        
        // Remove old season mapping
        if let oldShift = shifts[shift.id], let oldSeasonId = oldShift.seasonId {
            shiftsBySeason[oldSeasonId]?.remove(shift.id)
        }
        
        // Add new season mapping
        shifts[shift.id] = shift
        if let seasonId = shift.seasonId {
            shiftsBySeason[seasonId, default: []].insert(shift.id)
        }
    }
    
    public func createShift(_ shift: Shift) async throws -> ShiftId {
        lock.lock()
        defer { lock.unlock() }
        
        guard shifts[shift.id] == nil else {
            throw DomainError.invalidInput("Shift with id \(shift.id.value) already exists")
        }
        
        shifts[shift.id] = shift
        if let seasonId = shift.seasonId {
            shiftsBySeason[seasonId, default: []].insert(shift.id)
        }
        
        return shift.id
    }
    
    public func deleteShift(id: ShiftId) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard let shift = shifts[id] else {
            throw DomainError.shiftNotFound
        }
        
        shifts.removeValue(forKey: id)
        if let seasonId = shift.seasonId {
            shiftsBySeason[seasonId]?.remove(id)
        }
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        shifts.removeAll()
        shiftsBySeason.removeAll()
    }
    
    public func getAllShifts() -> [Shift] {
        lock.lock()
        defer { lock.unlock() }
        return Array(shifts.values)
    }
}
