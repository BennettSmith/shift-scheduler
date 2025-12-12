import Foundation
import Troop900Domain

/// In-memory implementation of TemplateRepository for testing and local development.
public final class InMemoryTemplateRepository: TemplateRepository, @unchecked Sendable {
    private var templates: [String: ShiftTemplate] = [:]
    private let lock = AsyncLock()
    
    public init(initialTemplates: [ShiftTemplate] = []) {
        for template in initialTemplates {
            templates[template.id] = template
        }
    }
    
    public func getTemplate(id: String) async throws -> ShiftTemplate {
        lock.lock()
        defer { lock.unlock() }
        guard let template = templates[id] else {
            throw DomainError.templateNotFound
        }
        return template
    }
    
    public func getActiveTemplates() async throws -> [ShiftTemplate] {
        lock.lock()
        defer { lock.unlock() }
        return templates.values.filter { $0.isActive }
    }
    
    public func getAllTemplates() async throws -> [ShiftTemplate] {
        lock.lock()
        defer { lock.unlock() }
        return Array(templates.values)
    }
    
    public func updateTemplate(_ template: ShiftTemplate) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard templates[template.id] != nil else {
            throw DomainError.templateNotFound
        }
        
        templates[template.id] = template
    }
    
    public func createTemplate(_ template: ShiftTemplate) async throws -> String {
        lock.lock()
        defer { lock.unlock() }
        
        guard templates[template.id] == nil else {
            throw DomainError.invalidInput("ShiftTemplate with id \(template.id) already exists")
        }
        
        templates[template.id] = template
        
        return template.id
    }
    
    public func deleteTemplate(id: String) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard templates[id] != nil else {
            throw DomainError.templateNotFound
        }
        
        templates.removeValue(forKey: id)
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        templates.removeAll()
    }
    
    public func getAllTemplates() -> [ShiftTemplate] {
        lock.lock()
        defer { lock.unlock() }
        return Array(templates.values)
    }
}
