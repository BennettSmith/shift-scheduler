import Testing
import Foundation
@testable import Troop900Domain

@Suite("Shift Tests")
struct ShiftTests {
    
    @Test("Shift initialization")
    func shiftInitialization() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        
        let shift = Shift(
            id: "shift-1",
            date: Date(),
            startTime: startTime,
            endTime: endTime,
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 1,
            currentParents: 0,
            location: "Tree Lot",
            label: "Morning Shift",
            notes: "Bring gloves",
            status: .published,
            seasonId: "season-1",
            templateId: "template-1",
            createdAt: Date()
        )
        
        #expect(shift.id == "shift-1")
        #expect(shift.requiredScouts == 3)
        #expect(shift.requiredParents == 2)
        #expect(shift.currentScouts == 1)
        #expect(shift.currentParents == 0)
    }
    
    @Test("Fully staffed shift has full status")
    func fullyStaffedStatus() {
        let shift = Shift(
            id: "shift-1",
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 3,
            currentParents: 2,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        #expect(shift.staffingStatus == .full)
    }
    
    @Test("Partially staffed shift has partial status")
    func partiallyStaffedStatus() {
        let shift = Shift(
            id: "shift-1",
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 1,
            currentParents: 0,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        #expect(shift.staffingStatus == .partial)
    }
    
    @Test("Empty shift has empty status")
    func emptyStaffedStatus() {
        let shift = Shift(
            id: "shift-1",
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
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        #expect(shift.staffingStatus == .empty)
    }
    
    @Test("Shift needs scouts when under requirement")
    func needsScouts() {
        let shift = Shift(
            id: "shift-1",
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 1,
            currentParents: 2,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        #expect(shift.needsScouts)
    }
    
    @Test("Shift does not need scouts when requirement is met")
    func doesNotNeedScouts() {
        let shift = Shift(
            id: "shift-1",
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 3,
            currentParents: 1,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        #expect(!shift.needsScouts)
    }
    
    @Test("Shift needs parents when under requirement")
    func needsParents() {
        let shift = Shift(
            id: "shift-1",
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 3,
            currentParents: 0,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        #expect(shift.needsParents)
    }
    
    @Test("Shift duration is calculated correctly")
    func shiftDuration() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(7200) // 2 hours
        
        let shift = Shift(
            id: "shift-1",
            date: Date(),
            startTime: startTime,
            endTime: endTime,
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        #expect(shift.duration == 7200)
    }
}
