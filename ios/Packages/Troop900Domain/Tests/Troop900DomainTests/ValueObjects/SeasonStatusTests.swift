import Testing
@testable import Troop900Domain

@Suite("SeasonStatus Tests")
struct SeasonStatusTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(SeasonStatus.draft.displayName == "Draft")
        #expect(SeasonStatus.active.displayName == "Active")
        #expect(SeasonStatus.completed.displayName == "Completed")
        #expect(SeasonStatus.archived.displayName == "Archived")
    }
    
    @Test("Active status is active")
    func activeStatusIsActive() {
        #expect(SeasonStatus.active.isActive)
    }
    
    @Test("Draft status is not active")
    func draftStatusIsNotActive() {
        #expect(!SeasonStatus.draft.isActive)
    }
    
    @Test("Completed status is not active")
    func completedStatusIsNotActive() {
        #expect(!SeasonStatus.completed.isActive)
    }
    
    @Test("Archived status is not active")
    func archivedStatusIsNotActive() {
        #expect(!SeasonStatus.archived.isActive)
    }
}
