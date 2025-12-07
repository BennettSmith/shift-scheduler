import Foundation
import Troop900Domain

/// UC 23: Committee Publishes Schedule
public protocol PublishScheduleUseCaseProtocol: Sendable {
    func execute(request: PublishScheduleRequest) async throws -> PublishScheduleResponse
}

public final class PublishScheduleUseCase: PublishScheduleUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let seasonRepository: SeasonRepository
    private let messagingService: MessagingService
    
    public init(
        shiftRepository: ShiftRepository,
        seasonRepository: SeasonRepository,
        messagingService: MessagingService
    ) {
        self.shiftRepository = shiftRepository
        self.seasonRepository = seasonRepository
        self.messagingService = messagingService
    }
    
    public func execute(request: PublishScheduleRequest) async throws -> PublishScheduleResponse {
        // Fetch season
        let season = try await seasonRepository.getSeason(id: request.seasonId)
        
        // Get all draft shifts for this season
        let allSeasonShifts = try await shiftRepository.getShiftsForSeason(seasonId: request.seasonId)
        let draftShifts = allSeasonShifts.filter { $0.status == .draft }
        
        guard !draftShifts.isEmpty else {
            throw DomainError.operationFailed("No draft shifts found for this season")
        }
        
        // Publish all draft shifts
        var publishedCount = 0
        for shift in draftShifts {
            let publishedShift = Shift(
                id: shift.id,
                date: shift.date,
                startTime: shift.startTime,
                endTime: shift.endTime,
                requiredScouts: shift.requiredScouts,
                requiredParents: shift.requiredParents,
                currentScouts: shift.currentScouts,
                currentParents: shift.currentParents,
                location: shift.location,
                label: shift.label,
                notes: shift.notes,
                status: .published,  // Change from draft to published
                seasonId: shift.seasonId,
                templateId: shift.templateId,
                createdAt: shift.createdAt
            )
            
            try await shiftRepository.updateShift(publishedShift)
            publishedCount += 1
        }
        
        // Update season status to active if not already
        if season.status != .active {
            let activeSeason = Season(
                id: season.id,
                name: season.name,
                year: season.year,
                startDate: season.startDate,
                endDate: season.endDate,
                status: .active,
                description: season.description,
                createdAt: season.createdAt,
                updatedAt: Date()
            )
            try await seasonRepository.updateSeason(activeSeason)
        }
        
        // Send bulk notification if requested
        var recipientCount = 0
        if request.sendNotification {
            let title = request.notificationTitle ?? "Schedule Published!"
            let message = buildNotificationMessage(
                customMessage: request.notificationMessage,
                season: season,
                shiftCount: publishedCount,
                highlightSpecialEvents: request.highlightSpecialEvents,
                shifts: draftShifts
            )
            
            _ = try await messagingService.sendMessage(
                title: title,
                body: message,
                targetAudience: .all,
                targetUserIds: nil,
                targetHouseholdIds: nil,
                priority: .high
            )
            
            // Estimate recipient count (in real implementation, this would come from the service)
            recipientCount = 1 // Placeholder - actual count would come from messaging service
        }
        
        return PublishScheduleResponse(
            seasonId: request.seasonId,
            shiftsPublished: publishedCount,
            notificationSent: request.sendNotification,
            recipientCount: recipientCount
        )
    }
    
    private func buildNotificationMessage(
        customMessage: String?,
        season: Season,
        shiftCount: Int,
        highlightSpecialEvents: Bool,
        shifts: [Shift]
    ) -> String {
        if let customMessage = customMessage {
            return customMessage
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        var message = "The \(season.name) schedule is now available! "
        message += "\(shiftCount) shifts from \(dateFormatter.string(from: season.startDate)) to \(dateFormatter.string(from: season.endDate))."
        
        if highlightSpecialEvents {
            let specialEventShifts = shifts.filter { shift in
                shift.label?.lowercased().contains("setup") == true ||
                shift.label?.lowercased().contains("delivery") == true ||
                shift.label?.lowercased().contains("event") == true
            }
            
            if !specialEventShifts.isEmpty {
                message += "\n\nSpecial events: "
                let eventDescriptions = specialEventShifts.prefix(3).map { shift in
                    "\(shift.label ?? "Event") on \(dateFormatter.string(from: shift.date))"
                }
                message += eventDescriptions.joined(separator: ", ")
                
                if specialEventShifts.count > 3 {
                    message += ", and more!"
                }
            }
        }
        
        return message
    }
}
