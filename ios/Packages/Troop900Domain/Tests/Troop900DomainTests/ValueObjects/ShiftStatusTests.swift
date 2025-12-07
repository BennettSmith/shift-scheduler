import Testing
@testable import Troop900Domain

@Suite("ShiftStatus Tests")
struct ShiftStatusTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(ShiftStatus.draft.displayName == "Draft")
        #expect(ShiftStatus.published.displayName == "Published")
        #expect(ShiftStatus.cancelled.displayName == "Cancelled")
        #expect(ShiftStatus.completed.displayName == "Completed")
    }
    
    @Test("Published status can accept signups")
    func publishedCanAcceptSignups() {
        #expect(ShiftStatus.published.canAcceptSignups)
    }
    
    @Test("Draft status cannot accept signups")
    func draftCannotAcceptSignups() {
        #expect(!ShiftStatus.draft.canAcceptSignups)
    }
    
    @Test("Cancelled status cannot accept signups")
    func cancelledCannotAcceptSignups() {
        #expect(!ShiftStatus.cancelled.canAcceptSignups)
    }
    
    @Test("Completed status cannot accept signups")
    func completedCannotAcceptSignups() {
        #expect(!ShiftStatus.completed.canAcceptSignups)
    }
    
    @Test("Draft is editable")
    func draftIsEditable() {
        #expect(ShiftStatus.draft.isEditable)
    }
    
    @Test("Published is editable")
    func publishedIsEditable() {
        #expect(ShiftStatus.published.isEditable)
    }
    
    @Test("Cancelled is not editable")
    func cancelledIsNotEditable() {
        #expect(!ShiftStatus.cancelled.isEditable)
    }
    
    @Test("Completed is not editable")
    func completedIsNotEditable() {
        #expect(!ShiftStatus.completed.isEditable)
    }
}
