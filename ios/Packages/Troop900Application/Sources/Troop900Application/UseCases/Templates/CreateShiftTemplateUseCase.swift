import Foundation
import Troop900Domain

/// UC 20: Committee Creates Shift Templates
public protocol CreateShiftTemplateUseCaseProtocol: Sendable {
    func execute(request: CreateShiftTemplateRequest) async throws -> ShiftTemplateDetail
}

public final class CreateShiftTemplateUseCase: CreateShiftTemplateUseCaseProtocol, Sendable {
    private let templateRepository: TemplateRepository
    
    public init(templateRepository: TemplateRepository) {
        self.templateRepository = templateRepository
    }
    
    public func execute(request: CreateShiftTemplateRequest) async throws -> ShiftTemplateDetail {
        // Validate inputs
        guard !request.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.invalidInput("Template name cannot be empty")
        }
        
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
        
        let now = Date()
        let template = ShiftTemplate(
            id: UUID().uuidString,
            name: request.name.trimmingCharacters(in: .whitespacesAndNewlines),
            startTime: request.startTime,
            endTime: request.endTime,
            requiredScouts: request.requiredScouts,
            requiredParents: request.requiredParents,
            location: request.location.trimmingCharacters(in: .whitespacesAndNewlines),
            label: request.label?.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: request.notes?.trimmingCharacters(in: .whitespacesAndNewlines),
            isActive: true,
            createdAt: now,
            updatedAt: now
        )
        
        let templateId = try await templateRepository.createTemplate(template)
        
        // Fetch the created template to return
        let createdTemplate = try await templateRepository.getTemplate(id: templateId)
        
        return ShiftTemplateDetail(
            id: createdTemplate.id,
            name: createdTemplate.name,
            startTime: createdTemplate.startTime,
            endTime: createdTemplate.endTime,
            requiredScouts: createdTemplate.requiredScouts,
            requiredParents: createdTemplate.requiredParents,
            location: createdTemplate.location,
            label: createdTemplate.label,
            notes: createdTemplate.notes,
            isActive: createdTemplate.isActive,
            createdAt: createdTemplate.createdAt,
            updatedAt: createdTemplate.updatedAt
        )
    }
}
