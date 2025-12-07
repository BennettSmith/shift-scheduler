import Testing
@testable import Troop900Domain

@Suite("AccountStatus Tests")
struct AccountStatusTests {
    
    @Test("Display names are correct")
    func displayNames() {
        #expect(AccountStatus.pending.displayName == "Pending")
        #expect(AccountStatus.active.displayName == "Active")
        #expect(AccountStatus.inactive.displayName == "Inactive")
        #expect(AccountStatus.deactivated.displayName == "Deactivated")
    }
    
    @Test("Active status can sign up for shifts")
    func activeCanSignUp() {
        #expect(AccountStatus.active.canSignUpForShifts)
    }
    
    @Test("Pending status cannot sign up for shifts")
    func pendingCannotSignUp() {
        #expect(!AccountStatus.pending.canSignUpForShifts)
    }
    
    @Test("Inactive status cannot sign up for shifts")
    func inactiveCannotSignUp() {
        #expect(!AccountStatus.inactive.canSignUpForShifts)
    }
    
    @Test("Deactivated status cannot sign up for shifts")
    func deactivatedCannotSignUp() {
        #expect(!AccountStatus.deactivated.canSignUpForShifts)
    }
    
    @Test("Raw values")
    func rawValues() {
        #expect(AccountStatus.pending.rawValue == "pending")
        #expect(AccountStatus.active.rawValue == "active")
        #expect(AccountStatus.inactive.rawValue == "inactive")
        #expect(AccountStatus.deactivated.rawValue == "deactivated")
    }
}
