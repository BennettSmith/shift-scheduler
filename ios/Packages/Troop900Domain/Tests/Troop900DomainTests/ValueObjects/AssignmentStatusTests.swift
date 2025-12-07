import Testing
@testable import Troop900Domain

@Suite("AssignmentStatus Tests")
struct AssignmentStatusTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(AssignmentStatus.pending.displayName == "Pending")
        #expect(AssignmentStatus.confirmed.displayName == "Confirmed")
        #expect(AssignmentStatus.cancelled.displayName == "Cancelled")
        #expect(AssignmentStatus.completed.displayName == "Completed")
    }
    
    @Test("Pending is active")
    func pendingIsActive() {
        #expect(AssignmentStatus.pending.isActive)
    }
    
    @Test("Confirmed is active")
    func confirmedIsActive() {
        #expect(AssignmentStatus.confirmed.isActive)
    }
    
    @Test("Cancelled is not active")
    func cancelledIsNotActive() {
        #expect(!AssignmentStatus.cancelled.isActive)
    }
    
    @Test("Completed is not active")
    func completedIsNotActive() {
        #expect(!AssignmentStatus.completed.isActive)
    }
}
