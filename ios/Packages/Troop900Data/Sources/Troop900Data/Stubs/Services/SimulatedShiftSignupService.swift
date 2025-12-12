import Foundation
import Troop900Domain

/// Simulated implementation of ShiftSignupService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedShiftSignupService: ShiftSignupService, @unchecked Sendable {
    private let assignmentRepository: AssignmentRepository
    private let shiftRepository: ShiftRepository
    private let userRepository: UserRepository
    private let lock = AsyncLock()
    
    public init(
        assignmentRepository: AssignmentRepository,
        shiftRepository: ShiftRepository,
        userRepository: UserRepository
    ) {
        self.assignmentRepository = assignmentRepository
        self.shiftRepository = shiftRepository
        self.userRepository = userRepository
    }
    
    public func signUp(request: ShiftSignupServiceRequest) async throws -> ShiftSignupServiceResponse {
        // Verify shift exists and is published
        let shift = try await shiftRepository.getShift(id: request.shiftId)
        guard shift.status == .published else {
            throw DomainError.shiftNotPublished
        }
        
        // Verify user exists
        let user = try await userRepository.getUser(id: request.userId)
        guard user.canSignUpForShifts else {
            throw DomainError.invalidInput("User cannot sign up for shifts")
        }
        
        // Check if user already has an assignment for this shift
        let existingAssignments = try await assignmentRepository.getAssignmentsForShift(shiftId: request.shiftId)
        if existingAssignments.contains(where: { $0.userId == request.userId && $0.isActive }) {
            throw DomainError.alreadyAssignedToShift
        }
        
        // Check capacity
        let currentCount = request.assignmentType == .scout ? shift.currentScouts : shift.currentParents
        let requiredCount = request.assignmentType == .scout ? shift.requiredScouts : shift.requiredParents
        
        if currentCount >= requiredCount {
            throw DomainError.shiftFull
        }
        
        // Create assignment
        let assignmentId = try AssignmentId(unchecked: UUID().uuidString)
        let assignment = Assignment(
            id: assignmentId,
            shiftId: request.shiftId,
            userId: request.userId,
            assignmentType: request.assignmentType,
            status: .pending,
            notes: request.notes,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        try await assignmentRepository.createAssignment(assignment)
        
        // Update shift counts
        var updatedShift = shift
        if request.assignmentType == .scout {
            updatedShift = Shift(
                id: shift.id,
                date: shift.date,
                startTime: shift.startTime,
                endTime: shift.endTime,
                requiredScouts: shift.requiredScouts,
                requiredParents: shift.requiredParents,
                currentScouts: shift.currentScouts + 1,
                currentParents: shift.currentParents,
                location: shift.location,
                label: shift.label,
                notes: shift.notes,
                status: shift.status,
                seasonId: shift.seasonId,
                templateId: shift.templateId,
                createdAt: shift.createdAt
            )
        } else {
            updatedShift = Shift(
                id: shift.id,
                date: shift.date,
                startTime: shift.startTime,
                endTime: shift.endTime,
                requiredScouts: shift.requiredScouts,
                requiredParents: shift.requiredParents,
                currentScouts: shift.currentScouts,
                currentParents: shift.currentParents + 1,
                location: shift.location,
                label: shift.label,
                notes: shift.notes,
                status: shift.status,
                seasonId: shift.seasonId,
                templateId: shift.templateId,
                createdAt: shift.createdAt
            )
        }
        
        try await shiftRepository.updateShift(updatedShift)
        
        return ShiftSignupServiceResponse(
            success: true,
            assignmentId: assignmentId,
            message: "Successfully signed up for shift"
        )
    }
    
    public func cancelAssignment(assignmentId: AssignmentId, reason: String?) async throws {
        // Get assignment
        let assignment = try await assignmentRepository.getAssignment(id: assignmentId)
        
        // Update assignment status
        let updatedAssignment = Assignment(
            id: assignment.id,
            shiftId: assignment.shiftId,
            userId: assignment.userId,
            assignmentType: assignment.assignmentType,
            status: .cancelled,
            notes: reason ?? assignment.notes,
            assignedAt: assignment.assignedAt,
            assignedBy: assignment.assignedBy
        )
        
        try await assignmentRepository.updateAssignment(updatedAssignment)
        
        // Update shift counts
        let shift = try await shiftRepository.getShift(id: assignment.shiftId)
        var updatedShift = shift
        if assignment.assignmentType == .scout {
            updatedShift = Shift(
                id: shift.id,
                date: shift.date,
                startTime: shift.startTime,
                endTime: shift.endTime,
                requiredScouts: shift.requiredScouts,
                requiredParents: shift.requiredParents,
                currentScouts: max(0, shift.currentScouts - 1),
                currentParents: shift.currentParents,
                location: shift.location,
                label: shift.label,
                notes: shift.notes,
                status: shift.status,
                seasonId: shift.seasonId,
                templateId: shift.templateId,
                createdAt: shift.createdAt
            )
        } else {
            updatedShift = Shift(
                id: shift.id,
                date: shift.date,
                startTime: shift.startTime,
                endTime: shift.endTime,
                requiredScouts: shift.requiredScouts,
                requiredParents: shift.requiredParents,
                currentScouts: shift.currentScouts,
                currentParents: max(0, shift.currentParents - 1),
                location: shift.location,
                label: shift.label,
                notes: shift.notes,
                status: shift.status,
                seasonId: shift.seasonId,
                templateId: shift.templateId,
                createdAt: shift.createdAt
            )
        }
        
        try await shiftRepository.updateShift(updatedShift)
    }
}
