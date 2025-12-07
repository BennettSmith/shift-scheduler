import Testing
import Foundation
@testable import Troop900Domain

@Suite("Household Tests")
struct HouseholdTests {
    
    @Test("Household initialization")
    func householdInitialization() {
        let household = Household(
            id: "household-1",
            name: "Smith Household",
            members: ["user-1", "user-2", "user-3"],
            managers: ["user-1"],
            familyUnits: ["family-1", "family-2"],
            linkCode: "LINK123",
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(household.id == "household-1")
        #expect(household.name == "Smith Household")
        #expect(household.members.count == 3)
        #expect(household.managers.count == 1)
        #expect(household.familyUnits.count == 2)
        #expect(household.linkCode == "LINK123")
        #expect(household.isActive)
    }
}
