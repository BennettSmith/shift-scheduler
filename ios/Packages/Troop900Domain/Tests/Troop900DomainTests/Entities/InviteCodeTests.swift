import Testing
import Foundation
@testable import Troop900Domain

@Suite("InviteCode Tests")
struct InviteCodeTests {
    
    @Test("InviteCode initialization")
    func inviteCodeInitialization() {
        let inviteCode = InviteCode(
            id: "invite-1",
            code: "INVITE123",
            householdId: "household-1",
            role: .scout,
            createdBy: "user-1",
            usedBy: nil,
            usedAt: nil,
            expiresAt: Date().addingTimeInterval(86400 * 7),
            isUsed: false,
            createdAt: Date()
        )
        
        #expect(inviteCode.id == "invite-1")
        #expect(inviteCode.code == "INVITE123")
        #expect(inviteCode.householdId == "household-1")
        #expect(inviteCode.role == .scout)
        #expect(!inviteCode.isUsed)
    }
    
    @Test("Expired invite code reports as expired")
    func expiredCodeIsExpired() {
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday
        let inviteCode = InviteCode(
            id: "invite-1",
            code: "INVITE123",
            householdId: "household-1",
            role: .scout,
            createdBy: "user-1",
            usedBy: nil,
            usedAt: nil,
            expiresAt: pastDate,
            isUsed: false,
            createdAt: Date()
        )
        
        #expect(inviteCode.isExpired)
    }
    
    @Test("Non-expired invite code is not expired")
    func nonExpiredCodeIsNotExpired() {
        let futureDate = Date().addingTimeInterval(86400 * 7) // Week from now
        let inviteCode = InviteCode(
            id: "invite-1",
            code: "INVITE123",
            householdId: "household-1",
            role: .scout,
            createdBy: "user-1",
            usedBy: nil,
            usedAt: nil,
            expiresAt: futureDate,
            isUsed: false,
            createdAt: Date()
        )
        
        #expect(!inviteCode.isExpired)
    }
    
    @Test("Invite code without expiration is not expired")
    func codeWithoutExpirationIsNotExpired() {
        let inviteCode = InviteCode(
            id: "invite-1",
            code: "INVITE123",
            householdId: "household-1",
            role: .scout,
            createdBy: "user-1",
            usedBy: nil,
            usedAt: nil,
            expiresAt: nil,
            isUsed: false,
            createdAt: Date()
        )
        
        #expect(!inviteCode.isExpired)
    }
    
    @Test("Unused non-expired code is valid")
    func unusedNonExpiredIsValid() {
        let futureDate = Date().addingTimeInterval(86400 * 7)
        let inviteCode = InviteCode(
            id: "invite-1",
            code: "INVITE123",
            householdId: "household-1",
            role: .scout,
            createdBy: "user-1",
            usedBy: nil,
            usedAt: nil,
            expiresAt: futureDate,
            isUsed: false,
            createdAt: Date()
        )
        
        #expect(inviteCode.isValid)
    }
    
    @Test("Used code is not valid")
    func usedCodeIsNotValid() {
        let inviteCode = InviteCode(
            id: "invite-1",
            code: "INVITE123",
            householdId: "household-1",
            role: .scout,
            createdBy: "user-1",
            usedBy: "user-2",
            usedAt: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 7),
            isUsed: true,
            createdAt: Date()
        )
        
        #expect(!inviteCode.isValid)
    }
    
    @Test("Expired code is not valid")
    func expiredCodeIsNotValid() {
        let pastDate = Date().addingTimeInterval(-86400)
        let inviteCode = InviteCode(
            id: "invite-1",
            code: "INVITE123",
            householdId: "household-1",
            role: .scout,
            createdBy: "user-1",
            usedBy: nil,
            usedAt: nil,
            expiresAt: pastDate,
            isUsed: false,
            createdAt: Date()
        )
        
        #expect(!inviteCode.isValid)
    }
}
