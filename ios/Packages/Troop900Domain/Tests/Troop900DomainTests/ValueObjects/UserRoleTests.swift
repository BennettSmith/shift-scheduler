import Testing
@testable import Troop900Domain

@Suite("UserRole Tests")
struct UserRoleTests {
    
    @Test("All cases are defined")
    func allCasesCount() {
        #expect(UserRole.allCases.count == 4)
    }
    
    @Test("Scout display name")
    func scoutDisplayName() {
        #expect(UserRole.scout.displayName == "Scout")
    }
    
    @Test("Parent display name")
    func parentDisplayName() {
        #expect(UserRole.parent.displayName == "Parent")
    }
    
    @Test("Scoutmaster display name")
    func scoutmasterDisplayName() {
        #expect(UserRole.scoutmaster.displayName == "Scoutmaster")
    }
    
    @Test("Assistant Scoutmaster display name")
    func assistantScoutmasterDisplayName() {
        #expect(UserRole.assistantScoutmaster.displayName == "Assistant Scoutmaster")
    }
    
    @Test("Scoutmaster is leadership")
    func scoutmasterIsLeadership() {
        #expect(UserRole.scoutmaster.isLeadership)
    }
    
    @Test("Assistant Scoutmaster is leadership")
    func assistantScoutmasterIsLeadership() {
        #expect(UserRole.assistantScoutmaster.isLeadership)
    }
    
    @Test("Scout is not leadership")
    func scoutIsNotLeadership() {
        #expect(!UserRole.scout.isLeadership)
    }
    
    @Test("Parent is not leadership")
    func parentIsNotLeadership() {
        #expect(!UserRole.parent.isLeadership)
    }
    
    @Test("Raw value encoding")
    func rawValueEncoding() {
        #expect(UserRole.scout.rawValue == "scout")
        #expect(UserRole.parent.rawValue == "parent")
        #expect(UserRole.scoutmaster.rawValue == "scoutmaster")
        #expect(UserRole.assistantScoutmaster.rawValue == "assistant_scoutmaster")
    }
    
    @Test("Init from raw value")
    func initFromRawValue() {
        #expect(UserRole(rawValue: "scout") == .scout)
        #expect(UserRole(rawValue: "parent") == .parent)
        #expect(UserRole(rawValue: "scoutmaster") == .scoutmaster)
        #expect(UserRole(rawValue: "assistant_scoutmaster") == .assistantScoutmaster)
        #expect(UserRole(rawValue: "invalid") == nil)
    }
}
