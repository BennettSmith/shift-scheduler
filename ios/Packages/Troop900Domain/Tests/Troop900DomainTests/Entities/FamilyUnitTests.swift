import Foundation
import Testing
@testable import Troop900Domain

@Suite("FamilyUnit Tests")
struct FamilyUnitTests {
    
    @Test("FamilyUnit initialization")
    func familyUnitInitialization() {
        let unit = FamilyUnit(
            id: "family-1",
            householdId: "household-1",
            scouts: ["scout-1", "scout-2"],
            parents: ["parent-1"],
            name: "Smith Family",
            createdAt: Date()
        )
        
        #expect(unit.id == "family-1")
        #expect(unit.householdId == "household-1")
        #expect(unit.scouts.count == 2)
        #expect(unit.parents.count == 1)
        #expect(unit.name == "Smith Family")
    }
    
    @Test("All members includes scouts and parents")
    func allMembers() {
        let unit = FamilyUnit(
            id: "family-1",
            householdId: "household-1",
            scouts: ["scout-1", "scout-2"],
            parents: ["parent-1", "parent-2"],
            name: nil,
            createdAt: Date()
        )
        
        let allMembers = unit.allMembers
        #expect(allMembers.count == 4)
        #expect(allMembers.contains("scout-1"))
        #expect(allMembers.contains("scout-2"))
        #expect(allMembers.contains("parent-1"))
        #expect(allMembers.contains("parent-2"))
    }
    
    @Test("All members with only scouts")
    func allMembersScoutsOnly() {
        let unit = FamilyUnit(
            id: "family-1",
            householdId: "household-1",
            scouts: ["scout-1"],
            parents: [],
            name: nil,
            createdAt: Date()
        )
        
        #expect(unit.allMembers.count == 1)
        #expect(unit.allMembers.contains("scout-1"))
    }
}
