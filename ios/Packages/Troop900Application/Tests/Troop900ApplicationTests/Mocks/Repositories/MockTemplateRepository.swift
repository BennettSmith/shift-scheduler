import Foundation
import Troop900Domain

/// Mock implementation of TemplateRepository for testing
public final class MockTemplateRepository: TemplateRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Templates stored by ID
    public var templatesById: [String: ShiftTemplate] = [:]
    
    // MARK: - Configurable Results
    
    public var getTemplateResult: Result<ShiftTemplate, Error>?
    public var getActiveTemplatesResult: Result<[ShiftTemplate], Error>?
    public var getAllTemplatesResult: Result<[ShiftTemplate], Error>?
    public var createTemplateResult: Result<String, Error>?
    public var updateTemplateError: Error?
    public var deleteTemplateError: Error?
    
    // MARK: - Call Tracking
    
    public var getTemplateCallCount = 0
    public var getTemplateCalledWith: [String] = []
    
    public var getActiveTemplatesCallCount = 0
    
    public var getAllTemplatesCallCount = 0
    
    public var createTemplateCallCount = 0
    public var createTemplateCalledWith: [ShiftTemplate] = []
    
    public var updateTemplateCallCount = 0
    public var updateTemplateCalledWith: [ShiftTemplate] = []
    
    public var deleteTemplateCallCount = 0
    public var deleteTemplateCalledWith: [String] = []
    
    // MARK: - TemplateRepository Implementation
    
    public func getTemplate(id: String) async throws -> ShiftTemplate {
        getTemplateCallCount += 1
        getTemplateCalledWith.append(id)
        
        if let result = getTemplateResult {
            return try result.get()
        }
        
        guard let template = templatesById[id] else {
            throw DomainError.templateNotFound
        }
        return template
    }
    
    public func getActiveTemplates() async throws -> [ShiftTemplate] {
        getActiveTemplatesCallCount += 1
        
        if let result = getActiveTemplatesResult {
            return try result.get()
        }
        
        return templatesById.values.filter { $0.isActive }
    }
    
    public func getAllTemplates() async throws -> [ShiftTemplate] {
        getAllTemplatesCallCount += 1
        
        if let result = getAllTemplatesResult {
            return try result.get()
        }
        
        return Array(templatesById.values)
    }
    
    public func updateTemplate(_ template: ShiftTemplate) async throws {
        updateTemplateCallCount += 1
        updateTemplateCalledWith.append(template)
        
        if let error = updateTemplateError {
            throw error
        }
        
        templatesById[template.id] = template
    }
    
    public func createTemplate(_ template: ShiftTemplate) async throws -> String {
        createTemplateCallCount += 1
        createTemplateCalledWith.append(template)
        
        if let result = createTemplateResult {
            return try result.get()
        }
        
        templatesById[template.id] = template
        return template.id
    }
    
    public func deleteTemplate(id: String) async throws {
        deleteTemplateCallCount += 1
        deleteTemplateCalledWith.append(id)
        
        if let error = deleteTemplateError {
            throw error
        }
        
        templatesById.removeValue(forKey: id)
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        templatesById.removeAll()
        getTemplateResult = nil
        getActiveTemplatesResult = nil
        getAllTemplatesResult = nil
        createTemplateResult = nil
        updateTemplateError = nil
        deleteTemplateError = nil
        getTemplateCallCount = 0
        getTemplateCalledWith.removeAll()
        getActiveTemplatesCallCount = 0
        getAllTemplatesCallCount = 0
        createTemplateCallCount = 0
        createTemplateCalledWith.removeAll()
        updateTemplateCallCount = 0
        updateTemplateCalledWith.removeAll()
        deleteTemplateCallCount = 0
        deleteTemplateCalledWith.removeAll()
    }
}
