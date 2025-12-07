import Foundation

/// Protocol for shift template data persistence operations.
public protocol TemplateRepository: Sendable {
    /// Get a template by ID.
    /// - Parameter id: The template's ID.
    /// - Returns: The shift template entity.
    func getTemplate(id: String) async throws -> ShiftTemplate
    
    /// Get all active templates.
    /// - Returns: An array of active shift templates.
    func getActiveTemplates() async throws -> [ShiftTemplate]
    
    /// Get all templates (including inactive).
    /// - Returns: An array of all shift templates.
    func getAllTemplates() async throws -> [ShiftTemplate]
    
    /// Update a template entity.
    /// - Parameter template: The template entity to update.
    func updateTemplate(_ template: ShiftTemplate) async throws
    
    /// Create a new template entity.
    /// - Parameter template: The template entity to create.
    /// - Returns: The created template's ID.
    func createTemplate(_ template: ShiftTemplate) async throws -> String
    
    /// Delete a template by ID.
    /// - Parameter id: The template's ID.
    func deleteTemplate(id: String) async throws
}
