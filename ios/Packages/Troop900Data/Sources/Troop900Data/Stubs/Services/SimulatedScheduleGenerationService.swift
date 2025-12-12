import Foundation
import Troop900Domain

/// Simulated implementation of ScheduleGenerationService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedScheduleGenerationService: ScheduleGenerationService, @unchecked Sendable {
    private let shiftRepository: ShiftRepository
    private let templateRepository: TemplateRepository
    private let lock = AsyncLock()
    
    public init(
        shiftRepository: ShiftRepository,
        templateRepository: TemplateRepository
    ) {
        self.shiftRepository = shiftRepository
        self.templateRepository = templateRepository
    }
    
    public func generateSchedule(request: ScheduleGenerationRequest) async throws -> ScheduleGenerationResult {
        var createdShiftIds: [String] = []
        let calendar = Calendar.current
        
        // Generate dates based on days of week
        var currentDate = request.startDate
        while currentDate <= request.endDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            if request.daysOfWeek.contains(weekday) {
                // Create shifts for each template
                for templateId in request.templateIds {
                    guard let template = try? await templateRepository.getTemplate(id: templateId) else {
                        continue
                    }
                    
                    // Combine template time with date
                    let templateStartComponents = calendar.dateComponents([.hour, .minute], from: template.startTime)
                    let templateEndComponents = calendar.dateComponents([.hour, .minute], from: template.endTime)
                    
                    var startComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
                    startComponents.hour = templateStartComponents.hour
                    startComponents.minute = templateStartComponents.minute
                    
                    var endComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
                    endComponents.hour = templateEndComponents.hour
                    endComponents.minute = templateEndComponents.minute
                    
                    guard let startTime = calendar.date(from: startComponents),
                          let endTime = calendar.date(from: endComponents) else {
                        continue
                    }
                    
                    let shiftId = try ShiftId(unchecked: UUID().uuidString)
                    let shift = Shift(
                        id: shiftId,
                        date: currentDate,
                        startTime: startTime,
                        endTime: endTime,
                        requiredScouts: template.requiredScouts,
                        requiredParents: template.requiredParents,
                        currentScouts: 0,
                        currentParents: 0,
                        location: template.location,
                        label: template.label,
                        notes: template.notes,
                        status: .draft,
                        seasonId: request.seasonId,
                        templateId: templateId,
                        createdAt: Date()
                    )
                    
                    try await shiftRepository.createShift(shift)
                    createdShiftIds.append(shiftId.value)
                }
            }
            
            // Move to next day
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return ScheduleGenerationResult(
            success: true,
            shiftIds: createdShiftIds,
            message: "Generated \(createdShiftIds.count) shifts"
        )
    }
    
    public func publishSchedule(seasonId: String, shiftIds: [String]) async throws {
        for shiftIdString in shiftIds {
            guard let shiftId = try? ShiftId(unchecked: shiftIdString) else {
                continue
            }
            
            let shift = try await shiftRepository.getShift(id: shiftId)
            
            // Only publish if in draft status
            guard shift.status == .draft else {
                continue
            }
            
            let updatedShift = Shift(
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
                status: .published,
                seasonId: shift.seasonId,
                templateId: shift.templateId,
                createdAt: shift.createdAt
            )
            
            try await shiftRepository.updateShift(updatedShift)
        }
    }
}
