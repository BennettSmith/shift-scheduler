import Foundation

/// UC 3, 24: Committee Creates Individual Shift
public protocol CreateShiftUseCaseProtocol: Sendable {
    func execute(request: CreateShiftRequest) async throws -> CreateShiftResponse
}

public final class CreateShiftUseCase: CreateShiftUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let messagingService: MessagingService
    
    public init(
        shiftRepository: ShiftRepository,
        messagingService: MessagingService
    ) {
        self.shiftRepository = shiftRepository
        self.messagingService = messagingService
    }
    
    public func execute(request: CreateShiftRequest) async throws -> CreateShiftResponse {
        // Validate inputs
        guard request.requiredScouts >= 0 else {
            throw DomainError.invalidInput("Required scouts must be non-negative")
        }
        
        guard request.requiredParents >= 0 else {
            throw DomainError.invalidInput("Required parents must be non-negative")
        }
        
        guard request.endTime > request.startTime else {
            throw DomainError.invalidInput("End time must be after start time")
        }
        
        guard !request.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.invalidInput("Location cannot be empty")
        }
        
        // Determine initial status
        let initialStatus: ShiftStatus = request.publishImmediately ? .published : .draft
        
        // Create shift
        let shift = Shift(
            id: UUID().uuidString,
            date: request.date,
            startTime: request.startTime,
            endTime: request.endTime,
            requiredScouts: request.requiredScouts,
            requiredParents: request.requiredParents,
            currentScouts: 0,
            currentParents: 0,
            location: request.location.trimmingCharacters(in: .whitespacesAndNewlines),
            label: request.label?.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: request.notes?.trimmingCharacters(in: .whitespacesAndNewlines),
            status: initialStatus,
            seasonId: request.seasonId,
            templateId: nil,
            createdAt: Date()
        )
        
        let shiftId = try await shiftRepository.createShift(shift)
        
        // Send notification if requested and shift is published
        var notificationSent = false
        if request.publishImmediately && request.sendNotification {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            let title = "New Shift Available"
            let message = "A new shift has been added on \(dateFormatter.string(from: request.date)) at \(request.location). Sign up now!"
            
            let sendMessageRequest = SendMessageRequest(
                title: title,
                body: message,
                targetAudience: .all,
                targetUserIds: nil,
                targetHouseholdIds: nil,
                priority: .normal
            )
            
            do {
                _ = try await messagingService.sendMessage(request: sendMessageRequest)
                notificationSent = true
            } catch {
                // Log error but don't fail the shift creation
                // In production, this would be logged to monitoring
                notificationSent = false
            }
        }
        
        return CreateShiftResponse(
            shiftId: shiftId,
            status: initialStatus,
            notificationSent: notificationSent
        )
    }
}
