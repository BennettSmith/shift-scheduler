import Foundation
import Testing
@testable import Troop900Data
import Troop900Domain

@Suite("InMemoryShiftRepository Tests")
struct InMemoryShiftRepositoryTests {
    
    func makeTestShift(id: String = "shift-1", date: Date = Date()) -> Shift {
        Shift(
            id: ShiftId(unchecked: id),
            date: date,
            startTime: date,
            endTime: date.addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            location: "Tree Lot",
            label: "Morning Shift",
            notes: nil,
            status: .published,
            seasonId: "season-1",
            templateId: nil,
            createdAt: Date()
        )
    }
    
    @Test("Create shift")
    func createShift() async throws {
        let repository = InMemoryShiftRepository()
        let shift = makeTestShift()
        
        let shiftId = try await repository.createShift(shift)
        
        #expect(shiftId == shift.id)
        let retrieved = try await repository.getShift(id: shift.id)
        #expect(retrieved == shift)
    }
    
    @Test("Get shift by ID")
    func getShiftById() async throws {
        let shift = makeTestShift()
        let repository = InMemoryShiftRepository(initialShifts: [shift])
        
        let retrieved = try await repository.getShift(id: shift.id)
        
        #expect(retrieved == shift)
    }
    
    @Test("Get shift by ID throws when not found")
    func getShiftByIdNotFound() async throws {
        let repository = InMemoryShiftRepository()
        let shiftId = ShiftId(unchecked: "nonexistent")
        
        do {
            _ = try await repository.getShift(id: shiftId)
            Issue.record("Expected DomainError.shiftNotFound")
        } catch DomainError.shiftNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Get shifts for date range")
    func getShiftsForDateRange() async throws {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        
        let shift1 = makeTestShift(id: "shift-1", date: today)
        let shift2 = makeTestShift(id: "shift-2", date: tomorrow)
        let shift3 = makeTestShift(id: "shift-3", date: nextWeek)
        
        let repository = InMemoryShiftRepository(initialShifts: [shift1, shift2, shift3])
        
        let shifts = try await repository.getShiftsForDateRange(start: today, end: tomorrow)
        
        #expect(shifts.count == 2)
        #expect(shifts.contains(shift1))
        #expect(shifts.contains(shift2))
        #expect(!shifts.contains(shift3))
    }
    
    @Test("Get shifts for season")
    func getShiftsForSeason() async throws {
        let shift1 = makeTestShift(id: "shift-1")
        let shift2 = makeTestShift(id: "shift-2")
        let shift3 = Shift(
            id: ShiftId(unchecked: "shift-3"),
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: "season-2",
            templateId: nil,
            createdAt: Date()
        )
        
        let repository = InMemoryShiftRepository(initialShifts: [shift1, shift2, shift3])
        
        let shifts = try await repository.getShiftsForSeason(seasonId: "season-1")
        
        #expect(shifts.count == 2)
        #expect(shifts.contains(shift1))
        #expect(shifts.contains(shift2))
        #expect(!shifts.contains(shift3))
    }
    
    @Test("Update shift")
    func updateShift() async throws {
        let shift = makeTestShift()
        let repository = InMemoryShiftRepository(initialShifts: [shift])
        
        let updatedShift = Shift(
            id: shift.id,
            date: shift.date,
            startTime: shift.startTime,
            endTime: shift.endTime,
            requiredScouts: 5,
            requiredParents: 3,
            currentScouts: shift.currentScouts,
            currentParents: shift.currentParents,
            location: shift.location,
            label: shift.label,
            notes: shift.notes,
            status: shift.status,
            seasonId: shift.seasonId,
            templateId: shift.templateId,
            createdAt: shift.createdAt
        )
        
        try await repository.updateShift(updatedShift)
        
        let retrieved = try await repository.getShift(id: shift.id)
        #expect(retrieved.requiredScouts == 5)
        #expect(retrieved.requiredParents == 3)
    }
    
    @Test("Delete shift")
    func deleteShift() async throws {
        let shift = makeTestShift()
        let repository = InMemoryShiftRepository(initialShifts: [shift])
        
        try await repository.deleteShift(id: shift.id)
        
        do {
            _ = try await repository.getShift(id: shift.id)
            Issue.record("Expected DomainError.shiftNotFound")
        } catch DomainError.shiftNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Clear removes all shifts")
    func clear() async throws {
        let shift1 = makeTestShift(id: "shift-1")
        let shift2 = makeTestShift(id: "shift-2")
        let repository = InMemoryShiftRepository(initialShifts: [shift1, shift2])
        
        repository.clear()
        
        do {
            _ = try await repository.getShift(id: shift1.id)
            Issue.record("Expected DomainError.shiftNotFound")
        } catch DomainError.shiftNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
