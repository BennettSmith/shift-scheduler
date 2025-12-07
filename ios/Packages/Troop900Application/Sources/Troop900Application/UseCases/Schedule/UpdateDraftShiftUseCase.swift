import Foundation
import Troop900Domain

/// UC 22: Committee Reviews and Adjusts Draft Schedule
public protocol UpdateDraftShiftUseCaseProtocol: Sendable {
    func execute(request: UpdateShiftRequest) async throws -> ShiftSummary
}

public final class UpdateDraftShiftUseCase: UpdateDraftShiftUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    
    public init(shiftRepository: ShiftRepository) {
        self.shiftRepository = shiftRepository
    }
    
    public func execute(request: UpdateShiftRequest) async throws -> ShiftSummary {
        // Fetch existing shift
        let existingShift = try await shiftRepository.getShift(id: request.shiftId)
        
        // Ensure shift is in draft status
        guard existingShift.status == .draft else {
            throw DomainError.operationFailed(
                "Can only update draft shifts. Shift status is \(existingShift.status.displayName)"
            )
        }
        
        // Validate updates if provided
        if let requiredScouts = request.requiredScouts {
            guard requiredScouts >= 0 else {
                throw DomainError.invalidInput("Required scouts must be non-negative")
            }
        }
        
        if let requiredParents = request.requiredParents {
            guard requiredParents >= 0 else {
                throw DomainError.invalidInput("Required parents must be non-negative")
            }
        }
        
        if let startTime = request.startTime, let endTime = request.endTime {
            guard endTime > startTime else {
                throw DomainError.invalidInput("End time must be after start time")
            }
        } else if let endTime = request.endTime {
            guard endTime > existingShift.startTime else {
                throw DomainError.invalidInput("End time must be after start time")
            }
        } else if let startTime = request.startTime {
            guard existingShift.endTime > startTime else {
                throw DomainError.invalidInput("Start time must be before end time")
            }
        }
        
        if let location = request.location {
            guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw DomainError.invalidInput("Location cannot be empty")
            }
        }
        
        // Build updated shift
        let updatedShift = Shift(
            id: existingShift.id,
            date: request.date ?? existingShift.date,
            startTime: request.startTime ?? existingShift.startTime,
            endTime: request.endTime ?? existingShift.endTime,
            requiredScouts: request.requiredScouts ?? existingShift.requiredScouts,
            requiredParents: request.requiredParents ?? existingShift.requiredParents,
            currentScouts: existingShift.currentScouts,
            currentParents: existingShift.currentParents,
            location: request.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? existingShift.location,
            label: request.label ?? existingShift.label,
            notes: request.notes ?? existingShift.notes,
            status: existingShift.status,
            seasonId: existingShift.seasonId,
            templateId: existingShift.templateId,
            createdAt: existingShift.createdAt
        )
        
        try await shiftRepository.updateShift(updatedShift)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeRange = "\(formatter.string(from: updatedShift.startTime)) - \(formatter.string(from: updatedShift.endTime))"
        
        return ShiftSummary(
            id: updatedShift.id,
            date: updatedShift.date,
            startTime: updatedShift.startTime,
            endTime: updatedShift.endTime,
            requiredScouts: updatedShift.requiredScouts,
            requiredParents: updatedShift.requiredParents,
            currentScouts: updatedShift.currentScouts,
            currentParents: updatedShift.currentParents,
            location: updatedShift.location,
            label: updatedShift.label,
            status: updatedShift.status,
            staffingStatus: updatedShift.staffingStatus,
            timeRange: timeRange
        )
    }
}
