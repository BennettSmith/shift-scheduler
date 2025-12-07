import Foundation

/// UC 20: Committee Updates Shift Templates
public protocol UpdateShiftTemplateUseCaseProtocol: Sendable {
    func execute(request: UpdateShiftTemplateRequest) async throws -> ShiftTemplateDetail
}

public final class UpdateShiftTemplateUseCase: UpdateShiftTemplateUseCaseProtocol, Sendable {
    private let templateRepository: TemplateRepository
    
    public init(templateRepository: TemplateRepository) {
        self.templateRepository = templateRepository
    }
    
    public func execute(request: UpdateShiftTemplateRequest) async throws -> ShiftTemplateDetail {
        // Fetch existing template
        let existingTemplate = try await templateRepository.getTemplate(id: request.templateId)
        
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
            guard endTime > existingTemplate.startTime else {
                throw DomainError.invalidInput("End time must be after start time")
            }
        } else if let startTime = request.startTime {
            guard existingTemplate.endTime > startTime else {
                throw DomainError.invalidInput("Start time must be before end time")
            }
        }
        
        if let name = request.name {
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw DomainError.invalidInput("Template name cannot be empty")
            }
        }
        
        if let location = request.location {
            guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw DomainError.invalidInput("Location cannot be empty")
            }
        }
        
        // Build updated template
        let updatedTemplate = ShiftTemplate(
            id: existingTemplate.id,
            name: request.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? existingTemplate.name,
            startTime: request.startTime ?? existingTemplate.startTime,
            endTime: request.endTime ?? existingTemplate.endTime,
            requiredScouts: request.requiredScouts ?? existingTemplate.requiredScouts,
            requiredParents: request.requiredParents ?? existingTemplate.requiredParents,
            location: request.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? existingTemplate.location,
            label: request.label ?? existingTemplate.label,
            notes: request.notes ?? existingTemplate.notes,
            isActive: request.isActive ?? existingTemplate.isActive,
            createdAt: existingTemplate.createdAt,
            updatedAt: Date()
        )
        
        try await templateRepository.updateTemplate(updatedTemplate)
        
        return ShiftTemplateDetail(
            id: updatedTemplate.id,
            name: updatedTemplate.name,
            startTime: updatedTemplate.startTime,
            endTime: updatedTemplate.endTime,
            requiredScouts: updatedTemplate.requiredScouts,
            requiredParents: updatedTemplate.requiredParents,
            location: updatedTemplate.location,
            label: updatedTemplate.label,
            notes: updatedTemplate.notes,
            isActive: updatedTemplate.isActive,
            createdAt: updatedTemplate.createdAt,
            updatedAt: updatedTemplate.updatedAt
        )
    }
}
