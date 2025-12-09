import Foundation
import Troop900Domain

/// Protocol for getting shift templates.
public protocol GetShiftTemplatesUseCaseProtocol: Sendable {
    /// Get all shift templates (active and inactive).
    func execute(includeInactive: Bool) async throws -> [ShiftTemplateDetail]
}

/// Use case for retrieving shift templates.
/// Used by admins when creating season schedules or managing templates.
public final class GetShiftTemplatesUseCase: GetShiftTemplatesUseCaseProtocol, Sendable {
    private let templateRepository: TemplateRepository
    
    public init(templateRepository: TemplateRepository) {
        self.templateRepository = templateRepository
    }
    
    public func execute(includeInactive: Bool) async throws -> [ShiftTemplateDetail] {
        let templates: [ShiftTemplate]
        
        if includeInactive {
            templates = try await templateRepository.getAllTemplates()
        } else {
            templates = try await templateRepository.getActiveTemplates()
        }
        
        return templates.map { template in
            ShiftTemplateDetail(
                id: template.id,
                name: template.name,
                startTime: template.startTime,
                endTime: template.endTime,
                requiredScouts: template.requiredScouts,
                requiredParents: template.requiredParents,
                location: template.location,
                label: template.label,
                notes: template.notes,
                isActive: template.isActive,
                createdAt: template.createdAt,
                updatedAt: template.updatedAt
            )
        }.sorted { $0.name < $1.name }
    }
}
