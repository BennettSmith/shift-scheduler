import Foundation
import Testing
@testable import Troop900Data
import Troop900Domain

@Suite("SimulatedShiftSignupService Tests")
struct SimulatedShiftSignupServiceTests {
    
    func makeTestUser() -> User {
        User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: .active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func makeTestShift(currentScouts: Int = 0, currentParents: Int = 0) -> Shift {
        Shift(
            id: ShiftId(unchecked: "shift-1"),
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: currentScouts,
            currentParents: currentParents,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
    }
    
    @Test("Sign up for shift creates assignment")
    func signUpForShift() async throws {
        let user = makeTestUser()
        let shift = makeTestShift()
        
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let shiftRepo = InMemoryShiftRepository(initialShifts: [shift])
        let assignmentRepo = InMemoryAssignmentRepository()
        
        let service = SimulatedShiftSignupService(
            assignmentRepository: assignmentRepo,
            shiftRepository: shiftRepo,
            userRepository: userRepo
        )
        
        let request = ShiftSignupServiceRequest(
            shiftId: shift.id,
            userId: user.id,
            assignmentType: .scout,
            notes: "Excited to help!"
        )
        
        let response = try await service.signUp(request: request)
        
        #expect(response.success)
        let assignment = try await assignmentRepo.getAssignment(id: response.assignmentId)
        #expect(assignment.userId == user.id)
        #expect(assignment.shiftId == shift.id)
        #expect(assignment.assignmentType == .scout)
        
        // Verify shift counts updated
        let updatedShift = try await shiftRepo.getShift(id: shift.id)
        #expect(updatedShift.currentScouts == 1)
    }
    
    @Test("Sign up throws when shift not published")
    func signUpShiftNotPublished() async throws {
        let user = makeTestUser()
        let shift = Shift(
            id: ShiftId(unchecked: "shift-1"),
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .draft,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let shiftRepo = InMemoryShiftRepository(initialShifts: [shift])
        let assignmentRepo = InMemoryAssignmentRepository()
        
        let service = SimulatedShiftSignupService(
            assignmentRepository: assignmentRepo,
            shiftRepository: shiftRepo,
            userRepository: userRepo
        )
        
        let request = ShiftSignupServiceRequest(
            shiftId: shift.id,
            userId: user.id,
            assignmentType: .scout,
            notes: nil
        )
        
        do {
            _ = try await service.signUp(request: request)
            Issue.record("Expected DomainError.shiftNotPublished")
        } catch DomainError.shiftNotPublished {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Sign up throws when shift is full")
    func signUpShiftFull() async throws {
        let user = makeTestUser()
        let shift = makeTestShift(currentScouts: 3) // Full
        
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let shiftRepo = InMemoryShiftRepository(initialShifts: [shift])
        let assignmentRepo = InMemoryAssignmentRepository()
        
        let service = SimulatedShiftSignupService(
            assignmentRepository: assignmentRepo,
            shiftRepository: shiftRepo,
            userRepository: userRepo
        )
        
        let request = ShiftSignupServiceRequest(
            shiftId: shift.id,
            userId: user.id,
            assignmentType: .scout,
            notes: nil
        )
        
        do {
            _ = try await service.signUp(request: request)
            Issue.record("Expected DomainError.shiftFull")
        } catch DomainError.shiftFull {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Cancel assignment updates status and shift counts")
    func cancelAssignment() async throws {
        let shift = makeTestShift(currentScouts: 1)
        let assignment = Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: shift.id,
            userId: UserId(unchecked: "user-1"),
            assignmentType: .scout,
            status: .confirmed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        let shiftRepo = InMemoryShiftRepository(initialShifts: [shift])
        let assignmentRepo = InMemoryAssignmentRepository(initialAssignments: [assignment])
        let userRepo = InMemoryUserRepository()
        
        let service = SimulatedShiftSignupService(
            assignmentRepository: assignmentRepo,
            shiftRepository: shiftRepo,
            userRepository: userRepo
        )
        
        try await service.cancelAssignment(assignmentId: assignment.id, reason: "Can't make it")
        
        let updatedAssignment = try await assignmentRepo.getAssignment(id: assignment.id)
        #expect(updatedAssignment.status == .cancelled)
        
        let updatedShift = try await shiftRepo.getShift(id: shift.id)
        #expect(updatedShift.currentScouts == 0)
    }
}
