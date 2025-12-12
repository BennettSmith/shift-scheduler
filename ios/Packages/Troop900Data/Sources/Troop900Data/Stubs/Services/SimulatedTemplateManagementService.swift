import Foundation
import Troop900Domain

/// Simulated implementation of TemplateManagementService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedTemplateManagementService: TemplateManagementService, @unchecked Sendable {
    private let templateRepository: TemplateRepository
    private let shiftRepository: ShiftRepository
    private let lock = AsyncLock()
    
    public init(
        templateRepository: TemplateRepository,
        shiftRepository: ShiftRepository
    ) {
        self.templateRepository = templateRepository
        self.shiftRepository = shiftRepository
    }
    
    public func createTemplate(request: CreateTemplateRequest) async throws -> String {
        let templateId = UUID().uuidString
        
        // Normalize times to use today's date for start/end time
        let calendar = Calendar.current
        let today = Date()
        let startComponents = calendar.dateComponents([.hour, .minute], from: request.startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: request.endTime)
        
        var startDateComponents = calendar.dateComponents([.year, .month, .day], from: today)
        startDateComponents.hour = startComponents.hour
        startDateComponents.minute = startComponents.minute
        
        var endDateComponents = calendar.dateComponents([.year, .month, .day], from: today)
        endDateComponents.hour = endComponents.hour
        endDateComponents.minute = endComponents.minute
        
        guard let normalizedStartTime = calendar.date(from: startDateComponents),
              let normalizedEndTime = calendar.date(from: endDateComponents) else {
            throw DomainError.invalidInput("Invalid time components")
        }
        
        let template = ShiftTemplate(
            id: templateId,
            name: request.name,
            startTime: normalizedStartTime,
            endTime: normalizedEndTime,
            requiredScouts: request.requiredScouts,
            requiredParents: request.requiredParents,
            location: request.location,
            label: request.label,
            notes: request.notes,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await templateRepository.createTemplate(template)
        
        return templateId
    }
    
    public func updateTemplate(request: UpdateTemplateRequest) async throws {
        var template = try await templateRepository.getTemplate(id: request.templateId)
        
        // Apply updates
        let updatedName = request.name ?? template.name
        let updatedStartTime = request.startTime ?? template.startTime
        let updatedEndTime = request.endTime ?? template.endTime
        let updatedRequiredScouts = request.requiredScouts ?? template.requiredScouts
        let updatedRequiredParents = request.requiredParents ?? template.requiredParents
        let updatedLocation = request.location ?? template.location
        let updatedLabel = request.label ?? template.label
        let updatedNotes = request.notes ?? template.notes
        
        let updatedTemplate = ShiftTemplate(
            id: template.id,
            name: updatedName,
            startTime: updatedStartTime,
            endTime: updatedEndTime,
            requiredScouts: updatedRequiredScouts,
            requiredParents: updatedRequiredParents,
            location: updatedLocation,
            label: updatedLabel,
            notes: updatedNotes,
            isActive: template.isActive,
            createdAt: template.createdAt,
            updatedAt: Date()
        )
        
        try await templateRepository.updateTemplate(updatedTemplate)
    }
    
    public func deactivateTemplate(templateId: String) async throws {
        var template = try await templateRepository.getTemplate(id: templateId)
        
        let updatedTemplate = ShiftTemplate(
            id: template.id,
            name: template.name,
            startTime: template.startTime,
            endTime: template.endTime,
            requiredScouts: template.requiredScouts,
            requiredParents: template.requiredParents,
            location: template.location,
            label: template.label,
            notes: template.notes,
            isActive: false,
            createdAt: template.createdAt,
            updatedAt: Date()
        )
        
        try await templateRepository.updateTemplate(updatedTemplate)
    }
    
    public func generateShiftsFromTemplate(request: GenerateShiftsRequest) async throws -> [String] {
        let template = try await templateRepository.getTemplate(id: request.templateId)
        var createdShiftIds: [String] = []
        let calendar = Calendar.current
        
        for date in request.dates {
            // Combine template time with date
            let templateStartComponents = calendar.dateComponents([.hour, .minute], from: template.startTime)
            let templateEndComponents = calendar.dateComponents([.hour, .minute], from: template.endTime)
            
            var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
            startComponents.hour = templateStartComponents.hour
            startComponents.minute = templateStartComponents.minute
            
            var endComponents = calendar.dateComponents([.year, .month, .day], from: date)
            endComponents.hour = templateEndComponents.hour
            endComponents.minute = templateEndComponents.minute
            
            guard let startTime = calendar.date(from: startComponents),
                  let endTime = calendar.date(from: endComponents) else {
                continue
            }
            
            let shiftId = try ShiftId(unchecked: UUID().uuidString)
            let shift = Shift(
                id: shiftId,
                date: date,
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
                templateId: template.id,
                createdAt: Date()
            )
            
            try await shiftRepository.createShift(shift)
            createdShiftIds.append(shiftId.value)
        }
        
        return createdShiftIds
    }
}
