import Testing
@testable import Troop900Domain

@Suite("AssignmentType Tests")
struct AssignmentTypeTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(AssignmentType.scout.displayName == "Scout")
        #expect(AssignmentType.parent.displayName == "Parent")
    }
    
    @Test("Raw values")
    func rawValues() {
        #expect(AssignmentType.scout.rawValue == "scout")
        #expect(AssignmentType.parent.rawValue == "parent")
    }
}
