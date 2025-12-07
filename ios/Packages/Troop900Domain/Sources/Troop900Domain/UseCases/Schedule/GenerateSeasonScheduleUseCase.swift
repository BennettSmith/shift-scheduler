import Foundation

/// UC 21: Committee Generates Season Schedule (Bulk Creation)
public protocol GenerateSeasonScheduleUseCaseProtocol: Sendable {
    func execute(request: GenerateSeasonScheduleRequest) async throws -> GenerateSeasonScheduleResponse
}

public final class GenerateSeasonScheduleUseCase: GenerateSeasonScheduleUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let templateRepository: TemplateRepository
    private let seasonRepository: SeasonRepository
    
    public init(
        shiftRepository: ShiftRepository,
        templateRepository: TemplateRepository,
        seasonRepository: SeasonRepository
    ) {
        self.shiftRepository = shiftRepository
        self.templateRepository = templateRepository
        self.seasonRepository = seasonRepository
    }
    
    public func execute(request: GenerateSeasonScheduleRequest) async throws -> GenerateSeasonScheduleResponse {
        // Validate date range
        guard request.endDate > request.startDate else {
            throw DomainError.invalidInput("End date must be after start date")
        }
        
        // Fetch templates
        let templates = try await fetchTemplates(templateIds: request.templateIds)
        guard !templates.isEmpty else {
            throw DomainError.invalidInput("At least one valid template must be provided")
        }
        
        // Create a map of special event dates
        let specialEventMap = Dictionary(
            uniqueKeysWithValues: request.specialEventDates.map { 
                (Calendar.current.startOfDay(for: $0.date), $0) 
            }
        )
        
        // Create a set of excluded dates
        let excludedDatesSet = Set(request.excludedDates.map { Calendar.current.startOfDay(for: $0) })
        
        var shiftsToCreate: [Shift] = []
        var specialEventCount = 0
        let calendar = Calendar.current
        
        // Iterate through each day in the range
        var currentDate = calendar.startOfDay(for: request.startDate)
        let endDate = calendar.startOfDay(for: request.endDate)
        
        while currentDate <= endDate {
            // Skip excluded dates
            if excludedDatesSet.contains(currentDate) {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                continue
            }
            
            // Check for special event on this date
            if let specialEvent = specialEventMap[currentDate] {
                // Create shift from special event template
                if let template = templates.first(where: { $0.id == specialEvent.templateId }) {
                    let shift = createShiftFromTemplate(
                        template: template,
                        date: currentDate,
                        seasonId: request.seasonId,
                        label: specialEvent.label,
                        notes: specialEvent.notes,
                        location: request.defaultLocation
                    )
                    shiftsToCreate.append(shift)
                    specialEventCount += 1
                }
            } else {
                // Create shifts from regular templates
                for template in templates {
                    let shift = createShiftFromTemplate(
                        template: template,
                        date: currentDate,
                        seasonId: request.seasonId,
                        label: template.label,
                        notes: template.notes,
                        location: template.location
                    )
                    shiftsToCreate.append(shift)
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Create all shifts as DRAFT status
        for shift in shiftsToCreate {
            _ = try await shiftRepository.createShift(shift)
        }
        
        let totalVolunteerSlots = shiftsToCreate.reduce(0) { $0 + $1.requiredScouts + $1.requiredParents }
        let datesWithShifts = Set(shiftsToCreate.map { calendar.startOfDay(for: $0.date) }).count
        
        return GenerateSeasonScheduleResponse(
            seasonId: request.seasonId,
            totalShiftsCreated: shiftsToCreate.count,
            totalVolunteerSlots: totalVolunteerSlots,
            datesWithShifts: datesWithShifts,
            specialEventCount: specialEventCount
        )
    }
    
    private func fetchTemplates(templateIds: [String]) async throws -> [ShiftTemplate] {
        var templates: [ShiftTemplate] = []
        for templateId in templateIds {
            do {
                let template = try await templateRepository.getTemplate(id: templateId)
                if template.isActive {
                    templates.append(template)
                }
            } catch {
                // Skip invalid template IDs
                continue
            }
        }
        return templates
    }
    
    private func createShiftFromTemplate(
        template: ShiftTemplate,
        date: Date,
        seasonId: String,
        label: String?,
        notes: String?,
        location: String
    ) -> Shift {
        let calendar = Calendar.current
        
        // Combine date with template times
        let startComponents = calendar.dateComponents([.hour, .minute], from: template.startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: template.endTime)
        
        let startTime = calendar.date(
            bySettingHour: startComponents.hour ?? 0,
            minute: startComponents.minute ?? 0,
            second: 0,
            of: date
        ) ?? date
        
        let endTime = calendar.date(
            bySettingHour: endComponents.hour ?? 0,
            minute: endComponents.minute ?? 0,
            second: 0,
            of: date
        ) ?? date
        
        return Shift(
            id: UUID().uuidString,
            date: calendar.startOfDay(for: date),
            startTime: startTime,
            endTime: endTime,
            requiredScouts: template.requiredScouts,
            requiredParents: template.requiredParents,
            currentScouts: 0,
            currentParents: 0,
            location: location,
            label: label,
            notes: notes,
            status: .draft,  // Always create as draft
            seasonId: seasonId,
            templateId: template.id,
            createdAt: Date()
        )
    }
}
