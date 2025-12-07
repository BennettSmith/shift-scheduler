import Testing
@testable import Troop900Domain

@Suite("TargetAudience Tests")
struct TargetAudienceTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(TargetAudience.all.displayName == "All Users")
        #expect(TargetAudience.scouts.displayName == "Scouts")
        #expect(TargetAudience.parents.displayName == "Parents")
        #expect(TargetAudience.leadership.displayName == "Leadership")
        #expect(TargetAudience.household.displayName == "Household")
        #expect(TargetAudience.individual.displayName == "Individual")
    }
    
    @Test("Raw values")
    func rawValues() {
        #expect(TargetAudience.all.rawValue == "all")
        #expect(TargetAudience.scouts.rawValue == "scouts")
        #expect(TargetAudience.parents.rawValue == "parents")
        #expect(TargetAudience.leadership.rawValue == "leadership")
        #expect(TargetAudience.household.rawValue == "household")
        #expect(TargetAudience.individual.rawValue == "individual")
    }
}
